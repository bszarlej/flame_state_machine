import 'state.dart';
import 'state_transition.dart';

class StateMachine<T> {
  State<T>? _currentState;
  final List<StateTransition<T>> _transitions = [];

  State<T>? get currentState => _currentState;

  void addTransition(
    State<T> from,
    State<T> to,
    bool Function(T owner) when, {
    int priority = 1,
    int reversePriority = 1,
    bool reverse = false,
  }) {
    final transition = StateTransition(
      priority: priority,
      from: from,
      to: to,
      when: when,
    );
    _transitions.add(transition);

    if (reverse) {
      final reverseTransition = StateTransition(
        priority: reversePriority,
        from: to,
        to: from,
        when: (owner) => !when(owner),
      );
      _transitions.add(reverseTransition);
    }
    _transitions.sort((a, b) => b.priority.compareTo(a.priority));
  }

  void setInitialState(State<T> state, T owner) {
    _currentState = state..onEnter(owner);
  }

  void update(double dt, T owner) {
    if (_currentState == null) return;

    final availableTransitions = _transitions.where(
      (t) => t.from == _currentState,
    );

    for (final transition in availableTransitions) {
      if (transition.when(owner)) {
        _currentState!.onExit(owner, transition.to);
        final from = _currentState;
        _currentState = transition.to..onEnter(owner, from);
        break;
      }
    }

    _currentState!.onUpdate(dt, owner);
  }
}
