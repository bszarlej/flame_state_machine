abstract class State<T> {
  void onEnter(T owner, [State<T>? from]);
  void onExit(T owner, [State<T>? to]);
  void onUpdate(double dt, T owner);
}
