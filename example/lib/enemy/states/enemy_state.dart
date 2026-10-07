import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter/material.dart' hide State;
import 'package:flutter_state_machine_example/enemy/enemy.dart';
import 'package:flutter_state_machine_example/health_bar_painter.dart';

class EnemyState extends State<Enemy> {
  static const _healthBar = HealthBarPainter();

  @override
  void onRender(Enemy owner, Canvas canvas) {
    _healthBar.paint(
      canvas,
      health: owner.health,
      maxHealth: owner.maxHealth,
      size: const Size(40, 5),
      offset: Offset(owner.width / 2 - 20, -8),
    );
  }

  @override
  void onRenderDebugMode(Enemy owner, Canvas canvas) {
    final painter = TextPainter(
      textDirection: .ltr,
      text: TextSpan(
        text: '$runtimeType',
        style: const TextStyle(color: Colors.yellow),
      ),
    );

    painter.layout();

    painter.paint(
      canvas,
      Offset(owner.width / 2 - painter.width / 2, owner.height),
    );
  }
}
