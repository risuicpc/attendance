import 'package:attendance/utils/auth/user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  Future<AuthUser> createUser({
    required String email,
    required String name,
    required String password,
  });
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail({required String email});
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  AuthUser? get currentUser;
  Future<void> logOut();
}
