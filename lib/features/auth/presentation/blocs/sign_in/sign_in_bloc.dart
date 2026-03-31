import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/usecases/sign_in.dart';
import '../../../domain/usecases/send_otp_usecase.dart';
import '../../../domain/usecases/verify_reset_otp_usecase.dart';
import '../../../domain/usecases/change_password_usecase.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

@injectable
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignIn _signIn;
  final SendOtpUseCase _sendOtp;
  final VerifyResetOtpUseCase _verifyResetOtp;
  final ChangePasswordUseCase _changePassword;

  SignInBloc(
      this._signIn,
      this._sendOtp,
      this._verifyResetOtp,
      this._changePassword,
      ) : super(SignInInitial()) {
    on<SignInRequest>(_onSignInRequest);
    on<SendOtpRequested>(_onSendOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<ChangePasswordRequested>(_onChangePassword);
  }

  Future<void> _onSignInRequest(
      SignInRequest event,
      Emitter<SignInState> emit,
      ) async {
    emit(SignInLoading());
    try {
      final params = SignInParams(
        email: event.email.trim().toLowerCase(),
        password: event.password,
      );
      final user = await _signIn(params);
      emit(SignInSuccess(user));
    } catch (error) {
      emit(SignInFailure(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onSendOtp(
      SendOtpRequested event,
      Emitter<SignInState> emit,
      ) async {
    if (kDebugMode) print('🔐 SignInBloc: Sending OTP to ${event.email}');
    emit(SignInLoading());
    try {
      await _sendOtp(event.email);
      emit(OtpSentSuccess(event.email));
    } catch (error) {
      emit(SignInFailure(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onVerifyOtp(
      VerifyOtpRequested event,
      Emitter<SignInState> emit,
      ) async {
    if (kDebugMode) print('🔐 SignInBloc: Verifying OTP for ${event.email}');
    emit(SignInLoading());
    try {
      await _verifyResetOtp(event.email, event.otp);
      emit(OtpVerifiedSuccess());
    } catch (error) {
      emit(SignInFailure(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onChangePassword(
      ChangePasswordRequested event,
      Emitter<SignInState> emit,
      ) async {
    if (kDebugMode) print('🔐 SignInBloc: Changing password for ${event.email}');
    emit(SignInLoading());
    try {
      await _changePassword(event.email, event.code, event.newPassword);
      emit(PasswordChangedSuccess());
    } catch (error) {
      emit(SignInFailure(ErrorHandler.getErrorMessage(error)));
    }
  }
}