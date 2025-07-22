import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter/widgets.dart' hide State;

void main() {
  runApp(GameWidget(game: FlameStateMachineExampleGame()));
}

class Enemy extends RectangleComponent with HasStates<Enemy> {
  @override
  late final StateMachine<Enemy> stateMachine;

  bool isPatrolling = false;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final idleState = IdleState();
    final patrolState = PatrolState();

    stateMachine = StateMachine<Enemy>(owner: this, initialState: idleState);
    stateMachine.register(
      from: idleState,
      to: patrolState,
      guard: (owner) => isPatrolling,
      reverse: true,
    );
  }
}

class FlameStateMachineExampleGame extends FlameGame {
  @override
  FutureOr<void> onLoad() {
    world.add(
      Enemy()
        ..size = Vector2(50, 50)
        ..anchor = Anchor.center,
    );
    return super.onLoad();
  }
}

class IdleState extends State<Enemy> {
  final double _idleDuration = 2;
  double _timer = 0.0;

  @override
  void onEnter(Enemy owner, [State<Enemy>? from]) {
    _timer = 0.0;
    print('Enemy entered Idle state');
  }

  @override
  void onExit(Enemy owner, [State<Enemy>? to]) {
    print('Enemy exited Idle state');
  }

  @override
  void onUpdate(double dt, Enemy owner) {
    _timer += dt;
    if (_timer >= _idleDuration) {
      owner.isPatrolling = true;
    }
  }
}

class PatrolState extends State<Enemy> {
  final Vector2 _patrolDirection = Vector2(1, 0);
  final double _patrolSpeed = 75;

  @override
  void onEnter(Enemy owner, [State<Enemy>? from]) {
    print('Enemy entered Patrol state');
  }

  @override
  void onExit(Enemy owner, [State<Enemy>? to]) {
    print('Enemy exited Patrol state');
  }

  @override
  void onUpdate(double dt, Enemy owner) {
    // Move the enemy in the patrol direction
    owner.position += _patrolDirection * _patrolSpeed * dt;

    // Example condition to switch back to idle state
    if (owner.position.x.abs() > 100) {
      _patrolDirection.x *= -1; // Reverse direction
      owner.isPatrolling = false;
    }
  }
}

//ignore_for_file: avoid_print
