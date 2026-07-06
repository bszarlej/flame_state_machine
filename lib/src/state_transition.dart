import 'package:flame_state_machine/src/state.dart';
import 'package:flame_state_machine/src/state_match.dart';
import 'package:flutter/foundation.dart';

/// A guard function that determines whether a transition should occur.
///
/// Takes the [owner] of type [T] and returns `true` if the transition
/// is allowed to proceed.
typedef Guard<T> = bool Function(T owner);

/// Represents a transition rule between two [State]s in the state machine.
///
/// A transition defines:
/// - a state matcher ([match]) that determines when the transition applies
/// - a target state (`to`)
/// - a `guard` function that controls when the transition is allowed
/// - a `priority` used to resolve conflicts when multiple transitions match
///
/// Transitions are evaluated by the state machine in descending priority order.
/// The first transition whose [match] matches the current state and whose
/// [guard] returns `true` is executed during an update cycle.
///
///
/// ### Matching behavior
/// The [match] determines which current states can trigger this transition.
///
/// Common matchers include:
/// - [ExactStateMatch] to match a specific state instance.
/// - [TypeStateMatch] to match any state of a given type.
/// - [AnyStateMatch] to match every state.
///
///
/// ### Global convenience constructor
/// [StateTransition.global] is a shorthand for creating a transition whose
/// [match] is an [AnyStateMatch], allowing it to trigger from any state.
///
///
/// ### Example
/// ```dart
/// StateTransition<Player>(
///   match: StateMatch.exact(idleState),
///   to: runningState,
///   guard: (player) => player.isMoving,
/// );
///
/// StateTransition<Player>(
///   match: StateMatch.type<Player, IdleState>(),
///   to: runningState,
///   guard: (player) => player.isMoving,
/// );
///
/// StateTransition<Player>.global(
///   to: idleState,
///   guard: (player) => !player.isMoving,
/// );
/// ```
///
/// Key points:
/// - Higher [priority] transitions are evaluated first.
/// - Only one transition can trigger per update cycle.
/// - The transition applies only if [match] matches the current state.
/// - Transitions are immutable and contain no side effects.
@immutable
class StateTransition<T> {
  /// Creates a [StateTransition].
  ///
  /// [match] determines which current states this transition applies to.
  /// [to] is the target state of the transition.
  /// [guard] determines whether the transition is allowed.
  /// can occur from any state.
  /// [priority] determines evaluation order (higher runs first).
  const StateTransition({
    this.priority = 1,
    required this.match,
    required this.to,
    required this.guard,
  });

  /// Creates a global transition that can trigger from any state.
  ///
  /// This is equivalent to using `match: const AnyStateMatch()`.
  ///
  /// [to] is the target state of the transition.
  /// [guard] determines whether the transition is allowed.
  /// [priority] determines evaluation order (higher runs first).
  static StateTransition<T> global<T>({
    int priority = 1,
    required State<T> to,
    required Guard<T> guard,
  }) {
    return StateTransition<T>(
      priority: priority,
      match: const AnyStateMatch(),
      to: to,
      guard: guard,
    );
  }

  /// The priority of this transition.
  ///
  /// Higher values are evaluated before lower values when multiple
  /// transitions are eligible. Defaults to `1`.
  final int priority;

  /// Determines which current states this transition applies to.
  ///
  /// The transition is considered for execution only if this matcher matches
  /// the current state of the state machine.
  final StateMatch<T> match;

  /// The target state that will be entered when this transition fires.
  final State<T> to;

  /// The condition that determines whether this transition is allowed.
  ///
  /// If this returns `true`, the transition may be executed (depending on
  /// priority and other matching transitions).
  final Guard<T> guard;
}
