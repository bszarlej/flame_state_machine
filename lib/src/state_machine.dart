import 'state.dart';
import 'state_transition.dart';

/// A generic finite state machine for managing [State] transitions.
///
/// The [StateMachine] maintains the current and previous states of an owner object of type [T].
/// It allows registering transitions between states guarded by conditions.
///
/// Usage:
/// ```dart
/// final machine = StateMachine<Player>(
///   owner: player,
///   initialState: IdleState(),
/// );
///
/// machine.register(
///   from: IdleState(),
///   to: RunningState(),
///   guard: (player) => player.isMoving,
/// );
///
/// // In your game loop:
/// machine.update(dt);
/// ```
///
/// - The owner is the object controlled by this state machine (e.g., a Flame component).
/// - Transitions can be registered with optional priorities and reversible guards.
/// - Transitions with higher priority are evaluated first.
/// - If `from` is `null` in `register()`, the transition applies from *any* state.
/// - The state lifecycle methods ([onEnter], [onExit], [onUpdate]) are called accordingly.
class StateMachine<T> {
  late T _owner;
  State<T>? _currentState;
  State<T>? _previousState;
  final List<StateTransition<T>> _transitions = [];

  /// Creates a [StateMachine] for the given [owner] and optional [initialState].
  ///
  /// The [initialState], if provided, will be entered immediately.
  StateMachine({required T owner, State<T>? initialState}) {
    _owner = owner;
    setState(initialState);
  }

  /// The current active state.
  State<T>? get currentState => _currentState;

  /// The previous state before the current one.
  State<T>? get previousState => _previousState;

  /// The list of all registered state transitions.
  List<StateTransition<T>> get transitions => _transitions;

  /// Adds a [transition] to the state machine, sorted by priority.
  void addTransition(StateTransition<T> transition) {
    _transitions
      ..add(transition)
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Registers a state transition with optional reverse transition.
  ///
  /// - [from]: The source state, or `null` to match any state.
  /// - [to]: The destination state (required).
  /// - [guard]: Condition function to allow transition (required).
  /// - [priority]: Priority for evaluating this transition (default 1).
  /// - [reverse]: If true, also register reverse transition.
  /// - [reverseGuard]: Guard for reverse transition (defaults to negation of [guard]).
  /// - [reversePriority]: Priority for reverse transition (default 1).
  void register({
    State<T>? from,
    required State<T> to,
    required Guard<T> guard,
    int priority = 1,
    bool reverse = false,
    Guard<T>? reverseGuard,
    int reversePriority = 1,
  }) {
    final fromState = from ?? AnyState<T>();

    final forwardTransition = StateTransition(
      priority: priority,
      from: fromState,
      to: to,
      guard: guard,
    );
    addTransition(forwardTransition);

    if (reverse) {
      final reverseTransition = StateTransition(
        priority: reversePriority,
        from: to,
        to: fromState,
        guard: reverseGuard ?? (owner) => !guard(owner as T),
      );
      addTransition(reverseTransition);
    }
  }

  /// Sets the current state immediately and calls its [onEnter] method.
  void setState(State<T>? state) {
    _currentState = state;
    _currentState?.onEnter(_owner);
  }

  /// Updates the state machine, evaluating transitions and updating the current state.
  ///
  /// This should be called once per frame with the elapsed [dt].
  void update(double dt) {
    final applicableTransitions = _transitions.where(
      (t) => t.from == _currentState || t.from is AnyState<T>,
    );

    for (final transition in applicableTransitions) {
      if (transition.to == _currentState || !transition.guard(_owner)) continue;

      _currentState?.onExit(_owner, transition.to);

      if (transition.to is AnyState<T>) {
        final oldState = _currentState;
        _currentState = _previousState?..onEnter(_owner, oldState);
      } else {
        _previousState = _currentState;
        _currentState = transition.to..onEnter(_owner, _previousState);
      }

      break;
    }

    _currentState?.onUpdate(dt, _owner);
  }
}
