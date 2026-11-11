# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Swift and Apple-platform developers who use coding agents to make, implement, teach, or review design-pattern decisions. Secondary users are maintainers of public pattern catalogues and engineering educators.

## Product Purpose

Provide portable Agent Skills that preserve one evidence-first position: design patterns are valuable when they move verified pressure to a better owner, and harmful when their name is used to justify speculative architecture.

Success means an agent can choose direct Swift, implement one minimal pattern boundary, explain it honestly, and audit a catalogue without maximizing pattern usage.

## Positioning

This is not a pattern encyclopedia or code generator. The skills are derived from executable app scenarios, negative cases, neighbour comparisons, tests, measurements, and release QA in `rgmez/Design-Patterns-in-Swift`.

## Operating Context

The canonical packages live under `skills/` and follow the shared Agent Skills format. Users install them from GitHub through the skills CLI or copy a complete skill directory. A scheduled GitHub workflow checks the upstream pattern repository and opens a reviewable synchronization PR when its evidence changes.

## Capabilities and Constraints

- Four responsibilities: choose, implement, teach, and audit.
- Shared behavior must remain portable across Codex, Claude Code, Cursor, GitHub Copilot, and compatible agents.
- Generated evidence references may update automatically; human-authored skill instructions never auto-merge.
- External mutations, publication, deletion, branch changes, and releases retain the host's normal authorization boundaries.
- The upstream Swift catalogue remains the evidence source; this repository is the skill distribution source.

## Brand Commitments

Use the existing RG matte-charcoal, white, muted-gray, red, and warm-orange visual system. Preserve the original logo when used. The voice is technically direct, skeptical of ceremony, strongly pro-pattern when evidence earns one, and explicit about costs and reversal.

## Evidence on Hand

- `rgmez/Design-Patterns-in-Swift` contains 23 canonical GoF guides, one no-pattern case, 359 tests in 194 suites, decision matrices, hardening reviews, README contracts, diagrams, and release evidence.
- The existing `choose-swift-design-pattern` skill passed independent forward scenarios before extraction into this repository.
- No customer testimonials, adoption metrics, or cross-agent behavioral claims exist yet; documentation must not fabricate them.

## Product Principles

- Direct Swift first.
- Evidence before abstraction.
- Responsibility boundaries over class-diagram mimicry.
- Costs, alternatives, and reversal are part of the result.
- Automation proposes evidence updates through PRs; people review meaning.

## Accessibility & Inclusion

README content must work in GitHub light and dark modes, use semantic headings, descriptive alt text, accessible Mermaid explanations, mobile-readable tables, and one logical source line per prose paragraph or list item.
