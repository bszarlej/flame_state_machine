import 'package:flame_state_machine/flame_state_machine.dart';

/// A matcher used by the state machine to determine whether a transition
/// is valid based on the current state.
///
/// Different implementations define different matching strategies:
/// - [AnyStateMatch]: matches any state
/// - [ExactStateMatch]: matches a specific state instance
abstract class StateMatch<T> {
  const StateMatch();

  /// Creates a matcher that matches any state.
  static StateMatch<T> any<T>() => AnyStateMatch<T>();

  /// Creates a matcher that matches a specific state instance.
  ///
  /// Uses identity comparison (`identical`) to ensure exact instance matching.
  static StateMatch<T> exact<T>(State<T> state) => ExactStateMatch<T>(state);

  /// Determines whether the given [state] matches this matcher.
  ///
  /// Used internally by the state machine to evaluate whether a transition
  /// should be considered for execution.
  bool matches(State<T> state);
}

/// Matches any state unconditionally.
///
/// This is typically used for global transitions that should be evaluated
/// regardless of the current state.
final class AnyStateMatch<T> extends StateMatch<T> {
  const AnyStateMatch();

  @override
  bool matches(State<T> state) => true;
}

/// Matches a specific state instance using identity comparison.
///
/// This ensures the transition only applies when the exact same state
/// instance is active.
final class ExactStateMatch<T> extends StateMatch<T> {
  const ExactStateMatch(this._state);

  /// The specific state instance to match against.
  final State<T> _state;

  @override
  bool matches(State<T> state) => identical(state, _state);
}
