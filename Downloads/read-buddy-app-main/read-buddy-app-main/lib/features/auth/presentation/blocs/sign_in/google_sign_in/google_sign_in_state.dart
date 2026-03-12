import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';

sealed class GoogleSignInState extends Equatable {
  const GoogleSignInState();

  @override
  List<Object?> get props => [];
}

class GoogleSignInInitial extends GoogleSignInState {}

class GoogleSignInLoading extends GoogleSignInState {}

class GoogleSignInSuccess extends GoogleSignInState {
  final AppUser user;

  const GoogleSignInSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class GoogleSignInFailure extends GoogleSignInState {
  final String errorMessage;

  const GoogleSignInFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
