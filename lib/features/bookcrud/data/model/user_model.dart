import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String userRole,
    required bool isEmailVerified,
    required String id,
    required String name,
    required String email,
    required String authType,
    required String socialId,
    required String phone,
    required String pincode,
    required String city,
    required bool isPrime,
    required DateTime? membershipExpires,
    required int finesDue,
    required List<String> badges,
  }) : super(
          userRole: userRole,
          isEmailVerified: isEmailVerified,
          id: id,
          name: name,
          email: email,
          authType: authType,
          socialId: socialId,
          phone: phone,
          pincode: pincode,
          city: city,
          isPrime: isPrime,
          membershipExpires: membershipExpires,
          finesDue: finesDue,
          badges: badges,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userRole: json['userRole'],
      isEmailVerified: json['isEmailVerified'],
      id: json['_id'],
      name: json['name'],
      email: json['email'] ?? "",
      authType: json['authType'] ?? "",
      socialId: json['socialId'] ?? "",
      phone: json['phone'] ?? "",
      pincode: json['pincode'] ?? "",
      city: json['city'] ?? "",
      isPrime: json['isPrime'] ?? "",
      membershipExpires: json['membershipExpires'] != null
          ? DateTime.tryParse(json['membershipExpires'])
          : null,
      finesDue: json['finesDue'],
      badges: List<String>.from(json['badges']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userRole': userRole,
      'isEmailVerified': isEmailVerified,
      '_id': id,
      'name': name,
      'email': email,
      'authType': authType,
      'socialId': socialId,
      'phone': phone,
      'pincode': pincode,
      'city': city,
      'isPrime': isPrime,
      'membershipExpires': membershipExpires?.toIso8601String(),
      'finesDue': finesDue,
      'badges': badges,
    };
  }
}
