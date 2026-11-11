# Swift Representation Guide

Choose representation after the responsibility boundary is justified.

| Pressure | Prefer first | Escalate when |
| --- | --- | --- |
| Local stateless behavior | Function or `@Sendable` closure | Behavior needs a named policy, captured inputs, or independent lifecycle. |
| Closed alternatives | Enum plus exhaustive switch | Cases grow independently or ownership no longer belongs to one switch. |
| External contract | Protocol at the integration edge | Never add another protocol merely to wrap the protocol. |
| Shared mutable state | Actor | Multiple identities are valid; add Singleton only for proven process identity pressure. |
| Lifecycle transitions | Enum reducer | Several behavior families change together with the current phase. |
| Lazy ordered values | `Sequence` or `AsyncSequence` | Cursor, cancellation, or production policy needs a dedicated iterator owner. |
| Staged construction | Throwing initializer | Partial construction has ordered validation or privacy state. |
| Fixed algorithm with one variation | Private higher-order function | A closed nominal family benefits from one final template operation. |
| Stable element family, growing operations | Exhaustive enum switches | Repeated concrete dispatch dominates and element kinds remain stable. |

## Protocol test

Before creating a protocol, identify at least one:

- external system the app does not control;
- immediate second implementation;
- composition-root substitution required by the product; or
- test seam around a nondeterministic external boundary.

Mocking convenience alone does not justify a public protocol.

Prefer a closure when the app-owned boundary has one function-shaped operation and local injection is sufficient, including when a composition root selects between two implementations. Prefer a narrow internal protocol when the boundary has several cohesive operations, multiple clients need one named contract, or conformers own lifecycle/state that a closure would obscure.

## Concurrency test

Name the isolation domain and the state it protects. `@MainActor` is for UI-owned state, not a general warning suppressor. `Sendable` describes safe transfer; it does not serialize mutation. An actor serializes one identity; it does not ensure every construction root uses that identity.

## Value/reference test

Prefer values for independent snapshots, requests, policies, and closed state. Use references when shared identity or mutable lifetime is the requirement. Measure copy or allocation pressure before replacing value semantics with object sharing.
