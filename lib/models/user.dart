class User {
  final String id;
  final String email;
  final String name;
  final DateTime joinDate;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.joinDate,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      joinDate: DateTime.parse(json['joinDate'] as String),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'joinDate': joinDate.toIso8601String(),
      if (token != null) 'token': token,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? joinDate,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      joinDate: joinDate ?? this.joinDate,
      token: token ?? this.token,
    );
  }
}