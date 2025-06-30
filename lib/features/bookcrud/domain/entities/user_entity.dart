class UserEntity {
  final String userRole;
  final bool isEmailVerified;
  final String id;
  final String name;
  final String email;
  final String authType;
  final String socialId;
  final String phone;
  final String pincode;
  final String city;
  final bool isPrime;
  final DateTime? membershipExpires;
  final int finesDue;
  final List<String> badges;

  const UserEntity({
    required this.userRole,
    required this.isEmailVerified,
    required this.id,
    required this.name,
    required this.email,
    required this.authType,
    required this.socialId,
    required this.phone,
    required this.pincode,
    required this.city,
    required this.isPrime,
    required this.membershipExpires,
    required this.finesDue,
    required this.badges,
  });

  static empty() {}
}
