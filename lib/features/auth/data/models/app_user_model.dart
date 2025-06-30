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
    super.wishlist,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return AppUserModel(
      id: user['_id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      password: user['password'] ?? '',
      role: user['role'] ?? user['userRole'] ?? 'user',
      isPrime: user['isPrime'] ?? false,
      finesDue: user['finesDue'] ?? 0,
      isEmailVerified: user['isEmailVerified'] ?? false,
      badges: List<dynamic>.from(user['badges'] ?? []),
      createdAt: DateTime.tryParse(user['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(user['updatedAt'] ?? '') ?? DateTime.now(),
      version: user['__v'] ?? 0,
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      picture: user['picture'],
      phno: user['phno'],
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
        'badges': badges,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        '__v': version,
        'picture': picture,
        'phno': phno,
        'wishlist': wishlist,
      },
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}