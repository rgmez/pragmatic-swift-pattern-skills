# Agent Guidance

## Repository purpose

This repository distributes four portable Agent Skills for evidence-led Swift design-pattern work. Preserve the position in `docs/position.md`: direct Swift first, patterns when verified pressure earns them, and no pattern as a successful result.

## Skill routing

- Use `choose-swift-design-pattern` for one feature-level decision or review.
- Use `implement-swift-design-pattern` only after one pattern boundary is evidence-backed.
- Use `teach-swift-design-pattern` only from verified code and tests.
- Use `audit-swift-pattern-catalogue` for multi-pattern repositories and release readiness.

Do not merge all responsibilities into one catch-all skill. For an end-to-end request, complete each boundary in order and preserve the stop conditions of the previous skill.

## Generated evidence

Files whose first line says `Generated from rgmez/Design-Patterns-in-Swift@...` are synchronized artifacts. Never edit them manually.

Update generated evidence with:

```sh
ruby scripts/sync_from_catalogue.rb --source /path/to/Design-Patterns-in-Swift
```

The scheduled workflow may open a synchronization pull request. It must never auto-merge evidence changes into human-authored skill instructions.

## Validation

Run before closing a change:

```sh
ruby scripts/validate_skills.rb
ruby scripts/validate_evals.rb
ruby scripts/sync_from_catalogue.rb --source /path/to/Design-Patterns-in-Swift --check
```

For distribution changes, also run the documented `npx skills` discovery and temporary installation smoke test with telemetry disabled.

## Editing rules

- Keep shared behavior inside each canonical `skills/<name>/` package.
- Keep provider-specific UI metadata under `agents/`; shared behavior must not depend on it.
- Keep public instructions free of personal paths, secrets, private URLs, customer data, and local-only assumptions.
- Require explicit authorization before external publication, destructive actions, branch changes, or release operations.
- Preserve one logical source line per prose paragraph or list item in human README files.

## Commits

Use English subjects with `New:`, `Fix:`, or `Update:` and describe the verified result.
