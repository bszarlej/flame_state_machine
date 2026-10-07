import 'package:flame/extensions.dart';
import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter_state_machine_example/enemy/enemy.dart';
import 'package:flutter_state_machine_example/enemy/states/enemy_state.dart';

final class RetreatState extends EnemyState {
  RetreatState({
    this.retreatDistance = 200,
    this.healInterval = 0.5,
    this.healAmount = 10,
  });

  final double retreatDistance;
  final double healInterval;
  final double healAmount;

  bool _finished = false;
  double _healTimer = 0;

  bool get finished => _finished;

  @override
  void onEnter(Enemy owner, State<Enemy>? prev) {
    _finished = false;
    _healTimer = 0;

    owner.action = .run;
  }

  @override
  void onUpdate(Enemy owner, double dt) {
    _healTimer += dt;

    if (_healTimer >= healInterval) {
      _healTimer = 0;

      owner.heal(healAmount);
    }

    final awayDirection = owner.position - owner.game.player.position;

    if (awayDirection.isZero()) {
      return;
    }

    awayDirection.normalize();

    final target = owner.position + awayDirection * retreatDistance;

    owner.moveTo(target);

    if (owner.distanceToPlayer >= retreatDistance) {
      owner.stop();
      _finished = true;
    }
  }
}
