class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: _readString(json['id']) ?? '',
      email: _readString(json['email']) ?? '',
      displayName:
          _readString(json['displayName']) ??
          _readString(json['name']) ??
          _readString(json['email']) ??
          'Learner',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'displayName': displayName};
  }

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final letters = parts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0]);
    final result = letters.join();
    return result.isEmpty ? 'U' : result.toUpperCase();
  }
}

class AuthSession {
  const AuthSession({
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  final String? accessToken;
  final String? refreshToken;
  final String? accessTokenExpiresAt;
  final String? refreshTokenExpiresAt;

  bool get hasAccessToken => accessToken != null && accessToken!.isNotEmpty;

  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;
}

class AuthResult {
  const AuthResult({required this.session, required this.user});

  final AuthSession session;
  final AuthUser user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      session: AuthSession(
        accessToken: _readString(json['accessToken']),
        refreshToken: _readString(json['refreshToken']),
        accessTokenExpiresAt: _readString(json['accessTokenExpiresAt']),
        refreshTokenExpiresAt: _readString(json['refreshTokenExpiresAt']),
      ),
      user: AuthUser.fromJson(
        (json['user'] is Map ? json['user'] as Map : <Object?, Object?>{}).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      ),
    );
  }
}

enum AuthStatus { loading, authenticated, unauthenticated }

String? _readString(Object? value) {
  final trimmed = value?.toString().trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
