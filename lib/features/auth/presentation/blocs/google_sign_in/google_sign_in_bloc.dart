import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in_with_google.dart';

part 'google_sign_in_event.dart';
part 'google_sign_in_state.dart';

@injectable
class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  final SignInWithGoogle signInWithGoogle;

  GoogleSignInBloc(this.signInWithGoogle) : super(GoogleSignInInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<GoogleSignInState> emit,
  ) async {
    emit(GoogleSignInLoading());

    try {
      final googleSignIn = GoogleSignIn(
        clientId:
            '792931872361-1cajorgndi4a5jpb7m150u145kpboggs.apps.googleusercontent.com',
        serverClientId:
            '792931872361-sc45u0c4dh0tvsprnat2si7i762jp458.apps.googleusercontent.com',
      );

      final account = await googleSignIn.signIn();
      if (account == null) {
        emit(GoogleSignInFailure("User cancelled sign-in"));
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        emit(GoogleSignInFailure("ID token is null"));
        return;
      }

      // Send ID token to backend
      final user = await signInWithGoogle(SignInGoogleParams(token: idToken));

      emit(GoogleSignInSuccess(user));
    } catch (e) {
      emit(GoogleSignInFailure("Google Sign-In failed: $e"));
    }
  }
}
