library sync.waitgroup;

import "dart:async";

/// A WaitGroup waits for a collection of processes to finish.
/// The main process calls [add] to set the number of processes to wait for.
/// Then each of the processes runs and calls [done] when finished. At the same
/// time, [wait] can be used to block until all processes have finished.
class WaitGroup {
  int _counter = 0;
  Completer? _completer;

  WaitGroup();

  /// Adds delta, which may be negative, to the WaitGroup counter.
  /// If a wait Future is open and the counter becomes zero, the future is
  /// released.
  /// If the counter goes negative, it throws.
  void add([int amount = 1]) {
    if (_counter + amount < 0) {
      throw new StateError("WaitGroup counter cannot go negative.");
    }
    _counter += amount;
    final completer = _completer;
    if (_counter == 0 && completer != null) {
      completer.complete();
    }
  }

  int get counter => _counter;

  void reset() {
    _counter = 0;
    if (_completer != null) {
      _completer!.complete();
    }
  }

  /// Decrements the WaitGroup counter.
  void done() => add(-1);

  /// Returns a future that will complete when the WaitGroup counter is zero.
  Future wait() {
    if (_counter == 0) {
      return new Future.value();
    }

    final completer = _completer;
    if (completer == null) {
      final completer = Completer();
      _completer = completer;
      return completer.future;
    }
    return completer.future;
  }
}
