#!/usr/bin/env ruby

require "fileutils"
require "json"
require "optparse"
require "pathname"
require "shellwords"
require "time"
require "uri"

ROOT = File.expand_path("..", __dir__)
UPSTREAM_REPOSITORY = "rgmez/Design-Patterns-in-Swift"
UPSTREAM_BRANCH = "master"

MAPPINGS = [
  [".codex/skills/choose-swift-design-pattern/references/decision-matrix.md", "skills/choose-swift-design-pattern/references/decision-matrix.md", :markdown],
  [".codex/skills/choose-swift-design-pattern/references/catalogue-guidance.md", "skills/choose-swift-design-pattern/references/catalogue-guidance.md", :markdown],
  [".codex/skills/choose-swift-design-pattern/references/example-quality-checklist.md", "skills/choose-swift-design-pattern/references/example-quality-checklist.md", :markdown],
  ["Documentation/find-pattern-by-pressure.md", "skills/choose-swift-design-pattern/references/pressure-index.md", :markdown],
  ["Documentation/skill-decision-signals.md", "skills/implement-swift-design-pattern/references/evidence-gate.md", :markdown],
  [".codex/skills/choose-swift-design-pattern/references/decision-matrix.md", "skills/implement-swift-design-pattern/references/decision-matrix.md", :markdown],
  ["Documentation/pattern-readme-template.md", "skills/teach-swift-design-pattern/references/pattern-readme-template.md", :markdown],
  ["Documentation/readme-experience.md", "skills/teach-swift-design-pattern/references/readme-experience.md", :markdown],
  ["Documentation/visual-style.md", "skills/teach-swift-design-pattern/references/visual-style.md", :markdown],
  [".codex/skills/choose-swift-design-pattern/references/catalogue-guidance.md", "skills/audit-swift-pattern-catalogue/references/catalogue-guidance.md", :markdown],
  [".codex/skills/choose-swift-design-pattern/references/example-quality-checklist.md", "skills/audit-swift-pattern-catalogue/references/example-quality-checklist.md", :markdown],
  ["Documentation/catalogue-review.md", "skills/audit-swift-pattern-catalogue/references/catalogue-review.md", :markdown],
  ["Documentation/bonus-track-review.md", "skills/audit-swift-pattern-catalogue/references/hardening-review.md", :markdown],
  ["scripts/validate_readmes.rb", "skills/audit-swift-pattern-catalogue/references/upstream-readme-validator.rb", :ruby]
].freeze

options = { check: false }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/sync_from_catalogue.rb --source PATH [--check]"
  parser.on("--source PATH", "Checked-out Design-Patterns-in-Swift repository") { |value| options[:source] = value }
  parser.on("--check", "Fail when generated references or the lock are stale") { options[:check] = true }
end.parse!

abort("--source is required") unless options[:source]

source_root = File.expand_path(options[:source])
abort("Not a Git repository: #{source_root}") unless system("git", "-C", source_root, "rev-parse", "--git-dir", out: File::NULL)

upstream_commit = `git -C #{Shellwords.escape(source_root)} rev-parse HEAD`.strip
abort("Could not resolve upstream commit") unless upstream_commit.match?(/\A[0-9a-f]{40}\z/)

def encoded_path(path)
  path.split("/").map { |component| URI.encode_www_form_component(component).gsub("+", "%20") }.join("/")
end

def rewrite_markdown_links(raw, source_path, commit)
  raw.gsub(/(!?)\[([^\]]*)\]\(([^)]+)\)/) do
    image_prefix = Regexp.last_match(1)
    label = Regexp.last_match(2)
    target = Regexp.last_match(3)
    next Regexp.last_match(0) if target.empty? || target.start_with?("#", "http://", "https://", "mailto:")
    next Regexp.last_match(0) if target.include?("[category]") || target.start_with?("path/to/") || target.include?("<pattern-directory>")
    next Regexp.last_match(0) if source_path == "Documentation/pattern-readme-template.md" && (target.start_with?("../../README.md#") || target == "../README.md")

    path, fragment = target.split("#", 2)
    decoded = URI.decode_www_form_component(path)
    resolved = Pathname.new(File.dirname(source_path)).join(decoded).cleanpath.to_s
    host = image_prefix == "!" ? "https://raw.githubusercontent.com/#{UPSTREAM_REPOSITORY}/#{commit}" : "https://github.com/#{UPSTREAM_REPOSITORY}/blob/#{commit}"
    rewritten = "#{host}/#{encoded_path(resolved)}"
    rewritten += "##{fragment}" if fragment
    "#{image_prefix}[#{label}](#{rewritten})"
  end
end

def generated_content(raw, source_path, commit, kind)
  marker = "Generated from #{UPSTREAM_REPOSITORY}@#{commit}:#{source_path}. Do not edit by hand."
  case kind
  when :markdown
    rewritten = rewrite_markdown_links(raw, source_path, commit)
    "<!-- #{marker} -->\n\n#{rewritten.sub(/\A\s+/, "")}"
  when :ruby
    body = raw.sub(/\A#![^\n]*\n/, "")
    "#!/usr/bin/env ruby\n# #{marker}\n\n#{body.sub(/\A\s+/, "")}"
  else
    raise "Unsupported generated kind: #{kind}"
  end
end

stale = []

MAPPINGS.each do |source_path, destination_path, kind|
  source = File.join(source_root, source_path)
  destination = File.join(ROOT, destination_path)
  abort("Missing upstream source: #{source_path}") unless File.file?(source)

  expected = generated_content(File.read(source), source_path, upstream_commit, kind)
  if options[:check]
    stale << destination_path unless File.file?(destination) && File.read(destination) == expected
  else
    FileUtils.mkdir_p(File.dirname(destination))
    File.write(destination, expected)
    FileUtils.chmod(0o755, destination) if kind == :ruby
  end
end

lock_path = File.join(ROOT, "upstream.lock.json")
if options[:check]
  if File.file?(lock_path)
    lock = JSON.parse(File.read(lock_path))
    stale << "upstream.lock.json" unless lock["commit"] == upstream_commit
  else
    stale << "upstream.lock.json"
  end

  unless stale.empty?
    warn "Catalogue sync is stale:"
    stale.each { |path| warn "- #{path}" }
    exit 1
  end

  puts "Catalogue references are current at #{upstream_commit}"
  exit 0
end

generated_files = MAPPINGS.map { |_, destination, _| destination }
existing_lock = File.file?(lock_path) ? JSON.parse(File.read(lock_path)) : nil
lock = if existing_lock && existing_lock["commit"] == upstream_commit && existing_lock["generated_files"] == generated_files
  existing_lock
else
  {
    "repository" => UPSTREAM_REPOSITORY,
    "branch" => UPSTREAM_BRANCH,
    "commit" => upstream_commit,
    "synced_at" => Time.now.utc.iso8601,
    "generated_files" => generated_files
  }
end
File.write(lock_path, "#{JSON.pretty_generate(lock)}\n")

puts "Synced #{MAPPINGS.count} generated files from #{UPSTREAM_REPOSITORY}@#{upstream_commit}"
