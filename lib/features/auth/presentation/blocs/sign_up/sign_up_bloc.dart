import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
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
}
