import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_state_machine_example/game.dart';
import 'package:flutter_state_machine_example/mixins/y_priority.dart';

enum PlayerState {
  idleSide,
  idleDown,
  idleUp,
  moveDown,
  moveUp,
  moveSide,
  attackDown,
  attackUp,
  attackSide,
  dead,
}

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with
        HasGameReference<FlameStateMachineExample>,
        KeyboardHandler,
        YPriority,
        CollisionCallbacks {
  final Vector2 _textureSize = Vector2(48, 48);
  final String _spritePath = 'player.png';

  Set<LogicalKeyboardKey> _keys = {};
  final Vector2 _moveDirection = Vector2.zero();
  final Vector2 _facingDirection = Vector2(0, 1);
  final double _moveSpeed = 100.0;

  double health = 100;

  void takeDamage(double damage) => health -= damage;

  @override
  Future<void> onLoad() async {
    anchor = const Anchor(.5, .85);
    await _initializeAnimations();
  }

  @override
  void update(double dt) {
    _updateMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keys = keysPressed;
    return true;
  }

  Future<void> _initializeAnimations() async {
    final image = await game.images.load(_spritePath);
    final sheet = SpriteSheet(image: image, srcSize: _textureSize);

    animations = {
      .idleDown: sheet.createAnimation(row: 0, stepTime: 0.2, to: 6),
      .idleSide: sheet.createAnimation(row: 1, stepTime: 0.2, to: 6),
      .idleUp: sheet.createAnimation(row: 2, stepTime: 0.2, to: 6),
      .moveDown: sheet.createAnimation(row: 3, stepTime: 0.1, to: 6),
      .moveSide: sheet.createAnimation(row: 4, stepTime: 0.1, to: 6),
      .moveUp: sheet.createAnimation(row: 5, stepTime: 0.1, to: 6),
      .attackDown: sheet.createAnimation(row: 6, stepTime: 0.1, to: 4),
      .attackSide: sheet.createAnimation(row: 7, stepTime: 0.1, to: 4),
      .attackUp: sheet.createAnimation(row: 8, stepTime: 0.1, to: 4),
      .dead: sheet.createAnimation(row: 9, stepTime: 0.1, to: 3, loop: false),
    };

    current = .idleDown;
  }

  Future<void> _updateMovement(double dt) async {
    double boost = 1.0;

    _moveDirection.setZero();
    if (_keys.contains(LogicalKeyboardKey.keyW)) {
      _moveDirection.y = -1;
    } else if (_keys.contains(LogicalKeyboardKey.keyS)) {
      _moveDirection.y = 1;
    }
    if (_keys.contains(LogicalKeyboardKey.keyA)) {
      _moveDirection.x = -1;
    } else if (_keys.contains(LogicalKeyboardKey.keyD)) {
      _moveDirection.x = 1;
    }

    if (_keys.contains(LogicalKeyboardKey.shiftLeft)) {
      boost = 2.0;
    }

    if (!_moveDirection.isZero()) {
      _moveDirection.normalize();
      position.add(_moveDirection * _moveSpeed * boost * dt);

      _facingDirection.setFrom(_moveDirection);

      if (_moveDirection.y < 0) {
        current = PlayerState.moveUp;
      } else if (_moveDirection.y > 0) {
        current = PlayerState.moveDown;
      } else {
        current = PlayerState.moveSide;
        scale.x = _moveDirection.x < 0 ? -1 : 1;
      }
    } else {
      if (_facingDirection.y < 0) {
        current = PlayerState.idleUp;
      } else if (_facingDirection.y > 0) {
        current = PlayerState.idleDown;
      } else {
        current = PlayerState.idleSide;
        scale.x = _facingDirection.x < 0 ? -1 : 1;
      }
    }
  }
}
