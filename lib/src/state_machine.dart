import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_state_machine/src/state.dart';
import 'package:flame_state_machine/src/state_transition.dart';

/// A generic finite state machine for managing [State] transitions and behavior.
///
/// The [StateMachine] is a [Component], meaning it can be added to a Flame
/// component tree and its [update] and [render] methods will be called
/// automatically by the game loop. It maintains the current and previous states
/// of an owner object of type [T] and executes transitions based on a set of
/// predefined [StateTransition] rules.
///
/// Transitions are evaluated in priority order (higher priority first). Each
/// transition defines a [StateMatch] that determines which states it can trigger
/// from, a target state ([StateTransition.to]), and a guard function
/// ([StateTransition.guard]) that determines whether the transition is allowed.
///
/// Unlike traditional state machines that require a transition to specify a
/// single source state, [StateMatch] allows transitions to match states using
/// different strategies. A transition can match a specific state, multiple
/// states, or all states depending on the matcher used.
///
/// ### Matching behavior
/// State matching is handled through [StateMatch] implementations.
///
/// Common matchers include:
/// - [ExactStateMatch] to match a specific state instance.
/// - [AnyStateMatch] to match every state.
/// - [MultiStateMatch] to match multiple states.
///
/// Custom matchers can be created to implement more complex transition rules.
///
/// ### Example
/// ```dart
/// final idle = IdleState(duration: 8);
/// final patrol = PatrolState(patrolPoints: 5);
/// final chase = ChaseState();
/// final dead = DeadState();
///
/// final stateMachine = StateMachine<Enemy>(
///   owner: this,
///   initialState: idle,
///   transitions: [
///     StateTransition<Enemy>(
///       match: StateMatch.exact(idle),
///       to: patrol,
///       guard: (_) => idle.finished,
///     ),
///     StateTransition<Enemy>.global(
///       to: dead,
///       guard: (enemy) => enemy.health <= 0,
///     ),
///      StateTransition<Enemy>(
///       match: StateMatch.anyOf([idle, patrol]),
///       to: chase,
///       guard: (enemy) => enemy.distanceToPlayer <= 70,
///     )
///   ],
/// );
///
/// // Add the state machine to the component tree:
/// add(stateMachine);
/// ```
///
/// Key points:
/// - The owner is the object controlled by this state machine (e.g. a Flame component).
/// - Transitions are defined explicitly using [StateTransition] objects.
/// - [StateMatch] controls which states a transition can trigger from.
/// - Transitions are evaluated in priority order (higher priority first).
/// - State lifecycle methods ([State.onEnter], [State.onExit],
///   [State.onRender], [State.onRenderDebugMode], [State.onUpdate]) are delegated to the active state.
/// - Only one transition is executed per update cycle (first valid match wins).
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

  /// Immediately changes the active state.
  ///
  /// If [state] is already the current state, this method has no effect.
  ///
  /// The transition lifecycle is executed in the following order:
  /// 1. [onTransitionStart] is invoked.
  /// 2. The current state's [State.onExit] method is called.
  /// 3. The new state's [State.onEnter] method is called.
  ///
  /// This method bypasses all registered [StateTransition]s and their guards.
  void changeState(State<T> state) {
    final from = _currentState;
    final to = state;

    if (identical(from, to)) return;

    onTransitionStart?.call(_owner, from, to);

    _previousState = from;
    _currentState = to;

    from.onExit(_owner, to);
    to.onEnter(_owner, from);
  }

  /// Renders the current [State]'s visuals onto the provided [canvas]
  /// by calling its [onRender] method.
  @override
  void render(Canvas canvas) {
    currentState.onRender(_owner, canvas);
  }

  /// Renders the current [State]'s debug visuals onto the provided [canvas].
  ///
  /// This method is called by Flame when debug rendering is enabled and delegates
  /// the rendering to the active state's [State.onRenderDebugMode] method.
  @override
  void renderDebugMode(Canvas canvas) {
    currentState.onRenderDebugMode(_owner, canvas);
  }

  /// Updates the state machine.
  ///
  /// The active state's [State.onUpdate] method is called every update cycle.
  @override
  void update(double dt) {
    super.update(dt);

    _evaluateTransitions();

    _currentState.onUpdate(_owner, dt);
  }

  /// Evaluates all registered transitions.
  ///
  /// Transitions are checked in priority order. The first transition whose
  /// [StateMatch] matches the current state and whose guard returns `true`
  /// will be executed.
  void _evaluateTransitions() {
    for (final transition in _transitions) {
      if (!transition.match.matches(_currentState)) {
        continue;
      }

      if (identical(transition.to, _currentState) ||
          !transition.guard(_owner)) {
        continue;
      }

      changeState(transition.to);
      return;
    }
  }
}
