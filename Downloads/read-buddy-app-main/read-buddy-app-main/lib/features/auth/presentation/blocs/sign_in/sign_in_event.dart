part of 'sign_in_bloc.dart';


sealed class SignInEvent extends Equatable {
  const SignInEvent();
}

final class SignInRequest extends SignInEvent {
  final String email;
  final String password;

  const SignInRequest({
    required this.email,
    required this.password
  });

  @override
  List<Object?> get props => [email, password];
}