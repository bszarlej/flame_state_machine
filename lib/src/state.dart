final class AnyState<T> extends State<T> {
  @override
  void onEnter(T owner, [State<T>? from]) {}

  @override
  void onExit(T owner, [State<T>? to]) {}

  @override
  void onUpdate(double dt, T owner) {}
}

abstract class State<T> {
  void onEnter(T owner, [State<T>? from]);
  void onExit(T owner, [State<T>? to]);
  void onUpdate(double dt, T owner);
}
