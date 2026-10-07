import 'package:flame/components.dart';
import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter/material.dart' hide State;
import 'package:flutter_state_machine_example/enemy/enemy.dart';
import 'package:flutter_state_machine_example/enemy/states/enemy_state.dart';

final class CombatState extends EnemyState {
  double _hurtTimer = 0;
  final double _hurtInterval = .75;
  final double _damageTaken = 25;

  bool _hurtAnimationRunning = false;
  double _hurtAnimationTimer = 0;
  final double _hurtAnimationDuration =
      EnemyAction.hurt.stepTime * (EnemyAction.hurt.frameCount - 1);

  @override
  void onEnter(Enemy owner, State<Enemy>? prev) {
    owner.stop();
    owner.action = .attack;
    owner.isAttacking = true;
  }

  @override
  void onUpdate(Enemy owner, double dt) {
    if (_hurtAnimationRunning) {
      _hurtAnimationTimer += dt;

      if (_hurtAnimationTimer >= _hurtAnimationDuration) {
        owner.action = .attack;

        _hurtAnimationTimer = 0;
        _hurtAnimationRunning = false;
        owner.isAttacking = true;
      }

      return;
    }

    _hurtTimer += dt;

    if (_hurtTimer >= _hurtInterval) {
      _takeDamage(owner);
    }
  }

  @override
  void onRender(Enemy owner, Canvas canvas) {
    super.onRender(owner, canvas);

    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..style = .stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      owner.parentToLocal(owner.position).toOffset(),
      owner.attackRange,
      paint,
    );
  }

  @override
  void onExit(Enemy owner, State<Enemy> next) {
    owner.isAttacking = false;
  }

  void _takeDamage(Enemy owner) {
    owner.takeDamage(_damageTaken);

    owner.action = .hurt;
    owner.isAttacking = false;

    _hurtAnimationRunning = true;
    _hurtAnimationTimer = 0;
    _hurtTimer = 0;
  }
}
