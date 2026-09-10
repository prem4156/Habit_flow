enum AuthProviderType {
  email('Gmail / Email', '📧'),
  google('Google Account', '🌐'),
  guest('Guest Hunter', '👤');

  final String label;
  final String icon;
  const AuthProviderType(this.label, this.icon);

  static AuthProviderType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'google':
        return AuthProviderType.google;
      case 'guest':
        return AuthProviderType.guest;
      case 'email':
      default:
        return AuthProviderType.email;
    }
  }
}

class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final AuthProviderType provider;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.provider,
    required this.createdAt,
    required this.lastLoginAt,
  });

  bool get isGuest => provider == AuthProviderType.guest;
  bool get isGoogle => provider == AuthProviderType.google;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'provider': provider.name,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt.toIso8601String(),
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    photoUrl: json['photoUrl'] as String?,
    provider: AuthProviderType.fromString(json['provider'] as String? ?? 'email'),
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    lastLoginAt: DateTime.tryParse(json['lastLoginAt'] as String? ?? '') ?? DateTime.now(),
  );

  factory AuthUser.fromFirebaseUser(dynamic user) {
    // Accepts firebase_auth.User or dynamic
    final isAnon = user.isAnonymous == true;
    final email = (user.email as String?) ?? (isAnon ? 'guest@monarch.system' : '');
    final name = (user.displayName as String?) ??
        (isAnon ? 'Guest Hunter' : (email.contains('@') ? email.split('@').first : 'Hunter'));
    final photo = user.photoURL as String?;

    AuthProviderType provider = AuthProviderType.email;
    if (isAnon) {
      provider = AuthProviderType.guest;
    } else {
      final providerData = user.providerData as List<dynamic>? ?? [];
      for (final p in providerData) {
        if (p.providerId == 'google.com') {
          provider = AuthProviderType.google;
          break;
        }
      }
    }

    return AuthUser(
      id: user.uid as String,
      email: email,
      displayName: name.isNotEmpty ? name : 'Hunter',
      photoUrl: photo,
      provider: provider,
      createdAt: user.metadata?.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata?.lastSignInTime ?? DateTime.now(),
    );
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProviderType? provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
