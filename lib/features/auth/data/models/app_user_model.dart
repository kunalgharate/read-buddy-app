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
    final Map<String, dynamic> user =
        json['user'] != null ? json['user'] as Map<String, dynamic> : json;

    if (kDebugMode) {
      print('👤 AppUserModel: Parsed user id: ${user['_id'] ?? user['id']}');
      print('👤 AppUserModel: isEmailVerified: ${user['isEmailVerified']}');
      print(
          '👤 AppUserModel: onboardingCompleted: ${user['onboardingCompleted']}');
    }

    return AppUserModel(
      id: (user['_id'] ?? user['id'] ?? '').toString(),
      name: (user['name'] ?? '').toString(),
      email: (user['email'] ?? '').toString(),
      password: (user['password'] ?? '').toString(),
      role: (user['role'] ?? user['userRole'] ?? 'user').toString(),
      isPrime: user['isPrime'] as bool? ?? false,
      finesDue: (user['finesDue'] as num?)?.toInt() ?? 0,
      isEmailVerified: user['isEmailVerified'] as bool? ?? false,
      onboardingCompleted: user['onboardingCompleted'] as bool? ?? false,
      badges: List<dynamic>.from(user['badges'] ?? []),
      createdAt: DateTime.tryParse((user['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((user['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
      version: (user['__v'] as num?)?.toInt() ?? 0,
      accessToken:
          (json['accessToken'] ?? user['accessToken'] ?? '').toString(),
      refreshToken:
          (json['refreshToken'] ?? user['refreshToken'] ?? '').toString(),
      picture: user['picture']?.toString(),
      phno: user['phno']?.toString(),
      gender: user['gender']?.toString(),
      wishlist: user['wishlist'] as List<dynamic>?,
    );
  }

  @override
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
