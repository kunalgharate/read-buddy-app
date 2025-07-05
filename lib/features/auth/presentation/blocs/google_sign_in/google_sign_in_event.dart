part of 'google_sign_in_bloc.dart';

sealed class GoogleSignInEvent extends Equatable {
  const GoogleSignInEvent();
}

class GoogleSignInRequested extends GoogleSignInEvent {
  const GoogleSignInRequested();
  @override
  List<Object?> get props => [];
  // final String token;
}
