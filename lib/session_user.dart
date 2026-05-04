class SessionUser {
  const SessionUser({
    required this.id,
    required this.localId,
    required this.username,
    required this.name,
    required this.email,
    this.accessToken = '',
    this.refreshToken = '',
  });

  final String id;
  final String localId;
  final String username;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      id: (json['id'] as String? ?? '').trim(),
      localId:
          (json['localId'] as String? ?? json['centralId'] as String? ?? '')
              .trim(),
      username: (json['username'] as String? ?? '').trim(),
      name: (json['name'] as String? ?? '').trim(),
      email: (json['email'] as String? ?? '').trim(),
      accessToken: (json['accessToken'] as String? ?? '').trim(),
      refreshToken: (json['refreshToken'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localId': localId,
      'username': username,
      'name': name,
      'email': email,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  SessionUser copyWith({String? accessToken, String? refreshToken}) {
    return SessionUser(
      id: id,
      localId: localId,
      username: username,
      name: name,
      email: email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
