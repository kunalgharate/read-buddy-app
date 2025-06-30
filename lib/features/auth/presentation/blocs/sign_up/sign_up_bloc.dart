import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/usecases/register_user_usecase.dart';
import '../../../domain/usecases/verify_email_usecase.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final RegisterUserUseCase registerUserUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;

  SignUpBloc(this.registerUserUseCase, this.verifyEmailUseCase)
      : super(SignUpInitial()) {
    on<RegisterUserEvent>((event, emit) async {
      emit(SignUpLoading());
      try {
        final user = await registerUserUseCase(event.userData);
        emit(SignUpSuccess(user));
      } catch (e) {
        emit(SignUpError(e.toString()));
      }
    });

    on<VerifyEmailEvent>((event, emit) async {
      emit(SignUpLoading());
      try {
        final user = await verifyEmailUseCase(event.email, event.code);
        emit(SignUpUserVerified(user));
      } catch (e) {
        emit(SignUpError(e.toString()));
      }
    });
  }
}
