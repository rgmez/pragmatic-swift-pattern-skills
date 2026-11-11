#!/usr/bin/env ruby

require "json"
require "pathname"
require "rexml/document"
require "uri"
require "yaml"

ROOT = File.expand_path("..", __dir__)
EXPECTED_SKILLS = %w[
  audit-swift-pattern-catalogue
  choose-swift-design-pattern
  implement-swift-design-pattern
  teach-swift-design-pattern
].freeze
FRONTMATTER_FIELDS = %w[name description license compatibility metadata allowed-tools].freeze
OPENAI_TOP_LEVEL_FIELDS = %w[interface dependencies policy].freeze
OPENAI_INTERFACE_FIELDS = %w[display_name short_description icon_small icon_large brand_color default_prompt].freeze
SKILL_NAME_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
ICON_COLORS = %w[#111214 #F4512C #C92A2A #FFFFFF #7B7F85].freeze

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
  license_path = File.join(directory, "LICENSE")

  errors << "#{relative(directory)} missing SKILL.md" unless File.file?(skill_path)
  errors << "#{relative(directory)} missing human README.md" unless File.file?(readme_path)
  errors << "#{relative(directory)} missing agents/openai.yaml" unless File.file?(openai_path)
  errors << "#{relative(directory)} missing bundled LICENSE" unless File.file?(license_path)
  if File.file?(license_path) && File.file?(File.join(ROOT, "LICENSE"))
    errors << "#{relative(license_path)} must match the repository MIT license" unless File.read(license_path) == File.read(File.join(ROOT, "LICENSE"))
  end
  next unless File.file?(skill_path)

  begin
    frontmatter_data = frontmatter(skill_path)
    unless frontmatter_data.is_a?(Hash)
      errors << "#{relative(skill_path)} frontmatter must be a mapping"
      next
    end

    unknown_fields = frontmatter_data.keys.map(&:to_s) - FRONTMATTER_FIELDS
    errors << "#{relative(skill_path)} has unsupported frontmatter fields: #{unknown_fields.join(", ")}" unless unknown_fields.empty?

    skill_name = frontmatter_data["name"]
    errors << "#{relative(skill_path)} name must match directory" unless skill_name == name
    errors << "#{relative(skill_path)} name must use lowercase letters, digits, and single hyphens" unless skill_name.is_a?(String) && skill_name.length.between?(1, 64) && skill_name.match?(SKILL_NAME_PATTERN)

    description = frontmatter_data["description"]
    errors << "#{relative(skill_path)} needs a focused description" unless description.is_a?(String) && description.length.between?(40, 1_024)
    errors << "#{relative(skill_path)} license must be MIT" unless frontmatter_data["license"] == "MIT"

    compatibility = frontmatter_data["compatibility"]
    errors << "#{relative(skill_path)} compatibility must be a 1-500 character string" if compatibility && (!compatibility.is_a?(String) || !compatibility.length.between?(1, 500))

    custom_metadata = frontmatter_data["metadata"]
    if custom_metadata && (!custom_metadata.is_a?(Hash) || !custom_metadata.all? { |key, value| key.is_a?(String) && value.is_a?(String) })
      errors << "#{relative(skill_path)} metadata keys and values must be strings"
    end

    allowed_tools = frontmatter_data["allowed-tools"]
    errors << "#{relative(skill_path)} allowed-tools must be a string" if allowed_tools && !allowed_tools.is_a?(String)
  rescue StandardError => error
    errors << "#{relative(skill_path)}: #{error.message}"
  end

  skill_text = File.read(skill_path)
  Dir.glob(File.join(directory, "{references,scripts}", "**", "*")).select { |path| File.file?(path) }.each do |support_path|
    support_reference = Pathname.new(support_path).relative_path_from(Pathname.new(directory)).to_s
    errors << "#{relative(support_path)} is not routed from SKILL.md" unless skill_text.include?(support_reference)
  end

  skill_text.scan(/!?\[[^\]]*\]\(([^)]+)\)/).flatten.each do |raw_target|
    target = raw_target.strip.sub(/\s+\"[^\"]*\"\z/, "")
    next if target.empty? || target.start_with?("#", "http://", "https://", "mailto:")

    decoded = URI.decode_www_form_component(target.split("#", 2).first)
    destination = File.expand_path(decoded, File.dirname(skill_path))
    errors << "#{relative(skill_path)} reference escapes its skill package: #{target}" unless destination.start_with?("#{directory}/")
  end

  if File.file?(openai_path)
    begin
      openai_raw = File.read(openai_path)
      openai = YAML.safe_load(openai_raw, permitted_classes: [], aliases: false)
      unless openai.is_a?(Hash)
        errors << "#{relative(openai_path)} must be a mapping"
        next
      end

      unknown_top_level = openai.keys.map(&:to_s) - OPENAI_TOP_LEVEL_FIELDS
      errors << "#{relative(openai_path)} has unsupported top-level fields: #{unknown_top_level.join(", ")}" unless unknown_top_level.empty?

      interface = openai["interface"]
      unless interface.is_a?(Hash)
        errors << "#{relative(openai_path)} interface must be a mapping"
        next
      end

      unknown_interface = interface.keys.map(&:to_s) - OPENAI_INTERFACE_FIELDS
      errors << "#{relative(openai_path)} has unsupported interface fields: #{unknown_interface.join(", ")}" unless unknown_interface.empty?

      display_name = interface["display_name"]
      errors << "#{relative(openai_path)} display_name must be a non-empty string" unless display_name.is_a?(String) && !display_name.empty?

      short_description = interface["short_description"]
      errors << "#{relative(openai_path)} short_description must contain 25-64 characters" unless short_description.is_a?(String) && short_description.length.between?(25, 64)

      brand_color = interface["brand_color"]
      errors << "#{relative(openai_path)} brand_color must be a six-digit hex color" unless brand_color.is_a?(String) && brand_color.match?(/\A#[0-9A-Fa-f]{6}\z/)

      prompt = interface["default_prompt"]
      errors << "#{relative(openai_path)} default_prompt must mention $#{name}" unless prompt.is_a?(String) && prompt.include?("$#{name}")

      %w[icon_small icon_large].each do |icon_field|
        icon_target = interface[icon_field]
        unless icon_target.is_a?(String) && icon_target.start_with?("./assets/")
          errors << "#{relative(openai_path)} #{icon_field} must point to ./assets/"
          next
        end

        icon_path = File.expand_path(icon_target, directory)
        unless File.file?(icon_path)
          errors << "#{relative(openai_path)} missing #{icon_field}: #{icon_target}"
          next
        end

        begin
          icon_source = File.read(icon_path)
          svg = REXML::Document.new(icon_source).root
          valid_svg = svg&.name == "svg" && svg.attributes["viewBox"] && svg.attributes["role"] == "img" && svg.attributes["aria-labelledby"] && svg.elements["title"] && svg.elements["desc"]
          errors << "#{relative(icon_path)} must be an accessible SVG" unless valid_svg
          unexpected_colors = icon_source.scan(/#[0-9A-Fa-f]{6}/).map(&:upcase).uniq - ICON_COLORS
          errors << "#{relative(icon_path)} uses colors outside the closed palette: #{unexpected_colors.join(", ")}" unless unexpected_colors.empty?
          errors << "#{relative(icon_path)} contains a forbidden complex or raster element" if icon_source.match?(/<(?:filter|linearGradient|radialGradient|image|text|foreignObject)\b/i)
        rescue REXML::ParseException => error
          errors << "#{relative(icon_path)}: #{error.message}"
        end
      end

      interface.each do |field, value|
        next unless value.is_a?(String)

        quoted_line = openai_raw.lines.any? { |line| line.match?(/^  #{Regexp.escape(field)}:\s*\".*\"\s*$/) }
        errors << "#{relative(openai_path)} #{field} must be quoted" unless quoted_line
      end
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
    errors << "upstream.lock.json has invalid evidence selection" unless lock["selection"] == "latest commit touching allowlisted evidence"
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
