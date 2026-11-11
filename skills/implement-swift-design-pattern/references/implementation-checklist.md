# Implementation Checklist

## Evidence

- [ ] The requirement exists now.
- [ ] The direct baseline is implemented or precisely documented.
- [ ] Its failure mode is observable.
- [ ] The chosen pattern moves one named responsibility.
- [ ] The closest alternative loses for a concrete reason.

## Swift design

- [ ] The public API exposes the domain variation, not GoF participant names.
- [ ] Value/reference semantics and identity are deliberate.
- [ ] Protocols have an external boundary, test seam, or immediate variation.
- [ ] State, ownership, lifetime, ordering, errors, and cancellation are explicit where relevant.
- [ ] No unrelated architecture layer was added.

## Tests

- [ ] Acceptance behavior and failure behavior are covered.
- [ ] The pressure that earned the pattern is executable when practical.
- [ ] Tests remain isolated and parallel-safe.
- [ ] Assertions verify behavior or invariants rather than type count.
- [ ] Warning-as-error build and relevant suites pass.

## Closeout

- [ ] Added complexity and maintenance cost are recorded.
- [ ] A reversal condition is named.
- [ ] Comparative code without a consumer was removed or confined to tests/history.
- [ ] The complete diff contains no unrelated files or generated debris.
