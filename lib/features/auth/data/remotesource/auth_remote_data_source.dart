import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/network_utils.dart';
import '../models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel> signIn(
      {required String email, required String password});
  Future<String> registerUser(Map<String, dynamic> data);
  Future<AppUserModel> verifyEmail(String email, String code);
  Future<AppUserModel> signInWithGoogle({required String token});
  Future<void> sendOtp(String email);
  Future<void> resendRegisterOtp(String email);
  Future<void> verifyResetOtp(String email, String otp);
  Future<void> changePassword(String email, String code, String newPassword);
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('🌐 AuthRemoteDataSource: Starting sign in API call');
      print('🌐 AuthRemoteDataSource: URL: ${ApiConstants.login}');
      print('🌐 AuthRemoteDataSource: Email: $email');
    }

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.login),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (response.statusCode == ApiConstants.success) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Login failed with status: ${response.statusCode}',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> registerUser(Map<String, dynamic> data) async {
    if (kDebugMode) {
      print('🌐 AuthRemoteDataSource: Starting register API call');
      print('🌐 AuthRemoteDataSource: URL: ${ApiConstants.register}');
    }

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.register),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final cleanData = {
        ...data,
        'email': data['email']?.toString().trim().toLowerCase(),
        'name': data['name']?.toString().trim(),
      };

      // Strip empty or null picture — backend requires a valid URL or absent
      if (cleanData['picture'] == null ||
          cleanData['picture'].toString().trim().isEmpty) {
        cleanData.remove('picture');
      }

      final email = cleanData['email'].toString();
      final response = await _dio.post(ApiConstants.register, data: cleanData);
      final responseData = response.data;

      // Backend contract:
      //  201 + full `user` object  -> brand-new user registered (OTP sent)
      //  200 + generic message     -> email already exists (no user object)
      //                              -> resend probe decides verified vs not
      final hasUser = responseData is Map<String, dynamic> &&
          responseData['user'] is Map<String, dynamic>;
      final isNewRegistration =
          response.statusCode == ApiConstants.created && hasUser;

      if (kDebugMode) {
        print('🌐 AuthRemoteDataSource: Register new-user ($isNewRegistration)'
            ' status: ${response.statusCode}');
      }

      if (isNewRegistration) {
        return email;
      }

      if (response.statusCode == ApiConstants.success) {
        // Existing account. The register response cannot distinguish a
        // verified account from an unverified one, but resend-register-otp
        // can: verified accounts answer 400 "already verified and
        // registered"; unverified accounts answer 200 (and an OTP is sent,
        // which the user needs anyway). Only verified accounts proceed to
        // Sign In — never to the OTP screen. Ambiguous probe failures (500,
        // offline, timeout) propagate so the user sees the error instead of
        // an OTP screen with no code sent.
        final isVerified = await _isVerifiedExistingAccount(email);
        if (isVerified) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: Response(
              requestOptions: response.requestOptions,
              statusCode: ApiConstants.forbidden,
              data: responseData,
            ),
            message: 'user already registered',
          );
        }
        return email;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Registration failed',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Probes resend-register-otp to tell a verified existing account apart
  /// from an unverified one.
  ///
  /// Clear outcomes:
  ///  - 200 success (OTP sent)                        -> unverified
  ///  - "already verified and registered" signature   -> verified
  ///
  /// Everything else (500, 429, offline, timeout) is ambiguous: neither a
  /// usable OTP nor the verified signature was observed, so the error is
  /// rethrown to surface to the user instead of silently continuing to the
  /// OTP screen without a code being sent. Note that register created a fresh
  /// OTP only for brand-new accounts (201, which returns before this probe),
  /// so a rate-limited resend here cannot be assumed to mean "an OTP is
  /// still valid" — it must surface like any other probe failure.
  Future<bool> _isVerifiedExistingAccount(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.resendRegisterOtp,
        data: {'email': email},
      );
      // Inspect the response body too: some backends announce a verified
      // account inside a success response instead of an error status, so a
      // verified account must still be redirected to Sign In.
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final message = (data['message'] ?? data['error'] ?? '')
            .toString()
            .toLowerCase();
        if (message.contains('already verified and registered')) return true;
      }
      return false;
    } catch (error) {
      if (error is DioException) {
        final data = error.response?.data;
        final message =
            '${data is Map ? (data['message'] ?? data['error'] ?? '') : ''} '
            '${error.message ?? ''}'
                .toLowerCase();
        if (message.contains('already verified and registered')) {
          return true;
        }
      }
      // Ambiguous failure (500, 429, offline, timeout): surface the error
      // instead of returning false, which would open verification without a
      // usable code ever being sent.
      rethrow;
    }
  }

  @override
  Future<AppUserModel> verifyEmail(String email, String code) async {
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.verifyEmail),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.verifyEmail,
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
        },
      );

      if (response.statusCode == ApiConstants.success) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Email verification failed',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUserModel> signInWithGoogle({required String token}) async {
    if (kDebugMode) {
      print('🌐 AuthRemoteDataSource: Starting Google sign-in API call');
      print('🌐 AuthRemoteDataSource: URL: ${ApiConstants.loginWithGoogle}');
      print('🌐 AuthRemoteDataSource: Token length: ${token.length}');
    }

    try {
      final response = await _dio.post(
        ApiConstants.loginWithGoogle,
        data: {'token': token},
      );

      if (kDebugMode) {
        print(
            '🌐 AuthRemoteDataSource: Google sign-in response status: ${response.statusCode}');
      }

      if (response.statusCode == ApiConstants.success) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Google login failed',
      );
    } catch (e) {
      if (kDebugMode) {
        // Log only the error type, not the message, to avoid leaking any
        // request payload or credentials from the exception.
        print('🌐 AuthRemoteDataSource: Google sign-in failed (${e.runtimeType})');
      }
      rethrow;
    }
  }

  @override
  Future<void> sendOtp(String email) async {
    if (kDebugMode) print('🌐 AuthRemoteDataSource: Sending OTP to $email');

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.resendResetOtp),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.resendResetOtp,
        data: {'email': email.trim().toLowerCase()},
      );

      if (kDebugMode) {
        print('🌐 AuthRemoteDataSource: OTP sent ${response.statusCode}');
      }

      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to send OTP',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyResetOtp(String email, String otp) async {
    if (kDebugMode) print('🌐 AuthRemoteDataSource: Verifying OTP for $email');

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.verifyOtp),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          'email': email.trim().toLowerCase(),
          'code': otp.trim(),
        },
      );

      if (kDebugMode) {
        print('🌐 AuthRemoteDataSource: OTP verified ${response.statusCode}');
      }

      if (response.statusCode != ApiConstants.success) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'OTP verification failed',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(
      String email, String code, String newPassword) async {
    if (kDebugMode) {
      print('🌐 AuthRemoteDataSource: Changing password for $email');
    }

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.changePassword),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
          'newPassword': newPassword,
        },
      );

      if (kDebugMode) {
        print(
            '🌐 AuthRemoteDataSource: Password changed ${response.statusCode}');
      }

      if (response.statusCode != ApiConstants.success) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Password change failed',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendRegisterOtp(String email) async {
    if (kDebugMode) {
      print('🌐 AuthRemoteDataSource: Resending register OTP to $email');
    }

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.resendRegisterOtp),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.resendRegisterOtp,
        data: {'email': email.trim().toLowerCase()},
      );

      if (kDebugMode) {
        print(
            '🌐 AuthRemoteDataSource: Resend register OTP status: ${response.statusCode}');
      }

      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to resend verification email',
        );
      }

      // Some backends answer 200 with an explicit "already verified and
      // registered" body instead of an error status. Match the exact
      // signature so the user is redirected to Sign In rather than left
      // waiting for an OTP that will never arrive.
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final message = (responseData['message'] ??
                responseData['error'] ??
                '')
            .toString()
            .toLowerCase();
        if (message.contains('already verified and registered')) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: Response(
              requestOptions: response.requestOptions,
              statusCode: ApiConstants.forbidden,
              data: responseData,
            ),
            message: 'user already registered',
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
