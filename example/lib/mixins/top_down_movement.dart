import 'package:flame/components.dart';
import 'package:flutter_state_machine_example/direction.dart';

mixin TopDownMovement on PositionComponent {
  double moveSpeed = 100;
  final Vector2 velocity = Vector2.zero();

  Direction facing = Direction.down;

  void move(Vector2 direction) {
    if (direction.isZero()) {
      stop();
      return;
    }

    velocity
      ..setFrom(direction)
      ..normalize()
      ..scale(moveSpeed);

    _updateFacing(direction);
  }

  void stop() => velocity.setZero();

  void moveTo(Vector2 target) => move(target - position);

  void _updateFacing(Vector2 direction) {
    if (direction.x.abs() > direction.y.abs()) {
      facing = direction.x > 0
          ? Direction.right
          : direction.x < 0
          ? Direction.left
          : facing;
    } else {
      facing = direction.y > 0
          ? Direction.down
          : direction.y < 0
          ? Direction.up
          : facing;
    }
  }

  @override
  void update(double dt) {
    position += velocity * dt;
    super.update(dt);
  }

  bool get isMoving => !velocity.isZero();
}
