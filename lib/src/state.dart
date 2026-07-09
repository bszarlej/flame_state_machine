import 'package:flame/extensions.dart';

/// Represents a generic state for use in a [StateMachine].
///
/// A state defines the behavior of an owner object while it is active.
/// Subclasses should override lifecycle methods to implement state-specific
/// logic:
/// - [onEnter]: called when entering this state.
/// - [onUpdate]: called every update tick while this state is active.
/// - [onRender]: called every render tick while this state is active.
/// - [onRenderDebugMode]: called when debug rendering is enabled while this
/// - [onExit]: called when leaving this state.
///   state is active.
///
/// States can be used to manage behavior, animations, timers, effects,
/// input handling, or any other logic that belongs to a specific state.
///
/// The type parameter [T] represents the owner object that the state controls,
/// typically a Flame component or game entity.
abstract class State<T> {
  const State();

  /// Called when this state is entered.
  ///
  /// - [owner] is the state machine's owner.
  /// - [prev] is the previous state (if any).
  void onEnter(T owner, State<T>? prev) {}

  /// Called on every update tick while this state is active.
  ///
  /// - [dt] is the delta time since last update.
  /// - [owner] is the state machine's owner.
  void onUpdate(T owner, double dt) {}

  /// Called on every render tick while this state is active.
  ///
  /// Use this method to draw state-specific visuals.
  ///
  /// - [owner] is the component or object that owns this state machine.
  /// - [canvas] is the canvas to draw on.
  void onRender(T owner, Canvas canvas) {}

  /// Called when the game is rendered in debug mode.
  ///
  /// This method allows a state to draw debug-only visuals while it is active.
  /// It is only called when the parent component's debug rendering is enabled.
  ///
  /// Common uses include drawing hitboxes, navigation paths, detection ranges,
  /// state information, or other development-only visualizations.
  ///
  /// - [owner] is the object controlled by the state machine.
  /// - [canvas] is the canvas used for debug rendering.
  void onRenderDebugMode(T owner, Canvas canvas) {}

  /// Called when this state is exited.
  ///
  /// - [owner] is the state machine's owner.
  /// - [next] is the next state.
  void onExit(T owner, State<T> next) {}
}
