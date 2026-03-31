
import '../../domain/entities/user_profile.dart';

class ProfileUserModel extends ProfileUser {
  const ProfileUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phno,
    super.picture,
    required super.role,
    required super.isPrime,
    required super.finesDue,
    super.userAvatar,
    required super.isEmailVerified,
    required super.onboardingCompleted,
    required super.badges,
    required super.wishlist,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    return ProfileUserModel(
      id: user['_id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      phno: user['phno'],
      picture: user['picture'],
      role: user['userRole'] ?? user['role'] ?? 'user',
      isPrime: user['isPrime'] ?? false,
      finesDue: user['finesDue'] ?? 0,
      userAvatar: user['userAvatar'],
      isEmailVerified: user['isEmailVerified'] ?? false,
      onboardingCompleted: user['onboardingCompleted'] ?? false,
      badges: List<dynamic>.from(user['badges'] ?? []),
      wishlist: List<dynamic>.from(user['wishlist'] ?? []),
      createdAt: DateTime.tryParse(user['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(user['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}