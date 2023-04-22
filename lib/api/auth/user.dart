import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart' show immutable;

@immutable
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        name: user.displayName,
        isEmailVerified: user.emailVerified,
      );
}
