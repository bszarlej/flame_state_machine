import 'package:flame/components.dart';

import 'state_machine.dart';

/// A mixin to add state machine capabilities to a Flame [Component].
///
/// Requires implementing a [stateMachine] property which manages the states
/// of this component.
///
/// Automatically calls [stateMachine.update] each frame inside [update].
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
  void update(double dt) {
    super.update(dt);
    stateMachine.update(dt);
  }
}
