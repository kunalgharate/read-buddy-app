part of 'app_start_bloc.dart';

abstract class AppStartEvent extends Equatable {
  const AppStartEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AppStartEvent {}

class LogoutRequested extends AppStartEvent {}
