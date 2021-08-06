typedef EventCb = Future<void> Function(Map<String, dynamic>? args);
enum YaoEvent { appReady, appError, serviceReady }

class EitherType<A, B> {
  dynamic value;
  EitherType(this.value) {
    if (this.value.runtimeType != A && this.value.runtimeType != B) {
      throw FormatException("Type must be either $A or $B");
    }
  }

  dynamic get() {
    return value;
  }
}

class EventManager {
  final Map<EitherType<String, YaoEvent>, List<EventCb>> _listener = {};

  void on(EitherType<String, YaoEvent> name, EventCb cb) {
    for (final entry in _listener.entries) {
      if (entry.key.get() == name.get()) {
        entry.value.add(cb);
        return;
      }
    }

    _listener[name] = [cb];
  }

  Future<void> emit(EitherType<String, YaoEvent> name,
      [Map<String, dynamic>? args]) async {
    for (final entry in _listener.entries) {
      if (entry.key.get() == name.get()) {
        for (final cb in entry.value) {
          await cb(args);
        }
      }
    }
  }
}
