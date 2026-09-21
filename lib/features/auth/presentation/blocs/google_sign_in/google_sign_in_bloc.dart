import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/usecases/sign_in_with_google.dart';

part 'google_sign_in_event.dart';
part 'google_sign_in_state.dart';

/// This BLoC handles two distinct Google flows:
///
///  1. [GoogleLoginRequested] (LOGIN screen) — performs REAL authentication:
///     it obtains the Google ID token and exchanges it with the backend via
///     the [SignInWithGoogle] use case, which auto-registers or logs the user
///     in and returns session tokens. On success it emits
///     [GoogleSignInAuthenticated] carrying the authenticated [AppUser] so the
///     caller can persist tokens and navigate like a normal login.
///
///  2. [GoogleSignInRequested] (SIGN-UP screen) — fetches only the account's
///     name/email so the sign-up form can be pre-filled; the user still sets a
///     password to finish. This emits [GoogleSignUpDataFetched] and is kept for
///     backward compatibility with the sign-up page.
@injectable
class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  final SignInWithGoogle _signInWithGoogle;

  GoogleSignInBloc(this._signInWithGoogle) : super(GoogleSignInInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
  }

  /// SIGN-UP pre-fill path — fetches name/email only (no authentication).
  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<GoogleSignInState> emit,
  ) async {
    emit(GoogleSignInLoading());

    try {
      final googleSignIn = _buildGoogleSignIn();

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
      emit(GoogleSignInFailure(_mapPlatformError(e)));
    } catch (e) {
      emit(const GoogleSignInFailure(
          "Could not access Google account. Please try again."));
    }
  }

  /// LOGIN path — real authentication against the backend using the Google
  /// ID token. Auto-registers or logs the user in and returns session tokens.
  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<GoogleSignInState> emit,
  ) async {
    emit(GoogleSignInLoading());

    try {
      final googleSignIn = _buildGoogleSignIn();

      // Sign out first to force the account picker.
      await googleSignIn.signOut();

      final account = await googleSignIn.signIn();
      if (account == null) {
        emit(const GoogleSignInFailure("Sign-in cancelled"));
        return;
      }

      // Obtain the ID token the backend needs to verify the Google identity.
      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        emit(const GoogleSignInFailure(
            "Could not verify your Google account. Please try again."));
        // Best-effort cleanup so a retry re-prompts the picker.
        try {
          await googleSignIn.disconnect();
        } catch (_) {}
        return;
      }

      // Exchange the ID token for an authenticated session (tokens included).
      final user =
          await _signInWithGoogle(SignInGoogleParams(token: idToken));

      emit(GoogleSignInAuthenticated(user));

      // Best-effort disconnect — don't let failures override the success state.
      try {
        await googleSignIn.disconnect();
      } catch (_) {
        // Ignore disconnect errors; authentication already succeeded.
      }
    } on PlatformException catch (e) {
      emit(GoogleSignInFailure(_mapPlatformError(e)));
    } catch (e) {
      emit(GoogleSignInFailure(ErrorHandler.getErrorMessage(e)));
    }
  }

  /// Builds a GoogleSignIn configured with the backend Web client ID as
  /// `serverClientId`, so the plugin returns an idToken with the audience the
  /// backend verifies (backend GOOGLE_CLIENT_ID). Falls back to no
  /// serverClientId if not configured (id token won't be backend-verifiable).
  GoogleSignIn _buildGoogleSignIn() {
    final serverClientId = AppConfig.isInitialized
        ? AppConfig.instance.googleServerClientId
        : '';
    final valid = serverClientId.isNotEmpty &&
        !serverClientId.startsWith('PASTE_');
    return GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: valid ? serverClientId : null,
    );
  }

  String _mapPlatformError(PlatformException e) {
    switch (e.code) {
      case 'sign_in_failed':
        return 'Google account access failed. Please try again.';
      case 'network_error':
        return 'Network error. Please check your connection.';
      case 'sign_in_canceled':
        return 'Cancelled.';
      default:
        return 'Could not access Google account. Please try again.';
    }
  }
}
