import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';

import '../../../domain/usecases/sign_in.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

@injectable
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignIn signIn;

  SignInBloc(this.signIn) : super(SignInInitial()) {
    on<SignInRequest>((event, emit) async {

      emit(SignInLoading());
      try {
        final params = SignInParams(
          email: event.email,
          password: event.password,
        );
        final user = await signIn(params);

        print(" user name is : ${user.name}");

        emit(SignInSuccess(user));
      } catch (e) {
        emit(SignInFailure(e.toString()));
      }
    });
  }
}
