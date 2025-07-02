import 'state.dart';
import 'state_transition.dart';

class StateMachine<T> {
  State<T>? _currentState;
  State<T>? _previousState;
  final List<StateTransition<T>> _transitions = [];

  State<T>? get currentState => _currentState;

  void addTransition(
    State<T>? from,
    State<T> to,
    Guard<T> guard, {
    int priority = 1,
    int reversePriority = 1,
    bool reverse = false,
  }) {
    final fromState = from ?? AnyState<T>();

    final forwardTransition = StateTransition(
      priority: priority,
      from: fromState,
      to: to,
      guard: guard,
    );
    _addTransition(forwardTransition);

    if (reverse) {
      final reverseTransition = StateTransition(
        priority: reversePriority,
        from: to,
        to: fromState,
        guard: (owner) => !guard(owner),
      );
      _addTransition(reverseTransition);
    }
  }

  void popState(T owner) {
    if (_previousState != null && _previousState != _currentState) {
      _currentState?.onExit(owner, _previousState);
      final oldState = _currentState;
      _currentState = _previousState;
      _currentState?.onEnter(owner, oldState);
    }
  }

  void setInitialState(State<T> state, T owner) {
    _currentState = state;
    _currentState?.onEnter(owner);
  }

  void update(double dt, T owner) {
    if (_currentState == null) return;

    final applicableTransitions = _transitions.where(
      (t) => t.from == _currentState || t.from is AnyState<T>,
    );

    for (final transition in applicableTransitions) {
      if (transition.to == _currentState || !transition.guard(owner)) continue;

      _currentState!.onExit(owner, transition.to);

      if (transition.to is AnyState<T>) {
        final oldState = _currentState;
        _currentState = _previousState?..onEnter(owner, oldState);
      } else {
        _previousState = _currentState;
        _currentState = transition.to..onEnter(owner, _previousState);
      }

      break;
    }

    _currentState!.onUpdate(dt, owner);
  }

  void _addTransition(StateTransition<T> transition) {
    _transitions
      ..add(transition)
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }
}
