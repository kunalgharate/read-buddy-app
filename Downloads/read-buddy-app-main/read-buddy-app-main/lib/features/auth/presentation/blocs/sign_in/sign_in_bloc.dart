import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/usecases/sign_in.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

@injectable
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignIn _signIn;

  SignInBloc(this._signIn) : super(SignInInitial()) {
    on<SignInRequest>(_onSignInRequest);
  }

  Future<void> _onSignInRequest(
    SignInRequest event,
    Emitter<SignInState> emit,
  ) async {
    if (kDebugMode) {
      print('🔐 SignInBloc: Starting sign in process');
      print('🔐 SignInBloc: Email: ${event.email}');
      print('🔐 SignInBloc: Password length: ${event.password.length}');
    }
    
    emit(SignInLoading());
    
    try {
      final params = SignInParams(
        email: event.email.trim().toLowerCase(),
        password: event.password,
      );
      
      if (kDebugMode) {
        print('🔐 SignInBloc: Calling SignIn use case with params');
        print('🔐 SignInBloc: Cleaned email: ${params.email}');
      }
      
      final user = await _signIn(params);
      
      if (kDebugMode) {
        print('🔐 SignInBloc: Sign in successful');
        print('🔐 SignInBloc: User ID: ${user.id}');
        print('🔐 SignInBloc: User Name: ${user.name}');
        print('🔐 SignInBloc: User Email: ${user.email}');
      }
      
      emit(SignInSuccess(user));
    } catch (error) {
      if (kDebugMode) {
        print('🔐 SignInBloc: Sign in failed');
        print('🔐 SignInBloc: Error type: ${error.runtimeType}');
        print('🔐 SignInBloc: Error details: $error');
      }
      
      final errorMessage = ErrorHandler.getErrorMessage(error);
      
      if (kDebugMode) {
        print('🔐 SignInBloc: Processed error message: $errorMessage');
      }
      
      emit(SignInFailure(errorMessage));
    }
  }
}
