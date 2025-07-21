/// A wildcard state that matches any other state.
///
/// Used internally by the [StateMachine] to allow transitions
/// from or to any state when registering transitions.
///
/// Typically used as the default `from` state in [StateTransition].
final class AnyState<T> extends State<T> {
  const AnyState();
}

/// Represents a generic state for use in a [StateMachine].
///
/// Subclasses should override lifecycle methods to define behavior:
/// - [onEnter]: called when entering this state.
/// - [onExit]: called when exiting this state.
/// - [onUpdate]: called every update tick while in this state.
///
/// The type parameter [T] represents the owner object that the state controls,
/// typically a Flame component or game entity.
abstract class State<T> {
  const State();

  /// Called when this state is entered.
  ///
  /// [owner] is the state machine's owner.
  /// [from] is the previous state (if any).
  void onEnter(T owner, [State<T>? from]) {}

  /// Called when this state is exited.
  ///
  /// [owner] is the state machine's owner.
  /// [to] is the next state (if any).
  void onExit(T owner, [State<T>? to]) {}

  /// Called on every update tick while this state is active.
  ///
  /// [dt] is the delta time since last update.
  /// [owner] is the state machine's owner.
  void onUpdate(double dt, T owner) {}
}
