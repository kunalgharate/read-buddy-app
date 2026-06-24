import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/usecases/register_user_usecase.dart';
import '../../../domain/usecases/verify_email_usecase.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final RegisterUserUseCase _registerUserUseCase;
  final VerifyEmailUseCase _verifyEmailUseCase;

  SignUpBloc(this._registerUserUseCase, this._verifyEmailUseCase)
      : super(SignUpInitial()) {
    on<RegisterUserEvent>(_onRegisterUser);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ResendVerificationEmailEvent>(_onResendVerificationEmail);
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    try {
      final user = await _registerUserUseCase(event.userData);
      emit(SignUpSuccess(user));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      final isUserExists = ErrorHandler.isUserAlreadyExists(error);

      emit(SignUpError(
        message: errorMessage,
        isUserAlreadyExists: isUserExists,
      ));
    }
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    try {
      final user = await _verifyEmailUseCase(event.email, event.code);
      emit(SignUpUserVerified(user));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(SignUpError(message: errorMessage));
    }
  }

  Future<void> _onResendVerificationEmail(
    ResendVerificationEmailEvent event,
    Emitter<SignUpState> emit,
  ) async {
    // Don't emit loading — keep the OTP screen visible during resend.
    try {
      final user = await _registerUserUseCase(event.userData);
      emit(ResendVerificationEmailSuccess(user));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(SignUpError(message: errorMessage));
    }
  }
}
