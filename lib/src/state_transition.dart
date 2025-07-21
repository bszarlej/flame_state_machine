import 'state.dart';

/// A guard function that determines whether a transition should occur.
///
/// Takes the [owner] of type [T] and returns `true` if the transition
/// is allowed to proceed.
typedef Guard<T> = bool Function(T owner);

/// Represents a transition from one [State] to another.
///
/// Contains:
/// - [priority]: Higher priority transitions are evaluated first (default 1).
/// - [from]: The originating state. Defaults to [AnyState], which matches any state.
/// - [to]: The target state (required).
/// - [guard]: A function that returns `true` when the transition can be triggered (required).
class StateTransition<T> {
  /// The priority of this transition, higher values are checked before lower.
  final int priority;

  /// The state from which this transition originates.
  ///
  /// Defaults to [AnyState], meaning it matches transitions from any state.
  final State<T> from;

  /// The state to transition to.
  final State<T> to;

  /// The guard function that decides if this transition should trigger.
  final Guard<T> guard;

  /// Creates a [StateTransition].
  ///
  /// [to] and [guard] are required.
  /// If [from] is omitted, it defaults to [AnyState].
  /// [priority] defaults to 1.
  StateTransition({
    this.priority = 1,
    this.from = const AnyState(),
    required this.to,
    required this.guard,
  });
}
