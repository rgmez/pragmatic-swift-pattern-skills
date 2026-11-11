#!/usr/bin/env ruby

require "optparse"
require "pathname"
require "uri"

options = { root: Dir.pwd, expected_count: nil }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby validate_catalogue_readmes.rb [--root PATH] [--expected-count N]"
  parser.on("--root PATH", "Swift pattern catalogue root") { |value| options[:root] = value }
  parser.on("--expected-count N", Integer, "Expected canonical guide count") { |value| options[:expected_count] = value }
end.parse!

root = File.expand_path(options[:root])
abort("Catalogue root does not exist: #{root}") unless File.directory?(root)

def relative(root, path)
  Pathname.new(path).relative_path_from(Pathname.new(root)).to_s
end

guides = Dir.glob(File.join(root, "* Patterns", "*", "README.md")).sort
abort("No canonical pattern guides found under '* Patterns/*/README.md'") if guides.empty?

required_sections = [
  "At a glance",
  "The app problem",
  "Start with direct Swift",
  "The turning point",
  "Pattern intent",
  "Participants and responsibilities",
  "How the Swift implementation works",
  "Diagram",
  "Run the example",
  "Tests",
  "Trade-offs",
  "Alternatives",
  "When not to use it",
  "Source map",
  "Continue exploring"
]
errors = []

if options[:expected_count] && guides.count != options[:expected_count]
  errors << "Expected #{options[:expected_count]} canonical guides, found #{guides.count}"
end

def hard_wrap_errors(root, path)
  failures = []
  in_code = false
  previous_plain = false

  File.readlines(path, chomp: true).each_with_index do |line, index|
    if line.start_with?("```")
      in_code = !in_code
      previous_plain = false
      next
    end
    next if in_code

    stripped = line.strip
    special = stripped.empty? || stripped.start_with?("#", ">", "- ", "| ", "![", "<") || stripped.match?(/^\d+\. /)
    plain = !special
    failures << "#{relative(root, path)}:#{index + 1} hard-wrapped prose" if plain && previous_plain
    previous_plain = plain
  end

  failures
end

guides.each do |path|
  text = File.read(path)
  required_sections.each do |section|
    heading = /^##\s+.*#{Regexp.escape(section)}.*$/
    errors << "#{relative(root, path)} missing heading: #{section}" unless text.match?(heading)
  end
  errors << "#{relative(root, path)} must contain one normalized caption" unless text.scan(/^> \*\*Caption:\*\*/).count == 1
  errors << "#{relative(root, path)} must contain one catalogue navigation row" unless text.scan(/^\[← Pattern catalogue\]/).count == 1
  errors << "#{relative(root, path)} must contain one At a glance section" unless text.scan(/^## ✨ At a glance$/).count == 1
  errors << "#{relative(root, path)} must contain exactly one Mermaid block" unless text.scan(/^```mermaid$/).count == 1
  errors << "#{relative(root, path)} must contain one accessible diagram description" unless text.scan(/^\*\*Accessible description:\*\*/).count == 1
  errors.concat(hard_wrap_errors(root, path))
end

markdown_files = Dir.glob(File.join(root, "**", "*.md"), File::FNM_DOTMATCH).reject do |path|
  path.include?("/.git/") || path.include?("/.build/") || path.include?("/Editorial/")
end

local_targets = 0
mermaid_count = 0
markdown_files.each do |path|
  File.read(path).scan(/!?\[[^\]]*\]\(([^)]+)\)/).flatten.each do |raw_target|
    target = raw_target.strip.sub(/\s+\"[^\"]*\"\z/, "")
    next if target.empty? || target.start_with?("#", "http://", "https://", "mailto:")
    next if target.include?("[category]") || target.start_with?("path/to/") || target.include?("<pattern-directory>")
    next if relative(root, path) == "Documentation/pattern-readme-template.md" && target.start_with?("../../README.md#")

    target = target[1...-1] if target.start_with?("<") && target.end_with?(">")
    decoded = URI.decode_www_form_component(target.split("#", 2).first)
    next if decoded.empty?

    local_targets += 1
    destination = File.expand_path(decoded, File.dirname(path))
    errors << "#{relative(root, path)} unresolved target: #{target}" unless File.exist?(destination)
  end

  open_line = nil
  declaration = nil
  File.readlines(path, chomp: true).each_with_index do |line, index|
    if open_line
      if line.strip == "```"
        mermaid_count += 1
        unless declaration&.match?(/\A(?:flowchart|graph|sequenceDiagram|stateDiagram(?:-v2)?|classDiagram)\b/)
          errors << "#{relative(root, path)}:#{open_line} unsupported Mermaid declaration: #{declaration.inspect}"
        end
        open_line = nil
        declaration = nil
      elsif declaration.nil? && !line.strip.empty?
        declaration = line.strip
      end
    elsif line.strip == "```mermaid"
      open_line = index + 1
    end
  end
  errors << "#{relative(root, path)}:#{open_line} unclosed Mermaid fence" if open_line
end

unless errors.empty?
  warn errors.join("\n")
  exit 1
end

puts "Catalogue README validation passed"
puts "  canonical guides: #{guides.count}"
puts "  local targets: #{local_targets}"
puts "  Mermaid blocks: #{mermaid_count}"
