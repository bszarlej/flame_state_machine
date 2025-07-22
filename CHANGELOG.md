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