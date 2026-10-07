import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_machine_example/direction.dart';
import 'package:flutter_state_machine_example/enemy/states/chase_state.dart';
import 'package:flutter_state_machine_example/enemy/states/combat_state.dart';
import 'package:flutter_state_machine_example/enemy/states/dead_state.dart';
import 'package:flutter_state_machine_example/enemy/states/idle_state.dart';
import 'package:flutter_state_machine_example/enemy/states/patrol_state.dart';
import 'package:flutter_state_machine_example/enemy/states/retreat_state.dart';
import 'package:flutter_state_machine_example/game.dart';
import 'package:flutter_state_machine_example/mixins/top_down_movement.dart';
import 'package:flutter_state_machine_example/mixins/y_priority.dart';

enum EnemyAction {
  idle(4, stepTime: 0.22, loop: true),
  walk(6, stepTime: 0.2, loop: true),
  run(8, stepTime: 0.1, loop: true),
  attack(8, stepTime: 0.1, loop: true),
  hurt(6, stepTime: 0.1, loop: true),
  dead(8, stepTime: 0.15, loop: false);

  const EnemyAction(
    this.frameCount, {
    required this.stepTime,
    required this.loop,
  });

  final int frameCount;
  final double stepTime;
  final bool loop;
}

enum EnemyAnimation {
  idleDown(.idle, .down),
  idleUp(.idle, .up),
  idleLeft(.idle, .left),
  idleRight(.idle, .right),

  walkDown(.walk, .down),
  walkUp(.walk, .up),
  walkRight(.walk, .right),
  walkLeft(.walk, .left),

  walkAttackDown(.walk, .down, isAttacking: true),
  walkAttackUp(.walk, .up, isAttacking: true),
  walkAttackRight(.walk, .right, isAttacking: true),
  walkAttackLeft(.walk, .left, isAttacking: true),

  runDown(.run, .down),
  runUp(.run, .up),
  runRight(.run, .right),
  runLeft(.run, .left),

  runAttackDown(.run, .down, isAttacking: true),
  runAttackUp(.run, .up, isAttacking: true),
  runAttackRight(.run, .right, isAttacking: true),
  runAttackLeft(.run, .left, isAttacking: true),

  attackDown(.attack, .down, isAttacking: true),
  attackUp(.attack, .up, isAttacking: true),
  attackRight(.attack, .right, isAttacking: true),
  attackLeft(.attack, .left, isAttacking: true),

  hurtDown(.hurt, .down),
  hurtUp(.hurt, .up),
  hurtRight(.hurt, .right),
  hurtLeft(.hurt, .left),

  deadDown(.dead, .down),
  deadUp(.dead, .up),
  deadRight(.dead, .right),
  deadLeft(.dead, .left);

  const EnemyAnimation(this.action, this.direction, {this.isAttacking = false});

  final EnemyAction action;
  final Direction direction;
  final bool isAttacking;

  bool get isMoving => action == .walk || action == .run;

  bool get isAlive => action != .dead;

  bool get isIdle => action == .idle;

  bool get isHurt => action == .hurt;
}

class Enemy extends SpriteAnimationGroupComponent<EnemyAnimation>
    with
        HasGameReference<FlameStateMachineExample>,
        TopDownMovement,
        YPriority {
  Enemy({this.retreatWhenLow = true});

  bool retreatWhenLow;

  EnemyAction action = EnemyAction.idle;
  bool isAttacking = false;

  double get distanceToPlayer => (game.player.position - position).length;

  bool get seesPlayer => distanceToPlayer <= 150;

  bool get canAttack => distanceToPlayer <= attackRange;

  double attackRange = 30;
  double maxHealth = 100;
  double health = 100;

  void takeDamage(double damage) {
    if (health <= 0) return;

    final oldHealth = health;
    health = (health - damage).clamp(0, maxHealth);

    final damageTaken = oldHealth - health;

    if (damageTaken > 0) {
      _spawnFloatingText('-$damageTaken', color: Colors.red);
    }
  }

  void heal(double amount) {
    final oldHealth = health;

    health = (health + amount).clamp(0, maxHealth);

    final healed = health - oldHealth;

    if (healed > 0) {
      _spawnFloatingText('+$healed', color: Colors.green);
    }
  }

  late final StateMachine<Enemy> sm;

  @override
  double get moveSpeed => action == EnemyAction.walk ? 40 : 70;

  @override
  Future<void> onLoad() async {
    anchor = const Anchor(.5, .65);

    final idle = IdleState(duration: 5);
    final patrol = PatrolState(pointCount: 5, radius: 200);
    final chase = ChaseState();
    final combat = CombatState();
    final retreat = RetreatState();
    final dead = DeadState();

    sm = StateMachine(
      owner: this,
      initialState: idle,
      onTransitionStart: (owner, from, to) => print(
        'State Transition [Enemy]: ${from.runtimeType} --> ${to.runtimeType}',
      ),
      transitions: [
        StateTransition.global(
          priority: 999,
          to: dead,
          guard: (_) => health <= 0,
        ),
        StateTransition(
          match: .exact(idle),
          to: patrol,
          guard: (_) => idle.finished,
        ),
        StateTransition(
          match: .exact(patrol),
          to: idle,
          guard: (_) => patrol.finished,
        ),
        StateTransition(
          match: .anyOf([idle, patrol]),
          to: chase,
          guard: (_) => seesPlayer,
        ),
        StateTransition(
          match: .exact(chase),
          to: idle,
          guard: (_) => !seesPlayer,
        ),
        StateTransition(
          match: .exact(chase),
          to: combat,
          guard: (_) => canAttack,
        ),
        StateTransition(
          match: .exact(combat),
          to: chase,
          guard: (_) => !canAttack,
        ),
        StateTransition(
          priority: 10,
          match: .anyOf([idle, patrol, chase, combat]),
          to: retreat,
          guard: (_) => health <= 30 && seesPlayer && retreatWhenLow,
        ),
        StateTransition(
          match: .exact(retreat),
          to: idle,
          guard: (_) => retreat.finished,
        ),
        StateTransition(
          match: .exact(retreat),
          to: chase,
          guard: (_) => health > 50 && seesPlayer,
        ),
      ],
    );

    await add(sm);

    await game.images.loadAll([
      'orc/attack.png',
      'orc/death.png',
      'orc/hurt.png',
      'orc/idle.png',
      'orc/run_attack.png',
      'orc/run.png',
      'orc/walk_attack.png',
      'orc/walk.png',
    ]);

    final spriteSheets = {
      (EnemyAction.idle, false): _createSpriteSheet('orc/idle.png'),
      (EnemyAction.walk, false): _createSpriteSheet('orc/walk.png'),
      (EnemyAction.walk, true): _createSpriteSheet('orc/walk_attack.png'),
      (EnemyAction.run, false): _createSpriteSheet('orc/run.png'),
      (EnemyAction.run, true): _createSpriteSheet('orc/run_attack.png'),
      (EnemyAction.attack, true): _createSpriteSheet('orc/attack.png'),
      (EnemyAction.hurt, false): _createSpriteSheet('orc/hurt.png'),
      (EnemyAction.dead, false): _createSpriteSheet('orc/death.png'),
    };

    animations = {
      for (final state in EnemyAnimation.values)
        state: spriteSheets[(state.action, state.isAttacking)]!.createAnimation(
          row: state.direction.index,
          stepTime: state.action.stepTime,
          to: state.action.frameCount - 1,
          loop: state.action.loop,
        ),
    };

    current = .idleDown;
  }

  EnemyAnimation get animationState => EnemyAnimation.values.firstWhere(
    (state) =>
        state.action == action &&
        state.direction == facing &&
        state.isAttacking == isAttacking,
  );

  @override
  void update(double dt) {
    current = animationState;
    super.update(dt);
  }

  SpriteSheet _createSpriteSheet(String file) =>
      SpriteSheet(image: game.images.fromCache(file), srcSize: .all(64));

  void _spawnFloatingText(String text, {required Color color}) {
    add(
      ParticleSystemComponent(
        particle: AcceleratedParticle(
          lifespan: 1.2,
          acceleration: Vector2(0, -30),
          position: Vector2(width / 2, -10),
          speed: Vector2((Random().nextDouble() - .5) * 15, -20),
          child: ComponentParticle(
            component: TextComponent(
              text: text,
              anchor: .center,
              textRenderer: TextPaint(
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: .bold,
                  fontFamily: 'PixelOperator',
                  shadows: const [
                    Shadow(color: Colors.black, offset: Offset(1, 1)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
