# flame_state_machine

A lightweight and flexible **finite state machine** package for the [Flame](https://flame-engine.org/) game engine, written in Dart.

Built around Flame's component architecture, it allows you to separate entity behavior into clean, reusable states while automatically integrating with Flame's update and render lifecycle.

<a title="CI" href="https://github.com/bszarlej/flame_state_machine/actions/workflows/ci.yaml"><img src="https://github.com/bszarlej/flame_state_machine/actions/workflows/ci.yaml/badge.svg"></a>
<a title="Pub" href="https://pub.dev/packages/flame_state_machine" ><img src="https://img.shields.io/pub/v/flame_state_machine.svg?style=popout"></a>
<a title="Pub Points" href="https://pub.dev/packages/flame_state_machine/score"><img src="https://img.shields.io/pub/points/flame_state_machine.svg?style=popout"></a>
<a title="Pub Likes" href="https://pub.dev/packages/flame_state_machine/score"><img src="https://img.shields.io/pub/likes/flame_state_machine.svg?style=popout"></a>
<a title="Pub Downloads" href="https://pub.dev/packages/flame_state_machine/score" ><img src="https://img.shields.io/pub/dm/flame_state_machine"></a>

## Features

- Flame-native `StateMachine` implementation that integrates directly into the component tree
- Clean state lifecycle management with `onEnter`, `onExit`, `onUpdate`, `onRender`, and `onRenderDebugMode` callbacks
- Priority-based transitions for handling complex behavior hierarchies
- Manual state changes for direct behavior control when transitions are not required
- Flexible state matching with exact, global, and multi-state transition rules
- Generic state ownership, allowing states to control any Flame `Component`
- Built-in transition hooks for observing and reacting to state changes
- Simple composition of complex game behaviors without large conditional blocks

## Usage

### 1. Create states

Extend the `State<T>` class to define your custom states:

```dart
class IdleState extends State<Enemy> {
  @override
  void onEnter(Enemy owner, State<Enemy>? prev) {
    print('Enemy entered Idle state');
  }

  @override
  void onExit(Enemy owner, State<Enemy> next) {
    print('Enemy exited Idle state');
  }

  @override
  void onRender(Enemy owner, Canvas canvas) {
    // optionally render idle-specific visuals here
  }

  @override
  void onRenderDebugMode(Enemy owner, Canvas canvas) {
    // render debug stuff
  }

  @override
  void onUpdate(Enemy owner, double dt) {
    // handle idle behavior
  }
}
```

### 2. Setup state machine in your Flame component

Since `StateMachine` is a Flame `Component` all you have to do is add it directly via the `add` method of your component
and it will automatically handle the state transitions and update the current state.
```dart
class Enemy extends PositionComponent {
  double health = 100.0;
  
  double get distanceToPlayer => ...;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final idleState = IdleState();
    final chaseState = ChaseState();
    final deadState = DeadState();

    final stateMachine = StateMachine<Enemy>(
      owner: this,
      initialState: idleState,
      transitions: [
        // global transition from any state
        StateTransition.global(
          priority: 999,
          to: deadState,
          guard: (owner) => health <= 0,
        ),
        StateTransition(
          match: StateMatch.exact(idleState),
          to: chaseState,
          guard: (owner) => distanceToPlayer <= 70,
        ),
        StateTransition(
          match: StateMatch.exact(chaseState),
          to: idleState,
          guard: (owner) => distanceToPlayer > 70,
        )
      ]
    );

    // add the state machine as a child component
    // it will update its state automatically based on provided state transitions
    add(stateMachine);
  }
}
```

### State matching

`StateTransition` uses `StateMatch` to determine from which state or states a transition can occur.

Match a specific state:

```dart
StateTransition(
  match: StateMatch.exact(idleState),
  to: chaseState,
  guard: (owner) => owner.distanceToPlayer <= 70,
);
```

Match any state:

```dart
StateTransition.global(
  to: deadState,
  guard: (owner) => owner.health <= 0,
);
```

Match multiple states:

```dart
StateTransition(
  match: StateMatch.anyOf([idleState, patrolState])
  to: chaseState,
  guard: (owner) => owner.distanceToPlayer <= 70,
);
```

### Manual state changes

In addition to automatic transitions, states can also be changed manually using
the `StateMachine.changeState` method.

This is useful for situations where a state change is triggered externally,
such as player input, scripted events, cutscenes, or forced behaviors.

```dart
class AttackState extends State<Enemy> {
  @override
  void onUpdate(Enemy owner, double dt) {
    if (owner.attackFinished) {
      owner.stateMachine.changeState(owner.idleState);
    }
  }
}
```

Manual state changes bypass transition matching and guard conditions. The normal
state lifecycle is still executed:

1. onTransitionStart is called
2. The current state's onExit is called
3. The new state's onEnter is called

For behavior that should be controlled by conditions, use StateTransition.
For direct control, use changeState.

## Example

A complete example project demonstrating `flame_state_machine` in a Flame game:

[flame_state_machine_example](https://github.com/bszarlej/flame_state_machine_example)

The example demonstrates:

- Enemy "AI" using multiple states
- Patrol, chase, combat, retreat, and death behaviors
- Prioritized and global transitions
- State-specific rendering and debug visualization

## API

- `StateMachine<T>` — Core FSM logic, implemented as a Flame `Component`. Supports automatic transitions and manual state changes.
- `State<T>` — Base class for your states (override `onEnter`, `onExit`, `onRender`, `onRenderDebugMode`, `onUpdate`)
- `StateMatch<T>` - Determines the state[s] from which a transition can occur
- `StateTransition<T>` — Defines transitions between states with guards and priorities


## Contributing

Contributions and suggestions are welcome! Feel free to open issues or submit pull requests.