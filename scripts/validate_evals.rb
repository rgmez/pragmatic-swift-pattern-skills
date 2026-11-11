#!/usr/bin/env ruby

require "json"
require "set"

ROOT = File.expand_path("..", __dir__)
EVAL_PATH = File.join(ROOT, "evals", "cases.json")
EXPECTED_SKILLS = %w[
  audit-swift-pattern-catalogue
  choose-swift-design-pattern
  implement-swift-design-pattern
  teach-swift-design-pattern
].freeze
EXPECTED_FIELDS = %w[id skill mode prompt expected_outcome must_observe must_not].freeze
EXPECTED_MODES = %w[normal safety_stop].freeze

errors = []

begin
  document = JSON.parse(File.read(EVAL_PATH))
rescue StandardError => error
  warn "evals/cases.json: #{error.message}"
  exit 1
end

errors << "schema_version must be the string 1.0" unless document["schema_version"] == "1.0"
cases = document["cases"]
errors << "cases must be an array" unless cases.is_a?(Array)
cases = [] unless cases.is_a?(Array)
errors << "expected exactly 8 evaluation cases, found #{cases.count}" unless cases.count == 8

ids = Set.new
coverage = Hash.new { |hash, key| hash[key] = [] }

cases.each_with_index do |evaluation, index|
  label = "cases[#{index}]"
  unless evaluation.is_a?(Hash)
    errors << "#{label} must be an object"
    next
  end

  missing = EXPECTED_FIELDS - evaluation.keys
  unknown = evaluation.keys - EXPECTED_FIELDS
  errors << "#{label} missing fields: #{missing.join(", ")}" unless missing.empty?
  errors << "#{label} has unknown fields: #{unknown.join(", ")}" unless unknown.empty?

  id = evaluation["id"]
  if !id.is_a?(String) || !id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    errors << "#{label} id must be unique kebab-case"
  elsif ids.include?(id)
    errors << "duplicate evaluation id: #{id}"
  else
    ids << id
  end

  skill = evaluation["skill"]
  mode = evaluation["mode"]
  errors << "#{label} has unknown skill: #{skill.inspect}" unless EXPECTED_SKILLS.include?(skill)
  errors << "#{label} has unknown mode: #{mode.inspect}" unless EXPECTED_MODES.include?(mode)
  coverage[skill] << mode if EXPECTED_SKILLS.include?(skill) && EXPECTED_MODES.include?(mode)

  prompt = evaluation["prompt"]
  errors << "#{label} prompt must be a self-contained string" unless prompt.is_a?(String) && prompt.length >= 80

  expected_outcome = evaluation["expected_outcome"]
  errors << "#{label} expected_outcome must be a meaningful string" unless expected_outcome.is_a?(String) && expected_outcome.length >= 40

  { "must_observe" => 3, "must_not" => 2 }.each do |field, minimum|
    values = evaluation[field]
    valid = values.is_a?(Array) && values.count >= minimum && values.uniq.count == values.count && values.all? { |value| value.is_a?(String) && value.length >= 12 }
    errors << "#{label} #{field} must contain at least #{minimum} unique semantic checks" unless valid
  end
end

EXPECTED_SKILLS.each do |skill|
  errors << "#{skill} must have one normal and one safety_stop case" unless coverage[skill].sort == EXPECTED_MODES.sort
end

unless errors.empty?
  warn errors.join("\n")
  exit 1
end

puts "Evaluation schema validation passed"
puts "  cases: #{cases.count}"
puts "  skills: #{EXPECTED_SKILLS.count}"
puts "  modes per skill: normal, safety_stop"
