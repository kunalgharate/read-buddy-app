import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
    emit(SignInLoading());

    try {
      final params = SignInParams(
        email: event.email.trim().toLowerCase(),
        password: event.password,
      );

      final user = await _signIn(params);
      emit(SignInSuccess(user));
    } catch (error) {
      final errorMessage = ErrorHandler.getErrorMessage(error);
      emit(SignInFailure(errorMessage));
    }
  }
}
