class ProfileUser {
  final String id;
  final String name;
  final String email;
  final String? phno;
  final String? picture;
  final String? userAvatar; // NEW
  final String role;
  final bool isPrime;
  final int finesDue;
  final bool isEmailVerified;
  final bool onboardingCompleted;
  final List<dynamic> badges;
  final List<dynamic> wishlist;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    this.phno,
    this.picture,
    this.userAvatar, // NEW
    required this.role,
    required this.isPrime,
    required this.finesDue,
    required this.isEmailVerified,
    required this.onboardingCompleted,
    required this.badges,
    required this.wishlist,
    required this.createdAt,
    required this.updatedAt,
  });

  ProfileUser copyWith({String? userAvatar, String? picture}) {
    return ProfileUser(
      id: id,
      name: name,
      email: email,
      phno: phno,
      picture: picture ?? this.picture,
      userAvatar: userAvatar ?? this.userAvatar,
      role: role,
      isPrime: isPrime,
      finesDue: finesDue,
      isEmailVerified: isEmailVerified,
      onboardingCompleted: onboardingCompleted,
      badges: badges,
      wishlist: wishlist,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
