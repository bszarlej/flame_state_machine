import 'state.dart';

class StateTransition<T> {
  final int priority;
  final State<T> from;
  final State<T> to;
  final bool Function(T owner) when;

  StateTransition({
    this.priority = 1,
    required this.from,
    required this.to,
    required this.when,
  });

  @override
  String toString() {
    return 'StateTransition<$T>('
        'priority: $priority, '
        'from: $from, '
        'to: $to, '
        ')';
  }
}
