import 'state.dart';

typedef Guard<T> = bool Function(T owner);

class StateTransition<T> {
  final int priority;
  final State<T> from;
  final State<T> to;
  final Guard<T> guard;

  StateTransition({
    this.priority = 1,
    required this.from,
    required this.to,
    required this.guard,
  });

  bool get isGlobal => this.from is AnyState<T>;

  @override
  String toString() {
    return 'StateTransition<$T>('
        'priority: $priority, '
        'from: $from, '
        'to: $to, '
        ')';
  }
}
