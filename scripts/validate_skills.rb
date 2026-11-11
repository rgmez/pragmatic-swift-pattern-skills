#!/usr/bin/env ruby

require "json"
require "pathname"
require "uri"
require "yaml"

ROOT = File.expand_path("..", __dir__)
EXPECTED_SKILLS = %w[
  audit-swift-pattern-catalogue
  choose-swift-design-pattern
  implement-swift-design-pattern
  teach-swift-design-pattern
].freeze

errors = []
skill_directories = Dir.glob(File.join(ROOT, "skills", "*")).select { |path| File.directory?(path) }.sort
skill_names = skill_directories.map { |path| File.basename(path) }
errors << "Expected skills #{EXPECTED_SKILLS.inspect}, found #{skill_names.inspect}" unless skill_names == EXPECTED_SKILLS

def frontmatter(path)
  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  raise "Missing YAML frontmatter" unless match
  YAML.safe_load(match[1], permitted_classes: [], aliases: false)
end

def relative(path)
  Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
end

skill_directories.each do |directory|
  name = File.basename(directory)
  skill_path = File.join(directory, "SKILL.md")
  readme_path = File.join(directory, "README.md")
  openai_path = File.join(directory, "agents", "openai.yaml")

  errors << "#{relative(directory)} missing SKILL.md" unless File.file?(skill_path)
  errors << "#{relative(directory)} missing human README.md" unless File.file?(readme_path)
  errors << "#{relative(directory)} missing agents/openai.yaml" unless File.file?(openai_path)
  errors << "#{relative(directory)} missing bundled LICENSE" unless File.file?(File.join(directory, "LICENSE"))
  next unless File.file?(skill_path)

  begin
    metadata = frontmatter(skill_path)
    errors << "#{relative(skill_path)} name must match directory" unless metadata["name"] == name
    description = metadata["description"]
    errors << "#{relative(skill_path)} needs a focused description" unless description.is_a?(String) && description.length.between?(40, 1_024)
  rescue StandardError => error
    errors << "#{relative(skill_path)}: #{error.message}"
  end

  if File.file?(openai_path)
    begin
      openai = YAML.safe_load(File.read(openai_path), permitted_classes: [], aliases: false)
      prompt = openai.dig("interface", "default_prompt")
      errors << "#{relative(openai_path)} default_prompt must mention $#{name}" unless prompt&.include?("$#{name}")
    rescue StandardError => error
      errors << "#{relative(openai_path)}: #{error.message}"
    end
  end
end

markdown_files = Dir.glob(File.join(ROOT, "**", "*.md"), File::FNM_DOTMATCH).reject do |path|
  path.include?("/.git/") || path.include?("/.smoke/") || path.include?("/upstream/")
end
markdown_files.each do |path|
  text = File.read(path)
  errors << "#{relative(path)} contains unfinished TODO text" if text.match?(/\bTODO\b|\[TODO:/)
  errors << "#{relative(path)} contains a personal absolute path" if text.include?("/Users/")

  text.scan(/!?\[[^\]]*\]\(([^)]+)\)/).flatten.each do |raw_target|
    target = raw_target.strip.sub(/\s+\"[^\"]*\"\z/, "")
    next if target.empty? || target.start_with?("#", "http://", "https://", "mailto:")
    next if target.include?("[category]") || target.start_with?("path/to/") || target.include?("<pattern-directory>")
    next if relative(path).end_with?("pattern-readme-template.md") && target.start_with?("../../README.md#")
    target = target[1...-1] if target.start_with?("<") && target.end_with?(">")
    decoded = URI.decode_www_form_component(target.split("#", 2).first)
    next if decoded.empty?

    destination = File.expand_path(decoded, File.dirname(path))
    errors << "#{relative(path)} unresolved target: #{target}" unless File.exist?(destination)
  end
end

human_readmes = [File.join(ROOT, "README.md")] + Dir.glob(File.join(ROOT, "skills", "*", "README.md"))
human_readmes.each do |path|
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
    errors << "#{relative(path)}:#{index + 1} hard-wrapped prose" if plain && previous_plain
    previous_plain = plain
  end
end

root_readme = File.read(File.join(ROOT, "README.md"))
errors << "README.md must state the pro-pattern, anti-overengineering position" unless root_readme.include?("strongly in favor of design patterns") && root_readme.include?("speculative overengineering")

lock_path = File.join(ROOT, "upstream.lock.json")
if File.file?(lock_path)
  begin
    lock = JSON.parse(File.read(lock_path))
    errors << "upstream.lock.json has invalid commit" unless lock["commit"]&.match?(/\A[0-9a-f]{40}\z/)
    Array(lock["generated_files"]).each do |generated_path|
      absolute = File.join(ROOT, generated_path)
      errors << "Missing generated file: #{generated_path}" unless File.file?(absolute)
      if File.file?(absolute)
        header = File.readlines(absolute, chomp: true).first(2).join("\n")
        errors << "Generated file missing provenance header: #{generated_path}" unless header.include?("Generated from rgmez/Design-Patterns-in-Swift@")
      end
    end
  rescue StandardError => error
    errors << "upstream.lock.json: #{error.message}"
  end
else
  errors << "Missing upstream.lock.json"
end

unless errors.empty?
  warn errors.join("\n")
  exit 1
end

puts "Skill repository validation passed"
puts "  skills: #{skill_names.count}"
puts "  Markdown files: #{markdown_files.count}"
