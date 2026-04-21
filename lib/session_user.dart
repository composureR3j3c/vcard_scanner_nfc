class SessionUser {
  const SessionUser({
    required this.id,
    required this.localId,
    required this.username,
    required this.name,
    required this.email,
  });

  final String id;
  final String localId;
  final String username;
  final String name;
  final String email;

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      id: (json['id'] as String? ?? '').trim(),
      localId: (json['localId'] as String? ?? '').trim(),
      username: (json['username'] as String? ?? '').trim(),
      name: (json['name'] as String? ?? '').trim(),
      email: (json['email'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localId': localId,
      'username': username,
      'name': name,
      'email': email,
    };
  }
}
