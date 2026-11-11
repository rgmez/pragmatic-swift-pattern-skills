---
name: audit-swift-pattern-catalogue
description: Audit a Swift design-pattern catalogue for usefulness, classification, overengineering, executable evidence, documentation quality, and release readiness. Use for multi-pattern repositories or teaching collections; not for choosing one pattern for one feature or implementing fixes unless explicitly requested.
license: MIT
---

# Audit Swift Pattern Catalogue

Review the catalogue as a decision system. Pattern coverage is not proof of design quality.

## Scope

Inventory canonical examples, historical sketches, missing patterns, direct baselines, pressure evidence, final implementations, tests, guides, diagrams, visuals, and status links. Distinguish current source of truth from preserved history.

For one feature-level pattern decision, use `choose-swift-design-pattern` instead.

## Audit workflow

1. **Establish the catalogue boundary.** Record expected patterns, canonical guides, executable examples, and explicit no-pattern cases.
2. **Evaluate usefulness.** For each example, apply the [example-quality checklist](references/example-quality-checklist.md) and classify it as `useful`, `useful with reservations`, `misclassified`, `unearned`, or `insufficient evidence`.
3. **Check neighbours.** Read [catalogue guidance](references/catalogue-guidance.md) for commonly confused patterns and compare by ownership/change boundary rather than diagram shape.
4. **Inspect implementation evidence.** Verify the direct baseline, measured pressure, minimal public API, tests, ownership, lifetime, isolation, ordering, and errors.
5. **Inspect teaching evidence.** Verify standalone problem framing, quick decision summary, walkthrough, diagram, run/tests, trade-offs, alternatives, `When not to use it`, and source map.
6. **Check system consistency.** Validate links, Mermaid fences, assets, category indexes, historical labels, private/ignored material, and release claims.
7. **Report release readiness.** Separate blocking defects from tooling limitations and optional polish.

Read the synced [catalogue review](references/catalogue-review.md) when a complete GoF comparison or baseline example is useful. Read [hardening review](references/hardening-review.md) for examples of narrowing claims without adding architecture.

Use classifications consistently:

- `useful`: the evidence gate passes and the implementation plus teaching contract are complete.
- `useful with reservations`: the boundary is earned, but one documented limitation materially narrows transfer to real apps.
- `misclassified`: the implementation demonstrates a different named responsibility boundary.
- `unearned`: the named pattern shape is recognizable, but direct Swift still solves the current requirements with less cost.
- `insufficient evidence`: one missing fact could change the classification.

## Findings

Prioritize findings by impact:

- **P0:** behavior, safety, or published evidence is materially false.
- **P1:** example is misclassified, unearned, non-executable, or teaches a dangerous ownership/lifecycle rule.
- **P2:** documentation, navigation, accessibility, or maintainability reduces learning quality without changing behavior.

Give each finding an exact file or symbol, current evidence, consequence, minimal correction, and verification step. Do not inflate counts with generic praise or style preferences.

## Optional deterministic checks

If the target repository matches the pragmatic catalogue layout, run the bundled `scripts/validate_catalogue_readmes.rb --root <path> --expected-count 23`. Otherwise inspect it for applicable checks rather than forcing its path assumptions onto another repository.

Run the target's warning-as-error build and relevant tests when available. Treat a missing renderer, package manager, simulator, or host validator as a named limitation rather than a fabricated pass.

## Boundaries

- An audit request authorizes inspection and reporting, not code changes, branch deletion, publishing, or release operations.
- Do not require all examples to share a runtime framework, participant protocol, dependency container, or test superclass.
- Do not count historical sketches as canonical coverage.
- Do not accept a pattern merely because its participant names or class diagram look familiar.
- A direct Swift or platform solution is a successful catalogue outcome.

## Response contract

Lead with blocking findings, then provide the per-pattern decision matrix, systemic strengths and risks, validation results, known limits, and a prioritized remediation plan. If no actionable defects remain, say so explicitly and identify only real residual risks.
