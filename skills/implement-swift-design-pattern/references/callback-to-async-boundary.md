# Callback-to-Async Boundary

Use this reference when an Adapter or another external boundary converts callback APIs into Swift concurrency.

## Required contract

Confirm before implementation:

- whether the callback fires exactly once, at most once, or may stream values;
- whether success and failure can both arrive;
- which queue or executor invokes the callback;
- whether the operation can be cancelled and how cancellation is signalled;
- whether the SDK retains the callback or request token; and
- which vendor errors map to app-owned retryable, terminal, cancellation, or malformed-response outcomes.

Return `insufficient implementation contract` when the pattern verdict is already justified but these SDK facts are not available.

## Continuations

Use `withCheckedThrowingContinuation` only when the SDK guarantees exactly one callback on every terminal path. An `at most once` callback can still never arrive and leave the task suspended. A callback that may emit repeatedly belongs behind `AsyncStream` or another explicit streaming boundary instead.

Do not add a timeout merely because the SDK might never call back; timeout behavior is a product/integration requirement with its own cancellation and error semantics.

## Cancellation

Task cancellation has no automatic effect on a checked continuation. Propagate cancellation when the SDK exposes a real cancellation token or operation. If the app requires early cancellation without vendor support, specify and test an app-owned policy plus exact-once synchronization between cancellation and a late callback; do not improvise that policy inside the adapter.

## Tests

- success maps to one app-owned value;
- each documented terminal vendor error maps correctly;
- callbacks guaranteed exactly once resume one continuation; repeated values use `AsyncStream`, while first-result-wins behavior requires an explicit app-owned policy and exact-once synchronization;
- cancellation is tested only when a real cancellation mechanism exists; and
- vendor types do not cross the adapter's app-facing signature.
