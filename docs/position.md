# Our Position on Design Patterns

We are strongly in favor of design patterns.

We are equally opposed to using their names as permission for speculative architecture.

## What a pattern is for

A pattern gives a team shared vocabulary for a responsibility boundary that has already become difficult to own. It should reduce a verified problem: coupling, invalid state, duplicated ownership, lifecycle risk, repeated dispatch, or measured resource cost.

The value is not the participant diagram. The value is knowing what changes, who should own that change, and which alternatives lose.

## What must happen first

Start with the smallest Swift or platform solution that satisfies the current requirement: a value, enum, function, initializer, closure, actor, Observation model, `AsyncSequence`, collection operation, or native framework API.

Introduce a pattern only when:

1. A current requirement creates observable pressure.
2. The direct baseline has a named failure mode.
3. The pattern moves responsibility to a better owner.
4. Tests, ownership rules, types, or measurements verify the improvement.

## Successful outcomes

- **Use one pattern:** the evidence gate passes and one boundary is clearer.
- **No pattern yet:** direct Swift handles the current requirement with less indirection.
- **Insufficient evidence:** one missing fact would materially change the decision.

All three are successful engineering outcomes.

## What we refuse

- Pattern quotas.
- Class hierarchies copied from diagrams without Swift-specific justification.
- Protocols with one implementation and no external boundary or test seam.
- Repositories, coordinators, factories, dependency containers, or use cases added as architectural decoration.
- Invented future requirements used to defend current complexity.
- Teaching examples that hide costs, alternatives, or the condition that removes the pattern.

## Swift representation

The pattern chooses where responsibility belongs. Swift chooses how to encode it. A Strategy can be a captured function, State can retain a persisted enum, Observer can use `AsyncStream`, Iterator can be an `AsyncSequence`, and a process identity can combine an actor with narrow shared lookup.

Choose representation after the responsibility boundary is earned.
