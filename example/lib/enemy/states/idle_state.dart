import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter_state_machine_example/enemy/enemy.dart';
import 'package:flutter_state_machine_example/enemy/states/enemy_state.dart';

class IdleState extends EnemyState {
  IdleState({required this.duration});

  final double duration;
  double _timer = 0.0;

  @override
  void onEnter(Enemy owner, State<Enemy>? prev) {
    owner.action = .idle;
    owner.stop();
    _timer = 0.0;
  }

  @override
  void onUpdate(Enemy owner, double dt) {
    _timer += dt;
  }

  bool get finished => _timer >= duration;
}
