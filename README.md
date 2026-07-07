# flame_state_machine

A lightweight and flexible **finite state machine** package for the [Flame](https://flame-engine.org/) game engine, written in Dart.

Manage complex stateful behaviors for your Flame `Component`s with ease, enabling clean and maintainable game logic.

<a title="CI" href="https://github.com/bszarlej/flame_state_machine/actions/workflows/ci.yaml"><img src="https://github.com/bszarlej/flame_state_machine/actions/workflows/ci.yaml/badge.svg"></a>
<a title="Pub" href="https://pub.dev/packages/flame_state_machine" ><img src="https://img.shields.io/pub/v/flame_state_machine.svg?style=popout"></a>
<a title="Pub Points" href="https://pub.dev/packages/flame_state_machine/score"><img src="https://img.shields.io/pub/points/flame_state_machine.svg?style=popout"></a>
<a title="Pub Likes" href="https://pub.dev/packages/flame_state_machine/score"><img src="https://img.shields.io/pub/likes/flame_state_machine.svg?style=popout"></a>
<a title="Pub Downloads" href="https://pub.dev/packages/flame_state_machine/score" ><img src="https://img.shields.io/pub/dm/flame_state_machine"></a>

## Features

- Supports prioritized state transitions with custom guard conditions
- Flexible state matching using `StateMatch`
- Lifecycle callbacks for entering, exiting, rendering, and updating states
- Global transitions that can trigger from any state


## Usage

### 1. Create states

Extend the `State<T>` class to define your custom states:

```dart
class IdleState extends State<Enemy> {
  @override
  void onEnter(Enemy owner, State<Enemy>? from) {
    print('Enemy entered Idle state');
  }

  @override
  void onExit(Enemy owner, State<Enemy> to) {
    print('Enemy exited Idle state');
  }

  @override
  void onRender(Enemy owner, Canvas canvas) {
    // optionally render idle-specific visuals here (useful for debugging)
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
    final deathState = DeathState();

    final stateMachine = StateMachine<Enemy>(
      owner: this,
      initialState: idleState,
      transitions: [
        // global transition from any state
        StateTransition.global(
          priority: 999,
          to: deathState,
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
    // it will update its state automatically based on the transitions
    add(stateMachine);
  }
}
```

### State matching

`StateTransition` uses `StateMatch` to determine when a transition is applicable.

Match a specific state instance:

```dart
StateTransition(
  match: StateMatch.exact(idleState),
  to: chaseState,
  guard: (owner) => owner.distanceToPlayer <= 70,
);
```

Or create a transition that can occur from any state using either:

```dart
StateTransition.global(
  to: deathState,
  guard: (owner) => owner.health <= 0,
);
```

or:

```dart
StateTransition(
  match: StateMatch.any(),
  to: deathState,
  guard: (owner) => owner.health <= 0,
);
```

## API

- `StateMachine<T>` — Core FSM logic, implemented as a Flame `Component`
- `State<T>` — Base class for your states (override `onEnter`, `onExit`, `onRender`, `onUpdate`)
- `StateMatch<T>` - Determines the state[s] from which a transition can occur
- `StateTransition<T>` — Defines transitions between states with guards and priorities


## Contributing

Contributions and suggestions are welcome! Feel free to open issues or submit pull requests.