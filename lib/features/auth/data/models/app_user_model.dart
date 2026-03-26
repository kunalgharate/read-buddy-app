import 'package:flutter/foundation.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  AppUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.password,
    required super.role,
    required super.isPrime,
    required super.finesDue,
    required super.isEmailVerified,
    required super.onboardingCompleted, // ← ADDED
    required super.badges,
    required super.createdAt,
    required super.updatedAt,
    required super.version,
    required super.accessToken,
    required super.refreshToken,
    super.picture,
    super.phno,
    super.gender,
    super.wishlist,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    if (kDebugMode) {
      print('👤 AppUserModel: User data: $user');
      print('👤 AppUserModel: Access token: ${json['accessToken']}');
      print('👤 AppUserModel: Refresh token: ${json['refreshToken']}');
      print('👤 AppUserModel: isEmailVerified: ${user['isEmailVerified']}');
      print(
          '👤 AppUserModel: onboardingCompleted: ${user['onboardingCompleted']}'); // ← ADDED
    }

    return AppUserModel(
      id: user['_id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      password: user['password'] ?? '',
      role: user['role'] ?? user['userRole'] ?? 'user',
      isPrime: user['isPrime'] ?? false,
      finesDue: user['finesDue'] ?? 0,
      isEmailVerified: user['isEmailVerified'] ?? false,
      onboardingCompleted: user['onboardingCompleted'] ?? false, // ← ADDED
      badges: List<dynamic>.from(user['badges'] ?? []),
      createdAt: DateTime.tryParse(user['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(user['updatedAt'] ?? '') ?? DateTime.now(),
      version: user['__v'] ?? 0,
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      picture: user['picture'],
      phno: user['phno'],
      gender: user['gender'],
      wishlist: user['wishlist'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {
        '_id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'isPrime': isPrime,
        'finesDue': finesDue,
        'isEmailVerified': isEmailVerified,
        'onboardingCompleted': onboardingCompleted, // ← ADDED
        'badges': badges,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        '__v': version,
        'picture': picture,
        'phno': phno,
        'gender': gender,
        'wishlist': wishlist,
      },
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
