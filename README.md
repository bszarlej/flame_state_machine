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
  void onRender(Canvas canvas, Enemy enemy) {
    // optionally render idle-specific visuals here (useful for debugging)
  }

  @override
  void onUpdate(double dt, Enemy enemy) {
    // handle idle behavior
  }
}
```

### 2. Setup state machine in your Flame component

Since `StateMachine` is a Flame `Component` all you have to do is add it directly via the `add` method of your component
and it will automatically handle the state transitions and update the current state.
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
    stateMachine.addTransition(
      StateTransition.globlal(
        to: deathState,
        guard: (enemy) => !enemy.isAlive,
        priority: 100,
      )
    );

    stateMachine.addTransition(
      StateTransition(
        from: idleState,
        to: runningState,
        guard: (enemy) => enemy.isMoving,
      )
    );

    // add the state machine as a child component
    add(stateMachine);
  }
}
```

## API

- `StateMachine<T>` — Core FSM logic, implemented as a Flame `Component`
- `State<T>` — Base class for your states (override `onEnter`, `onExit`, `onRender`, `onUpdate`)
- `StateTransition<T>` — Defines transitions between states with guards and priorities


## Contributing

Contributions and suggestions are welcome! Feel free to open issues or submit pull requests.