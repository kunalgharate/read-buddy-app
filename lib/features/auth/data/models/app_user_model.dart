import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';
import 'package:read_buddy_app/features/auth/domain/entities/user.dart';

/// user : {"userRole":"user","isPrime":false,"finesDue":0,"isEmailVerified":false,"_id":"6820e04f2df88c58db03bc35","name":"firstuser","email":"second@gmail.com","password":"$2b$10$/YcSuYkZJNU0ZpPJkBYgCORENSDi5Wgi7GaKysNiEiREiYEOjTLiW","role":"user","badges":[],"createdAt":"2025-05-11T17:37:19.374Z","updatedAt":"2025-05-11T17:37:19.374Z","__v":0}
/// accessToken : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODIwZTA0ZjJkZjg4YzU4ZGIwM2JjMzUiLCJpYXQiOjE3NDkzODE5ODAsImV4cCI6MTc0OTM4NTU4MH0.lpTDAtpAjEogZ_FU815MvmQTX684GTvUptEQswIfuMQ"
/// refreshToken : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODIwZTA0ZjJkZjg4YzU4ZGIwM2JjMzUiLCJpYXQiOjE3NDkzODE5ODAsImV4cCI6MTc1MTk3Mzk4MH0.QFGetnxNIewosVa4eiUum9XAvJWc5MQ8otGpMl6d-2Y"

class AppUserModel extends AppUser{
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final bool isPrime;
  final int finesDue;
  final bool isEmailVerified;
  final List<dynamic> badges;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String accessToken;
  final String refreshToken;

  AppUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.isPrime,
    required this.finesDue,
    required this.isEmailVerified,
    required this.badges,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.accessToken,
    required this.refreshToken,
  }) :super(id: '', name: '', email: '', password: '', role: '', isPrime: false, finesDue: 0, isEmailVerified: false, badges: [], createdAt: DateTime.now(), updatedAt: DateTime.now(), version: 0, accessToken: '', refreshToken: '');

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
      createdAt: DateTime.parse(user['createdAt']),
      updatedAt: DateTime.parse(user['updatedAt']),
      version: user['__v'] ?? 0,
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
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
      },
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}