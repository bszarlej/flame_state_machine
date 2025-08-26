import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import 'state_machine.dart';

/// A mixin to add state machine capabilities to a Flame [Component].
///
/// Requires implementing a [stateMachine] property which manages the states
/// of this component.
///
/// Automatically calls [stateMachine.update] and [stateMachine.render] each frame inside [update] and [render] accordingly.
///
/// Example:
/// ```dart
/// class Player extends PositionComponent with HasStates<Player> {
///   @override
///   late final stateMachine = StateMachine<Player>(owner: this, initialState: IdleState());
/// }
/// ```
mixin HasStates<T extends Component> on Component {
  /// The state machine controlling this component's states.
  StateMachine<T> get stateMachine;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    stateMachine.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    stateMachine.update(dt);
  }
}
