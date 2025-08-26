## 2.0.2

* Updated Documentation

## 2.0.1

* Fix Documentation

## 2.0.0

* Make `StateMachine` a Flame `Component` to leverage Flame's lifecycle.
* Removed `HasStates` mixin. It's no longer needed since now update and render methods are managed by Flame.

## 1.2.0

* Added `onRender` callback to `State`, allowing state-specific rendering logic to be executed each frame. ([b2a95f9](https://github.com/bszarlej/flame_state_machine/commit/b2a95f967bc0c3ebd3d8c4c8a28488710e34112c))

## 1.1.0

* Added `onTransition()` callback to `StateMachine` that triggers whenever a state change occurs

## 1.0.5

* Added GitHub Actions CI badge to `README.md`.
* Added `topics` and `issue_tracker` fields to `pubspec.yaml` for improved pub.dev metadata.
* Supressed Linter warning `avoid_print` inside the example.

## 1.0.4

* Fixed: incorrect state parameter was being passed to the `onExit()` callback.

## 1.0.3

* Added state check in `setState` to avoid redundant updates.
* Fixed: `previousState` was not being set properly.
* Improve code readability and consistency.

## 1.0.2

* Refactored internal state transition logic for clarity and reuse (no functional changes).
* Replaced inline state updates with `setState` calls in the `StateMachine` class.
* Added status badges to `README.md` for better project visibility.

## 1.0.1

* Added example
* Updated documentation

## 1.0.0

* Initial release