class AuthUser {
  const AuthUser({required this.id, required this.email, required this.token});

  final String id;
  final String email;
  final String token;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    token: json['token'] as String,
  );
}
