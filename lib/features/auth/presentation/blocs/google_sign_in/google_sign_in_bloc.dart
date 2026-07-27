import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

part 'google_sign_in_event.dart';
part 'google_sign_in_state.dart';

/// This BLoC now handles "Sign Up with Google" — it fetches the user's
/// name and email from their Google account so the sign-up form can be
/// pre-filled. It does NOT authenticate with the backend directly.
@injectable
class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  GoogleSignInBloc() : super(GoogleSignInInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<GoogleSignInState> emit,
  ) async {
    emit(GoogleSignInLoading());

    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out first to force account picker
      await googleSignIn.signOut();

      final account = await googleSignIn.signIn();
      if (account == null) {
        emit(const GoogleSignInFailure("Sign-up cancelled"));
        return;
      }

      // Extract profile data from Google account
      final name = account.displayName ?? '';
      final email = account.email;

      // Emit success first — disconnect is best-effort cleanup
      emit(GoogleSignUpDataFetched(name: name, email: email));

      // Best-effort disconnect — don't let failures override the success state
      try {
        await googleSignIn.disconnect();
      } catch (_) {
        // Ignore disconnect errors; the data is already fetched
      }
    } on PlatformException catch (e) {
      String message;
      switch (e.code) {
        case 'sign_in_failed':
          message = 'Google account access failed. Please try again.';
          break;
        case 'network_error':
          message = 'Network error. Please check your connection.';
          break;
        case 'sign_in_canceled':
          message = 'Cancelled.';
          break;
        default:
          message = 'Could not access Google account. Please try again.';
      }
      emit(GoogleSignInFailure(message));
    } catch (e) {
      emit(const GoogleSignInFailure(
          "Could not access Google account. Please try again."));
    }
  }
}
