class AppUser {
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
  final String? picture;
  final String? phno;
  final String? gender;
  final List<dynamic>? wishlist;


  AppUser({
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
    this.picture,
    this.phno,
    this.gender,
    this.wishlist,
  });


}