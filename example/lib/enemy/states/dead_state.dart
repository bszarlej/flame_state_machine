import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_state_machine_example/enemy/enemy.dart';
import 'package:flutter_state_machine_example/enemy/states/enemy_state.dart';

final class DeadState extends EnemyState {
  double _despawnTimer = 0.0;

  double get _despawnAfterSeconds =>
      EnemyAction.dead.frameCount * EnemyAction.dead.stepTime + 2;

  double get _despawningIn =>
      (_despawnAfterSeconds - _despawnTimer).clamp(0, _despawnAfterSeconds);

  @override
  void onEnter(Enemy owner, State<Enemy>? prev) {
    _despawnTimer = 0.0;

    owner.stop();
    owner.action = .dead;
  }

  @override
  void onUpdate(Enemy owner, double dt) {
    _despawnTimer += dt;

    if (_despawnTimer >= _despawnAfterSeconds) {
      owner.removeFromParent();
    }
  }

  @override
  void onRender(Enemy owner, Canvas canvas) {}

  @override
  void onRenderDebugMode(Enemy owner, Canvas canvas) {
    super.onRenderDebugMode(owner, canvas);

    final painter = TextPainter(
      textDirection: .ltr,
      text: TextSpan(
        text: 'Despawning in ${_despawningIn.toStringAsFixed(1)}s',
      ),
    );

    painter.layout();

    painter.paint(
      canvas,
      Offset(owner.width, owner.height / 2 - painter.height / 2),
    );
  }
}
