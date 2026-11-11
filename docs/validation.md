# Validation Record

Validation is evidence, not a compatibility slogan.

## Current verified surfaces

| Surface | Evidence | Result |
| --- | --- | --- |
| Skill packages | Official `quick_validate.py` from Codex skill creator | Four valid skills |
| Repository contract | `ruby scripts/validate_skills.rb` | Metadata, links, provenance, and README policy passed |
| Upstream evidence | `ruby scripts/sync_from_catalogue.rb --check` | Generated references match the locked catalogue commit |
| Catalogue quality | `validate_catalogue_readmes.rb` against the source repository | 23 canonical guides, 1,175 local links, and 51 Mermaid blocks passed |
| CLI discovery | `skills@1.7.2 add . --list` | Four skills discovered |
| Installation | Clean temporary project with explicit agent targets | Codex, Claude Code, Cursor, and GitHub Copilot received all four skills |

## Behavioral scenarios

The skills were exercised against forward scenarios rather than validated only by headings.

- `choose-swift-design-pattern` kept a direct Swift solution when a second compression preset did not create a runtime variation boundary.
- `implement-swift-design-pattern` stopped on an incomplete callback contract instead of guessing cancellation, callback cardinality, or error behavior.
- `teach-swift-design-pattern` required an explicit reversal signal and treated the RG visual template as catalogue-specific rather than universal.
- `audit-swift-pattern-catalogue` verified anchored headings, one technical Mermaid diagram, one accessible description, and local-link integrity for every canonical guide.

## What this does not prove

- It does not prove that every host version interprets instructions identically.
- It does not replace human review of a generated upstream synchronization pull request.
- It does not guarantee that a pattern is appropriate without concrete app requirements.
- It does not turn installation counts or catalogue completeness into architectural evidence.

Re-run the checks after changes to skill instructions, packaging, synchronization logic, or upstream evidence.
