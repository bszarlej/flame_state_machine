# flame_state_machine

A lightweight and flexible **finite state machine** package for the [Flame](https://flame-engine.org/) game engine, written in Dart.

Manage complex stateful behaviors for your Flame `Component`s with ease, enabling clean and maintainable game logic.

<a title="CI" href="https://github.com/bszarlej/flame_state_machine/actions/workflows/ci.yaml"><img src="https://github.com/bszarlej/flame_state_machine/actions/workflows/ci.yaml/badge.svg"></a>
<a title="Pub" href="https://pub.dev/packages/flame_state_machine" ><img src="https://img.shields.io/pub/v/flame_state_machine.svg?style=popout"></a>
<a title="Pub Points" href="https://pub.dev/packages/flame_state_machine/score"><img src="https://img.shields.io/pub/points/flame_state_machine.svg?style=popout"></a>
<a title="Pub Likes" href="https://pub.dev/packages/flame_state_machine/score"><img src="https://img.shields.io/pub/likes/flame_state_machine.svg?style=popout"></a>
<a title="Pub Downloads" href="https://pub.dev/packages/flame_state_machine/score" ><img src="https://img.shields.io/pub/dm/flame_state_machine"></a>

## Features

- Generic state machine designed to work seamlessly with Flame `Component`s
- Supports prioritized state transitions with custom guard conditions
- Easy registration of reversible transitions
- Lifecycle callbacks for entering, exiting, rendering and updating states
- Support for transitions that can occur from any state


## Usage

### 1. Create states

Extend the `State<T>` class to define your custom states:

```dart
class IdleState extends State<Enemy> {
  @override
  void onEnter(Enemy enemy, [State<Enemy>? from]) {
    print('Enemy entered Idle state');
  }

  @override
  void onExit(Enemy enemy, [State<Enemy>? to]) {
    print('Enemy exited Idle state');
  }

  @override
  void onRender(Enemy owner, Canvas canvas) {
    // optionally render idle-specific visuals here (useful for debugging)
  }

  @override
  void onUpdate(double dt, Enemy enemy) {
    // handle idle behavior
  }
}
```

### 2. Setup state machine in your Flame component

add a `StateMachine` instance to your component
```dart
class Enemy extends PositionComponent {

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final idleState = IdleState();
    final runningState = RunningState();
    final deathState = DeathState();

    final stateMachine = StateMachine<Enemy>(
      owner: this,
      initialState: idleState,
    );

    // transition from any state with a high priority
    stateMachine.register(
      to: deathState,
      guard: (enemy) => !enemy.isAlive,
      priority: 100,
    );

    stateMachine.register(
      from: idleState,
      to: runningState,
      guard: (enemy) => enemy.isMoving,
      reverse: true,
    );

    // add the state machine as a child component
    add(stateMachine);
  }
}
```

### 3. Register transitions with guards

Use `register()` to define valid state changes and their conditions:

```dart
stateMachine.register(
  priority: 1, // transitions with higher priority values will be checked first
  from: IdleState(), // if not provided the transition can occur from any state
  to: RunningState(),
  guard: (enemy) => enemy.isMoving,
  reverse: true, // automatically registers reverse transition
  reversePriority: 1, // priority for the reverse transition
  reverseGuard: (enemy) => !enemy.isMoving, // guard for the reverse transition (Constructed automatically if not provided)
);
```

Or use `addTransition()` to add a `StateTransition` Object manually:

```dart
stateMachine.addTransition(
  StateTransition(
    from: IdleState(),
    to: RunningState(),
    guard: (enemy) => enemy.isMoving,
  )
);
```

## API

- `StateMachine<T>` — Core FSM logic, implemented as a Flame `Component`
- `State<T>` — Base class for your states (override `onEnter`, `onExit`, `onRender`, `onUpdate`)
- `StateTransition<T>` — Defines transitions between states with guards and priorities


## Contributing

Contributions and suggestions are welcome! Feel free to open issues or submit pull requests.