import 'package:flame_state_machine/src/state.dart';
import 'package:flutter/foundation.dart';

/// A guard function that determines whether a transition should occur.
///
/// Takes the [owner] of type [T] and returns `true` if the transition
/// is allowed to proceed.
typedef Guard<T> = bool Function(T owner);

/// Represents a transition rule between two [State]s in the state machine.
///
/// A transition defines:
/// - a source state (`from`)
/// - a target state (`to`)
/// - a `guard` function that controls when the transition is allowed
/// - a `priority` used to resolve conflicts when multiple transitions match
///
/// Transitions are evaluated by the state machine in descending priority order.
/// The first valid transition is executed during an update cycle.
///
///
/// ### Matching behavior
/// - If [from] is `null`, the transition is considered **global**
///   and can trigger from any current state.
/// - Otherwise, the transition only applies when the current state matches [from].
///
///
/// ### Global convenience constructor
/// [StateTransition.global] is a shorthand for creating a transition
/// that applies from any state.
///
///
/// ### Example
/// ```dart
/// StateTransition<Player>(
///   from: idleState,
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
///
/// Key points:
/// - Higher `priority` transitions are evaluated first.
/// - Only one transition can trigger per update cycle.
/// - `from == null` means "match any state".
/// - Transitions are pure data; no side effects should be defined here.
@immutable
class StateTransition<T> {
  /// Creates a [StateTransition].
  ///
  /// [to] is the target state of the transition.
  /// [guard] determines whether the transition is allowed.
  /// [from] defines the source state; if omitted or `null`, the transition
  /// can occur from any state.
  /// [priority] determines evaluation order (higher runs first).
  const StateTransition({
    this.priority = 1,
    this.from,
    required this.to,
    required this.guard,
  });

  /// Creates a global transition that can trigger from any state.
  ///
  /// This is equivalent to setting [from] to `null`.
  ///
  /// [to] is the target state of the transition.
  /// [guard] determines whether the transition is allowed.
  /// [priority] determines evaluation order (higher runs first).
  const StateTransition.global({
    this.priority = 1,
    required this.to,
    required this.guard,
  }) : from = null;

  /// The priority of this transition.
  ///
  /// Higher values are evaluated before lower values when multiple
  /// transitions are eligible. Defaults to `1`.
  final int priority;

  /// The source state required for this transition to match.
  ///
  /// If `null`, this transition is considered global and can trigger
  /// from any current state.
  final State<T>? from;

  /// The target state that will be entered when this transition fires.
  final State<T> to;

  /// The condition that determines whether this transition is allowed.
  ///
  /// If this returns `true`, the transition may be executed (depending on
  /// priority and other matching transitions).
  final Guard<T> guard;
}
