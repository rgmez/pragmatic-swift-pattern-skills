---
name: implement-swift-design-pattern
description: Implement an evidence-backed design-pattern decision in Swift with the smallest useful representation and behavioral tests. Use after a concrete app requirement has earned one named pattern; not for choosing a pattern, teaching generic definitions, or adding speculative architecture.
license: MIT
---

# Implement Swift Design Pattern

Turn one justified responsibility boundary into minimal Swift code and executable evidence. The goal is not to reproduce a textbook participant diagram.

## Entry gate

Require a concrete current requirement, a direct Swift baseline, its named failure mode, and one pattern verdict. If any is missing, read [evidence-gate.md](references/evidence-gate.md) and return `no pattern yet` or `insufficient evidence` instead of inventing pressure. Stop before implementation when error vocabulary, cancellation, ownership, or another behavior that changes the boundary is unspecified; name the missing contract precisely.

Do not implement a named pattern merely because the user requested its name when the supplied requirements contradict its intent. Explain the mismatch and preserve the direct solution unless the user changes the requirement.

## Workflow

1. **Lock observable behavior.** Identify inputs, outputs, errors, ordering, ownership, lifetime, isolation, and cancellation that must remain stable.
2. **Preserve the direct baseline.** Keep it visible in tests, documentation, or history. Do not maintain two competing production architectures without a consumer.
3. **Choose the smallest Swift representation.** Read [swift-representations.md](references/swift-representations.md) only when the encoding is not obvious. Read the synced [decision matrix](references/decision-matrix.md) when pattern-specific semantics are material. Prefer a canonical guide already present in the target repository; use the commit-pinned remote link only when no local guide exists and network access is available.
4. **Write boundary tests.** Prove the pressure that earned the pattern, the moved responsibility, and failure behavior. Test the closest alternative's losing condition only when it is behaviorally observable; use API/source review for dependency direction, visibility, and type leakage instead of brittle meta-tests.
5. **Implement one boundary.** Add the minimum types needed for immediate variation, an external dependency, shared identity, state ownership, or a test seam.
6. **Review the cost.** Count new types, indirection, state, allocation, ordering, lifecycle, and maintenance rules. Remove ceremonial participants.
7. **Verify reversal.** Name the future requirement that would justify returning to the direct design or moving to different infrastructure, and confirm unrelated callers have not adopted the boundary without the same pressure.

## Swift representation rules

- Prefer a function or closure when behavior is local, stateless, and selected directly.
- Prefer an enum or value type when the variation is closed and exhaustiveness is useful.
- Introduce a protocol only when an external boundary needs a named multi-operation contract, multiple clients depend on the same contract, conformers own lifecycle, or substitution cannot stay function-shaped. Prefer one injected closure for one local operation even when two implementations exist. Keep either boundary at the narrowest useful visibility; an external dependency does not automatically require a public protocol.
- Use an actor for shared mutable state that crosses concurrency domains; actor isolation does not create shared identity by itself.
- Use a reference type when identity, shared lifetime, or subtype dispatch is part of the requirement.
- Use inheritance only when a fixed algorithm genuinely owns a narrow overridable step and composition is less clear.
- Keep native APIs such as Observation, `AsyncSequence`, `URLComponents`, Codable, collections, and platform caches visible when they already own the mechanics.

When adapting callback SDKs to async/await, read [callback-to-async-boundary.md](references/callback-to-async-boundary.md). Do not invent cancellation or multi-callback guarantees the SDK does not provide.

## Tests

Use the repository's existing test framework and organization. Prefer behavior-focused tests over assertions about participant type names.

At minimum, verify:

- the current pressure or invalid state;
- the pattern boundary's observable improvement;
- success and failure behavior;
- ownership, ordering, cancellation, or isolation where relevant; and
- the direct alternative or reversal condition when executable.

Read [implementation-checklist.md](references/implementation-checklist.md) before closing a substantial change.

## Boundaries

- Do not add repositories, coordinators, use cases, factories, registries, dependency containers, or generic frameworks unless the same current requirement independently earns them.
- Do not publish, push, open a PR, or modify external systems unless the user authorizes that workflow.
- Do not generate editorial visuals or long-form teaching material unless requested; use `teach-swift-design-pattern` for that deliverable.
- Do not broaden a small example with networking, persistence, UI, or concurrency merely to make the pattern appear realistic.

## Response contract

Report the observed pressure, direct baseline, implemented boundary, representation choice, tests, cost, closest alternative, and reconsideration signal. If the evidence gate fails, report that outcome and stop without pattern code. If the pattern verdict is sound but the implementation contract is incomplete, return `insufficient implementation contract`, list only the missing behavioral facts, and do not produce provisional code.
