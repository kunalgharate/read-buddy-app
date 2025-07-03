part of 'app_start_bloc.dart';

abstract class AppStartState extends Equatable {
  const AppStartState();

  @override
  List<Object?> get props => [];
}

class AppStartInitial extends AppStartState {}

class UserLoggedIn extends AppStartState {}

class UserLoggedOut extends AppStartState {}
