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
- Lifecycle callbacks for entering, exiting, and updating states
- `AnyState` support for transitions valid from any current state


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
  void onUpdate(double dt, Enemy enemy) {
    // handle idle behavior
  }
}
```

### 2. Setup state machine in your Flame component

Mix in `HasStates` and provide a `StateMachine` instance:

```dart
class Enemy extends PositionComponent with HasStates<Enemy> {
  late final StateMachine<Enemy> stateMachine;

  Enemy() {
    final idleState = IdleState();
    final runningState = RunningState();
    final deathState = DeathState();

    stateMachine = StateMachine<Enemy>(
      owner: this,
      initialState: idleState,
    );

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
  }

  @override
  void update(double dt) {
    super.update(dt);
    // stateMachine.update(dt);  // called automatically by HasStates
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

>[!NOTE]
> If you use `addTransition()`, you must define the reverse transition yourself, like so:

```dart
stateMachine.addTransition(
  StateTransition(
    from: RunningState(),
    to: IdleState(),
    guard: (enemy) => !enemy.isMoving,
  )
);
```

## API

- `StateMachine<T>` — Core FSM logic
- `State<T>` — Base class for your states (override `onEnter`, `onExit`, `onUpdate`)
- `StateTransition<T>` — Defines transitions between states with guards and priorities
- `HasStates<T extends Component>` — Mixin for Flame components to attach a state machine


## Contributing

Contributions and suggestions are welcome! Feel free to open issues or submit pull requests.