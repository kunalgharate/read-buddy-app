import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    // Only log in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _debugLog('[Bloc Event] ${bloc.runtimeType} => $event');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // Only log in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _debugLog('[Bloc Transition] ${bloc.runtimeType} => ${transition.currentState} -> ${transition.nextState}');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // Only log in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _debugLog('[Bloc Change] ${bloc.runtimeType} => ${change.currentState} -> ${change.nextState}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // Always log errors, but avoid sensitive information
    _debugLog('[Bloc Error] ${bloc.runtimeType} => ${_sanitizeError(error)}');
    super.onError(bloc, error, stackTrace);
  }

  void _debugLog(String message) {
    // In a real app, you might want to use a proper logging framework
    print(message);
  }

  String _sanitizeError(Object error) {
    final errorString = error.toString();
    // Remove sensitive information from error messages
    return errorString
        .replaceAll(RegExp(r'password["\s]*[:=]["\s]*[^,}\s]*', caseSensitive: false), 'password: [REDACTED]')
        .replaceAll(RegExp(r'token["\s]*[:=]["\s]*[^,}\s]*', caseSensitive: false), 'token: [REDACTED]');
  }
}
