import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/usecases/register_user_usecase.dart';
import '../../../domain/usecases/resend_register_otp_usecase.dart';
import '../../../domain/usecases/verify_email_usecase.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final RegisterUserUseCase _registerUserUseCase;
  final VerifyEmailUseCase _verifyEmailUseCase;
  final ResendRegisterOtpUseCase _resendRegisterOtpUseCase;

  SignUpBloc(
    this._registerUserUseCase,
    this._verifyEmailUseCase,
    this._resendRegisterOtpUseCase,
  ) : super(SignUpInitial()) {
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
      final email = await _registerUserUseCase(event.userData);
      emit(SignUpSuccess(email));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      final isUserExists = ErrorHandler.isUserAlreadyExists(error);

      emit(SignUpError(
        message: isUserExists
            ? 'This email is already registered. Please sign in instead.'
            : (errorMessage.isNotEmpty
                ? errorMessage
                : 'Registration failed. Please try again.'),
        isUserAlreadyExists: isUserExists,
        source: SignUpErrorSource.register,
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
      emit(SignUpError(
        message: errorMessage,
        source: SignUpErrorSource.verifyEmail,
      ));
    }
  }

  Future<void> _onResendVerificationEmail(
    ResendVerificationEmailEvent event,
    Emitter<SignUpState> emit,
  ) async {
    try {
      await _resendRegisterOtpUseCase(event.email);
      emit(ResendVerificationEmailSuccess(event.email));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      final isUserExists = ErrorHandler.isUserAlreadyExists(error);
      emit(SignUpError(
        message: errorMessage,
        isUserAlreadyExists: isUserExists,
        source: SignUpErrorSource.resend,
      ));
    }
  }
}
