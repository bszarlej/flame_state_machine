import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'state.dart';
import 'state_transition.dart';

/// A generic finite state machine for managing [State] transitions.
///
/// The [StateMachine] is a [Component], meaning it can be added to a Flame
/// component tree and its [update] and [render] methods will be called automatically
/// by the game loop. It maintains the current and previous states of an owner object
/// of type [T] and allows registering transitions between states guarded by conditions.
///
/// Usage:
/// ```dart
/// final stateMachine = StateMachine<Player>(
///   owner: player,
///   initialState: IdleState(),
/// );
///
/// stateMachine.register(
///   from: IdleState(),
///   to: RunningState(),
///   guard: (player) => player.isMoving,
/// );
///
/// // Add the state machine to the component tree:
/// add(stateMachine);
/// ```
///
/// Key points:
/// - The owner is the object controlled by this state machine (e.g., a Flame component).
/// - Transitions can be registered with optional priorities and reversible guards.
/// - Transitions with higher priority are evaluated first.
/// - If `from` is `null` in [register], the transition applies from *any* state.
/// - State lifecycle methods ([onEnter], [onExit], [onRender], [onUpdate]) are called appropriately.
class StateMachine<T> extends Component {
  /// A function that is called whenever a state transition occurs.
  /// It receives the [owner], the previous state ([from]), and the new state ([to]).
  /// This can be used for logging, analytics, or triggering side effects.
  void Function(T owner, State<T>? from, State<T>? to)? onTransition;

  late T _owner;
  State<T>? _currentState;
  State<T>? _previousState;
  final List<StateTransition<T>> _transitions = [];

  /// Creates a [StateMachine] for the given [owner] and optional [initialState].
  ///
  /// The [initialState], if provided, will be entered immediately.
  StateMachine({required T owner, State<T>? initialState, this.onTransition}) {
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

  /// Renders the current state's visuals onto the provided [canvas]
  /// by calling its [onRender] method.
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    currentState?.onRender(_owner, canvas);
  }

  /// Sets the current state immediately and calls its [onEnter] method.
  /// Calls [onExit] on the previous state if applicable.
  void setState(State<T>? state) {
    if (state == _currentState) return;
    onTransition?.call(_owner, _currentState, state);
    _currentState?.onExit(_owner, state);
    state?.onEnter(_owner, _currentState);
    _previousState = _currentState;
    _currentState = state;
  }

  /// Updates the state machine, evaluating transitions and updating the current state.
  @override
  void update(double dt) {
    super.update(dt);

    final applicableTransitions = _transitions.where(
      (t) => t.from == _currentState || t.from is AnyState<T>,
    );

    for (final transition in applicableTransitions) {
      if (transition.to == _currentState || !transition.guard(_owner)) continue;
      final toState = transition.to is AnyState<T>
          ? previousState
          : transition.to;
      setState(toState);
      break;
    }

    _currentState?.onUpdate(dt, _owner);
  }
}
