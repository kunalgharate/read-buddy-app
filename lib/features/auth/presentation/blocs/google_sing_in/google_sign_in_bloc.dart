import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/google_sing_in/google_sign_in_event.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/google_sing_in/google_sign_in_state.dart';

class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  final SignInWithGoogleUseCase signInWithGoogle;

  GoogleSignInBloc(this.signInWithGoogle) : super(GoogleSignInInitial()) {
    on<GoogleSignInRequested>((event, emit) async {
      emit(GoogleSignInLoading());

      try {
        final user = await signInWithGoogle();
        emit(GoogleSignInSuccess(user));
      } catch (e) {
        emit(GoogleSignInFailure(e.toString()));
      }
    });
  }
}
