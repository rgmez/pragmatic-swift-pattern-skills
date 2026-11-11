# Reusable Evaluations

This suite contains eight contractual cases that check whether the four skills preserve their entry gates, decisions, and safety boundaries.

Schema validation confirms that `evals/cases.json` is valid JSON, declares schema version `1.0`, contains exactly eight cases, and satisfies the required fields and cardinalities.

Real host evaluation requires running each prompt with the named skill and reviewing the response against `expected_outcome`, `must_observe`, and `must_not`; schema validation does not prove that a host reasoned correctly.

From the repository root, run `ruby scripts/validate_evals.rb`.

For a manual evaluation, first confirm that the prompt is self-contained, then compare the verdict with `expected_outcome`, verify every `must_observe` invariant, and look for any forbidden `must_not` behavior.

For `safety_stop` cases, also verify that the response stops before implementation, editing, mutation, or publication when the named contract or evidence is missing.

Codex, Claude Code, Cursor, and GitHub Copilot may interpret instructions differently, so record results per host and review semantic behavior rather than fragile word matches.
