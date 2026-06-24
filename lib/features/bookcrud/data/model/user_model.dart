import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.userRole,
    required super.isEmailVerified,
    required super.id,
    required super.name,
    required super.email,
    required super.authType,
    required super.socialId,
    required super.phone,
    required super.pincode,
    required super.city,
    required super.isPrime,
    required super.membershipExpires,
    required super.finesDue,
    required super.badges,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userRole: json['userRole'] ?? 'user',
      isEmailVerified: json['isEmailVerified'] ?? false,
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      authType: json['authType'] ?? '',
      socialId: json['socialId'] ?? '',
      phone: json['phone'] ?? '',
      pincode: json['pincode'] ?? '',
      city: json['city'] ?? '',
      isPrime: json['isPrime'] ?? false,
      membershipExpires: json['membershipExpires'] != null
          ? DateTime.tryParse(json['membershipExpires'].toString())
          : null,
      finesDue: json['finesDue'] ?? 0,
      badges:
          json['badges'] != null ? List<String>.from(json['badges']) : const [],
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
