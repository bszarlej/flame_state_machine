import 'package:flame_state_machine/flame_state_machine.dart';
import 'package:test/test.dart';

void main() {
  group('StateMachine Tests', () {
    late StateMachine<TestOwner> sm;
    late TestOwner owner;
    late StateA stateA;
    late StateB stateB;
    late StateC stateC;

    setUp(() {
      owner = TestOwner();
      sm = StateMachine<TestOwner>(owner: owner, initialState: null);
      stateA = StateA();
      stateB = StateB();
      stateC = StateC();
    });

    test('Initial state set calls onEnter', () {
      sm.setState(stateA);
      expect(sm.currentState, equals(stateA));
      expect(stateA.entered, isTrue);
    });

    test('Transitions occur based on condition', () {
      sm.setState(stateA);
      sm.register(from: stateA, to: stateB, guard: (o) => o.conditionA);

      owner.conditionA = true;
      sm.update(0.1);

      expect(sm.currentState, equals(stateB));
      expect(stateA.exited, isTrue);
      expect(stateB.entered, isTrue);
    });

    test('No transition if condition false', () {
      sm.register(from: stateA, to: stateB, guard: (o) => o.conditionA);
      sm.setState(stateA);

      owner.conditionA = false;
      sm.update(0.1);

      expect(sm.currentState, equals(stateA));
      expect(stateA.exited, isFalse);
      expect(stateB.entered, isFalse);
    });

    test('Transitions respect priority', () {
      // Lower priority transition A->B
      sm.register(
        from: stateA,
        to: stateB,
        guard: (o) => o.conditionA,
        priority: 1,
      );

      // Higher priority transition A->C
      sm.register(
        from: stateA,
        to: stateC,
        guard: (o) => o.conditionB,
        priority: 2,
      );

      sm.setState(stateA);

      owner.conditionA = true;
      owner.conditionB = true;

      sm.update(0.1);

      // Because priority 2 is higher, transition to C should trigger first
      expect(sm.currentState, equals(stateC));
      expect(stateC.entered, isTrue);
    });

    test('Reverse transition works', () {
      sm.register(
        from: stateA,
        to: stateB,
        guard: (o) => o.conditionA,
        reverse: true,
      );

      sm.setState(stateA);

      owner.conditionA = true;
      sm.update(0.1);
      expect(sm.currentState, equals(stateB));

      owner.conditionA = false;
      sm.update(0.1);
      expect(sm.currentState, equals(stateA));
    });

    test('Global reverse transition returns to previous state', () {
      sm.register(
        to: stateC,
        guard: (owner) => owner.conditionB,
        reverse: true,
      );

      sm.setState(stateA);
      owner.conditionB = true;

      sm.update(0.1);

      expect(sm.currentState, equals(stateC));
      expect(stateC.entered, isTrue);

      owner.conditionB = false;

      sm.update(0.1);

      expect(sm.currentState, equals(stateA));
      expect(stateA.entered, isTrue);
    });

    test('Self transition won\'t trigger', () {
      sm.setState(stateA);
      stateA.entered = false;

      sm.register(from: stateA, to: stateA, guard: (owner) => owner.conditionA);

      owner.conditionA = true;
      sm.update(0.1);
      expect(stateA.entered, isFalse);
    });
  });
}

class StateA extends State<TestOwner> {
  bool entered = false;
  bool exited = false;

  @override
  void onEnter(TestOwner owner, [State<TestOwner>? from]) {
    entered = true;
  }

  @override
  void onExit(TestOwner owner, [State<TestOwner>? to]) {
    exited = true;
  }

  @override
  void onUpdate(double dt, TestOwner owner) {}
}

class StateB extends State<TestOwner> {
  bool entered = false;
  bool exited = false;

  @override
  void onEnter(TestOwner owner, [State<TestOwner>? from]) {
    entered = true;
  }

  @override
  void onExit(TestOwner owner, [State<TestOwner>? to]) {
    exited = true;
  }

  @override
  void onUpdate(double dt, TestOwner owner) {}
}

class StateC extends State<TestOwner> {
  bool entered = false;
  bool exited = false;

  @override
  void onEnter(TestOwner owner, [State<TestOwner>? from]) {
    entered = true;
  }

  @override
  void onExit(TestOwner owner, [State<TestOwner>? to]) {
    exited = true;
  }

  @override
  void onUpdate(double dt, TestOwner owner) {}
}

class TestOwner {
  bool conditionA = false;
  bool conditionB = false;
}
