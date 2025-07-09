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
      sm = StateMachine<TestOwner>();
      owner = TestOwner();
      stateA = StateA();
      stateB = StateB();
      stateC = StateC();
    });

    test('Initial state set calls onEnter', () {
      sm.setInitialState(stateA, owner);
      expect(sm.currentState, equals(stateA));
      expect(stateA.entered, isTrue);
    });

    test('Transitions occur based on condition', () {
      sm.setInitialState(stateA, owner);
      sm.addTransition(stateA, stateB, (o) => o.conditionA);

      owner.conditionA = true;
      sm.update(0.1, owner);

      expect(sm.currentState, equals(stateB));
      expect(stateA.exited, isTrue);
      expect(stateB.entered, isTrue);
    });

    test('No transition if condition false', () {
      sm.addTransition(stateA, stateB, (o) => o.conditionA);
      sm.setInitialState(stateA, owner);

      owner.conditionA = false;
      sm.update(0.1, owner);

      expect(sm.currentState, equals(stateA));
      expect(stateA.exited, isFalse);
      expect(stateB.entered, isFalse);
    });

    test('Transitions respect priority', () {
      // Lower priority transition A->B
      sm.addTransition(stateA, stateB, (o) => o.conditionA, priority: 1);

      // Higher priority transition A->C
      sm.addTransition(stateA, stateC, (o) => o.conditionB, priority: 2);

      sm.setInitialState(stateA, owner);

      owner.conditionA = true;
      owner.conditionB = true;

      sm.update(0.1, owner);

      // Because priority 2 is higher, transition to C should trigger first
      expect(sm.currentState, equals(stateC));
      expect(stateC.entered, isTrue);
    });

    test('Reverse transition works', () {
      sm.addTransition(stateA, stateB, (o) => o.conditionA, reverse: true);

      sm.setInitialState(stateA, owner);

      owner.conditionA = true;
      sm.update(0.1, owner);
      expect(sm.currentState, equals(stateB));

      owner.conditionA = false;
      sm.update(0.1, owner);
      expect(sm.currentState, equals(stateA));
    });

    test('Self transition won\'t trigger', () {
      sm.setInitialState(stateA, owner);
      stateA.entered = false;

      sm.addTransition(stateA, stateA, (owner) => owner.conditionA);

      owner.conditionA = true;
      sm.update(0.1, owner);
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
