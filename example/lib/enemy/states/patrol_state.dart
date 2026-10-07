import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter/widgets.dart' hide State;
import 'package:flutter_state_machine_example/enemy/enemy.dart';
import 'package:flutter_state_machine_example/enemy/states/enemy_state.dart';

class PatrolState extends EnemyState {
  PatrolState({
    this.pointCount = 4,
    this.radius = 100,
    this.pauseDuration = 2.0,
  });

  final int pointCount;
  final double radius;
  final double pauseDuration;

  final List<Vector2> _patrolPoints = [];

  int _currentPoint = 0;
  double _pauseTimer = 0;

  bool _waiting = false;

  bool get finished => _currentPoint >= _patrolPoints.length;

  late Vector2 origin;

  final _pathDebugPaint = Paint()
    ..color = const Color(0xFFFF0000).withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final _currentPathDebugPaint = Paint()
    ..color = const Color(0xFFFFFF00)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final _pointDebugPaint = Paint()
    ..color = const Color(0xFF00FF00)
    ..style = PaintingStyle.fill;

  @override
  void onEnter(Enemy owner, State<Enemy>? prev) {
    origin = owner.position.clone();

    _generatePatrolPoints();

    _currentPoint = 0;
    _pauseTimer = 0;
    _waiting = false;

    owner.action = EnemyAction.walk;
  }

  @override
  void onUpdate(Enemy owner, double dt) {
    if (finished) {
      return;
    }

    if (_waiting) {
      _pauseTimer += dt;

      owner.stop();

      if (_pauseTimer >= pauseDuration) {
        owner.action = .walk;
        _waiting = false;
        _pauseTimer = 0;
        _currentPoint++;
      }

      return;
    }

    final target = _patrolPoints[_currentPoint];

    owner.moveTo(target);

    if (owner.position.distanceTo(target) < 5) {
      if (_currentPoint == _patrolPoints.length - 1) {
        _currentPoint++;
        owner.stop();
        return;
      }

      _waiting = true;
      _pauseTimer = 0;
      owner.action = .idle;
    }
  }

  @override
  void onRenderDebugMode(Enemy owner, Canvas canvas) {
    super.onRenderDebugMode(owner, canvas);

    if (finished || _patrolPoints.isEmpty) return;

    final remainingPoints = _patrolPoints.sublist(_currentPoint);

    final localPoints = remainingPoints
        .map((p) => owner.parentToLocal(p))
        .toList();

    final ownerLocal = owner.parentToLocal(owner.position);

    canvas.drawLine(
      localPoints.first.toOffset(),
      ownerLocal.toOffset(),
      _currentPathDebugPaint,
    );

    if (localPoints.length > 1) {
      final path = Path()..moveTo(localPoints.first.x, localPoints.first.y);

      for (final point in localPoints.skip(1)) {
        path.lineTo(point.x, point.y);
      }

      canvas.drawPath(path, _pathDebugPaint);
    }

    for (final point in localPoints) {
      canvas.drawCircle(Offset(point.x, point.y), 4, _pointDebugPaint);
    }
  }

  void _generatePatrolPoints() {
    final random = math.Random();

    _patrolPoints.clear();

    for (var i = 0; i < pointCount; i++) {
      final angle = random.nextDouble() * math.pi * 2;

      final distance = 30 + random.nextDouble() * (radius - 30);

      _patrolPoints.add(
        origin + Vector2(math.cos(angle), math.sin(angle)) * distance,
      );
    }

    _patrolPoints.add(origin.clone());
  }
}
