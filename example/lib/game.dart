import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_camera_tools/flame_camera_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_machine_example/enemy/enemy.dart';
import 'package:flutter_state_machine_example/player/player.dart';

class FlameStateMachineExample extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final Player player;

  @override
  Color backgroundColor() => Colors.grey.shade800;

  @override
  Future<void> onLoad() async {
    debugMode = true;

    final world = World();
    final camera = CameraComponent(world: world);

    camera.viewfinder.zoom = 1.5;

    await add(world);
    await add(camera);

    player = Player();

    await world.add(player);

    await world.add(Enemy()..position = Vector2(200, 100));

    await world.add(Enemy(retreatWhenLow: false)..position = Vector2(-200, 70));

    camera.chase(
      player,
      stiffness: 0.95,
      deadZone: RectangularDeadzone.all(50),
    );
  }
}
