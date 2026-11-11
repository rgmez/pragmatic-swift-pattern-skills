# Validation Record

Validation is evidence, not a compatibility slogan.

Last verified: 2026-11-11.

## Current verified surfaces

| Surface | Evidence | Result |
| --- | --- | --- |
| Skill packages | Official `quick_validate.py` from Codex skill creator | Four valid skills |
| Shared specification | Agent Skills reference `skills-ref` at `83021e2` | Four valid skills |
| Repository contract | `ruby scripts/validate_skills.rb` | Metadata, links, provenance, and README policy passed |
| Evaluation contract | `ruby scripts/validate_evals.rb` | Eight cases covering one normal and one safety-stop path per skill |
| Host UI assets | XML parsing, accessibility checks, and 128/512 px renders | Eight semantic SVG icons remain legible at their intended sizes |
| Upstream evidence | `ruby scripts/sync_from_catalogue.rb --check` | Generated references follow the latest allowlisted evidence commit; unrelated upstream commits create no churn |
| Catalogue quality | `validate_catalogue_readmes.rb` against the source repository | 23 canonical guides, 1,175 local links, and 51 Mermaid blocks passed |
| Remote CLI discovery | `skills@1.8.1 add rgmez/pragmatic-swift-pattern-skills --list` | Four skills discovered from GitHub |
| Installation parity | Clean temporary project with explicit agent targets and directory comparison | Codex, Claude Code, Cursor, and GitHub Copilot received complete copies of all four skills |

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
