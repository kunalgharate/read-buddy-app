/// userRole : "user"
/// isPrime : false
/// finesDue : 0
/// isEmailVerified : false
/// _id : "6820e04f2df88c58db03bc35"
/// name : "firstuser"
/// email : "second@gmail.com"
/// password : "$2b$10$/YcSuYkZJNU0ZpPJkBYgCORENSDi5Wgi7GaKysNiEiREiYEOjTLiW"
/// role : "user"
/// badges : []
/// createdAt : "2025-05-11T17:37:19.374Z"
/// updatedAt : "2025-05-11T17:37:19.374Z"
/// __v : 0

class User {
  User({
    required String userRole,
    required bool isPrime,
    required num finesDue,
    bool isEmailVerified =false,
    required String id,
    required String name,
    required String email,
    required String role,
    required String createdAt,
    required String updatedAt,})
  {
    _userRole = userRole;
    _isPrime = isPrime;
    _finesDue = finesDue;
    _isEmailVerified = isEmailVerified;
    _id = id;
    _name = name;
    _email = email;
    _role = role;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  User.fromJson(dynamic json) {
    _userRole = json['userRole'];
    _isPrime = json['isPrime'];
    _finesDue = json['finesDue'];
    _isEmailVerified = json['isEmailVerified'];
    _id = json['_id'];
    _name = json['name'];
    _email = json['email'];
    _role = json['role'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }


 late final String _userRole;
  late final bool _isPrime;
  late final num _finesDue;
  late final bool _isEmailVerified;
  late final String _id;
  late final String _name;
  late final String _email;
  late final String _role;
  late final String _createdAt;
  late final String _updatedAt;


  User copyWith({  required String userRole,
    required bool isPrime,
    required num finesDue,
    required bool isEmailVerified,
    required String id,
    required String name,
    required String email,
    required String password,
    required String role,
    required String createdAt,
    required String updatedAt,
  }) => User(  userRole: userRole,
    isPrime: isPrime,
    finesDue: finesDue,
    isEmailVerified: isEmailVerified,
    id: id,
    name: name,
    email: email,
    role: role,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  String get userRole => _userRole;
  bool get isPrime => _isPrime;
  num get finesDue => _finesDue;
  bool get isEmailVerified => _isEmailVerified;
  String get id => _id;
  String get name => _name;
  String get email => _email;
  String get role => _role;
  String get createdAt => _createdAt;
  String get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userRole'] = _userRole;
    map['isPrime'] = _isPrime;
    map['finesDue'] = _finesDue;
    map['isEmailVerified'] = _isEmailVerified;
    map['_id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['role'] = _role;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}