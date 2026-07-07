import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_state_machine/src/state.dart';
import 'package:flame_state_machine/src/state_transition.dart';

/// A generic finite state machine for managing [State] transitions.
///
/// The [StateMachine] is a [Component], meaning it can be added to a Flame
/// component tree and its [update] and [render] methods will be called automatically
/// by the game loop. It maintains the current and previous states of an owner object
/// of type [T] and executes transitions based on a set of predefined [StateTransition] rules.
///
/// Transitions are evaluated in priority order (higher priority first). Each transition
/// defines a source state (`from`), a target state (`to`), and a `guard` function
/// that determines whether the transition is allowed.
///
/// A `null` `from` value means the transition is global and can trigger from any state.
///
///
/// Usage:
/// ```dart
/// // Inside the `onLoad()` method of a Flame component:
/// final idleState = IdleState();
/// final runningState = RunningState();
///
/// final stateMachine = StateMachine<Player>(
///   owner: this,
///   initialState: idleState,
///   transitions: [
///     StateTransition<Player>(
///       from: idleState,
///       to: runningState,
///       guard: (player) => player.isMoving,
///     ),
///     StateTransition<Player>(
///       from: idleState,
///       to: idleState,
///       guard: (player) => !player.isMoving,
///     ),
///   ],
/// );
///
/// // Add the state machine to the component tree:
/// add(stateMachine);
/// ```
///
/// Key points:
/// - The owner is the object controlled by this state machine (e.g., a Flame component).
/// - Transitions are defined explicitly via [StateTransition] objects.
/// - Transitions are evaluated in priority order (higher first).
/// - A `null` `from` state acts as a wildcard and matches any current state.
/// - State lifecycle methods ([onEnter], [onExit], [onRender], [onUpdate]) are called appropriately.
/// - Only one transition is executed per update cycle (first match wins).
class StateMachine<T> extends Component {
  /// Creates a [StateMachine] for the given [owner] and optional [initialState].
  ///
  /// The [initialState], if provided, will be entered immediately.
  StateMachine({
    required T owner,
    required State<T> initialState,
    List<StateTransition<T>> transitions = const [],
    this.onTransitionStart,
  }) : _previousState = null,
       _currentState = initialState {
    _owner = owner;

    addTransitions(transitions);

    onTransitionStart?.call(_owner, null, _currentState);
    _currentState.onEnter(_owner, null);
  }

  /// A function that is called at the start of a state transition.
  /// It receives the [owner], the previous state ([from]), and the new state ([to]).
  /// This can be used for logging, analytics, or triggering side effects.
  void Function(T owner, State<T>? from, State<T> to)? onTransitionStart;

  late T _owner;
  State<T> _currentState;
  State<T>? _previousState;
  final List<StateTransition<T>> _transitions = [];
  late UnmodifiableListView<StateTransition<T>> _readOnlyTransitions;

  /// Returns the current active state.
  State<T> get currentState => _currentState;

  /// Returns the previous state before the current one.
  State<T>? get previousState => _previousState;

  /// Returns a unmodifiable list of all registered state transitions.
  UnmodifiableListView<StateTransition<T>> get transitions =>
      _readOnlyTransitions;

  /// Adds a [StateTransition] to the state machine, sorted by priority.
  void addTransition(StateTransition<T> transition) {
    addTransitions([transition]);
  }

  /// Adds a list of [StateTransition]s to the state machine.
  ///
  /// Newly added transitions are merged with the existing ones and the
  /// complete list is sorted in descending priority order.
  void addTransitions(List<StateTransition<T>> transitions) {
    _transitions
      ..addAll(transitions)
      ..sort((a, b) => b.priority.compareTo(a.priority));
    _readOnlyTransitions = UnmodifiableListView(_transitions);
  }

  /// Removes a [StateTransition] from the state machine
  bool removeTransition(StateTransition<T> transition) {
    final removed = _transitions.remove(transition);
    _readOnlyTransitions = UnmodifiableListView(_transitions);
    return removed;
  }

  /// Removes all [StateTransition]s from the state machine
  void clearTransitions() {
    _transitions.clear();
    _readOnlyTransitions = UnmodifiableListView(_transitions);
  }

  /// Returns whether the given [StateTransition] is currently registered
  /// with the state machine.
  bool hasTransition(StateTransition<T> transition) =>
      _transitions.contains(transition);

  /// Returns whether any registered [StateTransition] applies to the given
  /// [state].
  bool hasTransitionsFor(State<T> state) =>
      _transitions.any((t) => t.match.matches(state));

  /// Renders the current [State]s visuals onto the provided [canvas]
  /// by calling its [onRender] method.
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    currentState.onRender(_owner, canvas);
  }

  void _setState(State<T> state) {
    final from = _currentState;
    final to = state;

    if (identical(from, to)) return;

    onTransitionStart?.call(_owner, from, to);

    _previousState = from;
    _currentState = to;

    from.onExit(_owner, to);
    to.onEnter(_owner, from);
  }

  /// Updates the state machine, evaluating transitions and updating the current state.
  @override
  void update(double dt) {
    super.update(dt);

    final applicableTransitions = _transitions.where(
      (t) => t.match.matches(_currentState),
    );

    for (final transition in applicableTransitions) {
      if (identical(transition.to, _currentState) ||
          !transition.guard(_owner)) {
        continue;
      }
      _setState(transition.to);
      break;
    }

    _currentState.onUpdate(dt, _owner);
  }
}
