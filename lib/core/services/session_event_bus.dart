import 'dart:async';

/// Global stream for session-level events that need UI response.
/// Used by interceptor (no BuildContext) to notify the app shell.
class SessionEventBus {
  SessionEventBus._();
  static final instance = SessionEventBus._();

  final _controller = StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get stream => _controller.stream;

  void fire(SessionEvent event) => _controller.add(event);
}

enum SessionEvent {
  sessionReplaced,
  primeRequired,
}
