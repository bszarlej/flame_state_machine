import 'package:flame/components.dart';

mixin YPriority on PositionComponent {
  @override
  void update(double dt) {
    super.update(dt);

    final newPriority = position.y.toInt();
    if (priority != newPriority) {
      priority = newPriority;
    }
  }
}
