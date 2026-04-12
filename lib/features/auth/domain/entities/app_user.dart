class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final bool isPrime;
  final int finesDue;
  final bool isEmailVerified;
  final bool onboardingCompleted;
  final List<dynamic> badges;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String accessToken;
  final String refreshToken;
  final String? picture;
  final String? phno;
  final String? gender;
  final List<dynamic>? wishlist;
  final String? userAvatar; // ← ADDED

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.isPrime,
    required this.finesDue,
    required this.isEmailVerified,
    required this.onboardingCompleted,
    required this.badges,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.accessToken,
    required this.refreshToken,
    this.picture,
    this.phno,
    this.gender,
    this.wishlist,
    this.userAvatar, // ← ADDED
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Support both flat response and nested { user: {...}, accessToken, refreshToken }
    final Map<String, dynamic> u =
        json['user'] != null ? json['user'] as Map<String, dynamic> : json;

    return AppUser(
      id: u['_id']?.toString() ?? u['id']?.toString() ?? '',
      name: u['name']?.toString() ?? '',
      email: u['email']?.toString() ?? '',
      password: u['password']?.toString() ?? '',
      role: u['role']?.toString() ?? 'user',
      isPrime: u['isPrime'] as bool? ?? false,
      finesDue: (u['finesDue'] as num?)?.toInt() ?? 0,
      isEmailVerified: u['isEmailVerified'] as bool? ?? false,
      onboardingCompleted: u['onboardingCompleted'] as bool? ?? false,
      badges: u['badges'] as List<dynamic>? ?? [],
      createdAt: u['createdAt'] != null
          ? DateTime.tryParse(u['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: u['updatedAt'] != null
          ? DateTime.tryParse(u['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      version: (u['__v'] as num?)?.toInt() ?? 0,
      // tokens can live at the root level or inside user object
      accessToken:
          json['accessToken']?.toString() ?? u['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ??
          u['refreshToken']?.toString() ??
          '',
      picture: u['picture']?.toString(),
      phno: u['phno']?.toString(),
      gender: u['gender']?.toString(),
      wishlist: u['wishlist'] as List<dynamic>?,
      userAvatar: u['userAvatar']?.toString(), // ← ADDED
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'isPrime': isPrime,
        'finesDue': finesDue,
        'isEmailVerified': isEmailVerified,
        'onboardingCompleted': onboardingCompleted,
        'badges': badges,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'picture': picture,
        'phno': phno,
        'gender': gender,
        'wishlist': wishlist,
        'userAvatar': userAvatar,
      };
}
