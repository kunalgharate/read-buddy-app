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
    if (kDebugMode) {
      print('👤 AppUserModel: Raw JSON: $json');
    }

    // Handle different response structures
    Map<String, dynamic> userData;
    
    if (json.containsKey('user') && json['user'] != null) {
      // Response structure: { "message": "...", "user": { ... } }
      userData = json['user'] as Map<String, dynamic>;
      if (kDebugMode) {
        print('👤 AppUserModel: Using nested user data');
      }
    } else if (json.containsKey('_id') || json.containsKey('id')) {
      // Response structure: { "_id": "...", "name": "...", ... } (direct user data)
      userData = json;
      if (kDebugMode) {
        print('👤 AppUserModel: Using direct user data');
      }
    } else {
      // Fallback: assume the entire json is user data
      userData = json;
      if (kDebugMode) {
        print('👤 AppUserModel: Using fallback user data');
      }
    }

    if (kDebugMode) {
      print('👤 AppUserModel: User data: $userData');
      print('👤 AppUserModel: Access token: ${json['accessToken']}');
      print('👤 AppUserModel: Refresh token: ${json['refreshToken']}');
      print('👤 AppUserModel: isEmailVerified: ${userData['isEmailVerified']}');
    }

    try {
      final model = AppUserModel(
        id: userData['_id'] ?? userData['id'] ?? '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        password: userData['password'] ?? '',
        role: userData['role'] ?? userData['userRole'] ?? 'user',
        isPrime: userData['isPrime'] ?? false,
        finesDue: userData['finesDue'] ?? 0,
        isEmailVerified: userData['isEmailVerified'] ?? false,
        badges: List<dynamic>.from(userData['badges'] ?? []),
        createdAt: _parseDateTime(userData['createdAt']),
        updatedAt: _parseDateTime(userData['updatedAt']),
        version: userData['__v'] ?? 0,
        // Access token and refresh token might be at root level or in user data
        accessToken: json['accessToken'] ?? userData['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? userData['refreshToken'] ?? '',
        picture: userData['picture'],
        phno: userData['phno'],
        gender: userData['gender'],
        wishlist: userData['wishlist'] != null ? List<dynamic>.from(userData['wishlist']) : [],
      );

      if (kDebugMode) {
        print('👤 AppUserModel: Successfully created model');
        print('👤 AppUserModel: ID: ${model.id}');
        print('👤 AppUserModel: Name: ${model.name}');
        print('👤 AppUserModel: Email: ${model.email}');
        print('👤 AppUserModel: Email Verified: ${model.isEmailVerified}');
        print('👤 AppUserModel: Gender: ${model.gender}');
      }

      return model;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('👤 AppUserModel: Error creating model: $e');
        print('👤 AppUserModel: Stack trace: $stackTrace');
        print('👤 AppUserModel: User data that caused error: $userData');
      }
      rethrow;
    }
  }

  /// Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic dateString) {
    if (dateString == null) return DateTime.now();
    if (dateString is String) {
      return DateTime.tryParse(dateString) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'isPrime': isPrime,
      'finesDue': finesDue,
      'isEmailVerified': isEmailVerified,
      'badges': badges,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'picture': picture,
      'phno': phno,
      'gender': gender,
      'wishlist': wishlist,
    };
  }

  /// Create a copy with updated values
  AppUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    bool? isPrime,
    int? finesDue,
    bool? isEmailVerified,
    List<dynamic>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? accessToken,
    String? refreshToken,
    String? picture,
    String? phno,
    String? gender,
    List<dynamic>? wishlist,
  }) {
    return AppUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isPrime: isPrime ?? this.isPrime,
      finesDue: finesDue ?? this.finesDue,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      picture: picture ?? this.picture,
      phno: phno ?? this.phno,
      gender: gender ?? this.gender,
      wishlist: wishlist ?? this.wishlist,
    );
  }
}
