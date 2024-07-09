class User {
  String id;
  String? name;
  String email;
  String code;

  User({required this.id, required this.email, required this.code, this.name});

  String getUserNickName() {
    if (name != null) {
      return "${name}";
    } else {
      return "null";
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'email': email};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        code: json['code'],
        email: json['email']);
  }
}
