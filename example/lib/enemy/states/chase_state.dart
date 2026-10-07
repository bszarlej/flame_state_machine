import 'package:flame/extensions.dart';
import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter/material.dart' hide State;
import 'package:flutter_state_machine_example/enemy/enemy.dart';
import 'package:flutter_state_machine_example/enemy/states/enemy_state.dart';

class ChaseState extends EnemyState {
  TextPainter? _painter;

  @override
  void onEnter(Enemy owner, State<Enemy>? prev) {
    owner.stop();
    owner.action = .idle;

    _painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: '!',
        style: TextStyle(
          color: Colors.red,
          fontFamily: 'PixelOperator',
          fontSize: 24,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
      ),
    );

    _painter!.layout();
  }

  @override
  void onUpdate(Enemy owner, double dt) {
    owner.action = .run;
    owner.move(owner.game.player.position - owner.position);
  }

  @override
  void onRender(Enemy owner, Canvas canvas) {
    super.onRender(owner, canvas);

    _painter!.paint(
      canvas,
      Offset(owner.width / 2 - _painter!.width / 2, -_painter!.height - 8),
    );
  }

  @override
  void onRenderDebugMode(Enemy owner, Canvas canvas) {
    super.onRenderDebugMode(owner, canvas);

    canvas.drawLine(
      owner.parentToLocal(owner.position).toOffset(),
      owner.parentToLocal(owner.game.player.position).toOffset(),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );
  }

  @override
  void onExit(Enemy owner, State<Enemy> next) {
    _painter = null;
  }
}
