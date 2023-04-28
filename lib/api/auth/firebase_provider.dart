import 'package:attendance/api/auth/exceptions.dart';
import 'package:attendance/api/auth/provider.dart';
import 'package:attendance/api/auth/user.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/extensions/strings.dart';
import 'package:attendance/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart' show Firebase;

class FirebaseAuthProvider implements AuthProvider {
  factory FirebaseAuthProvider() => _shared;
  static final _shared = FirebaseAuthProvider._sharedInstance();
  FirebaseAuthProvider._sharedInstance();

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<void> createUser({
    required String email,
    required String name,
    required String password,
  }) async {
    final cloudService = FirebaseStorage();

    // Validate email domain
    final domain = await cloudService.getDomain;
    bool validDomain = domain.isEmpty;
    for (String dm in domain) {
      validDomain |= email.endsWith(dm);
    }
    if (!validDomain) throw EmailDomainAuthException();

    // Validate device
    final isDeviceInUse = await cloudService.isTheDeviceRegistered;
    if (isDeviceInUse) {
      throw DeviceAlreadyInUseAuthException();
    }

    try {
      final instance =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await instance.user?.sendEmailVerification();
      await instance.user?.updateDisplayName(name.capitalize());

      try {
        final user = currentUser;
        if (user == null) throw UserNotLoggedInAuthException();

        cloudService.createUserInfo(
          userId: user.id,
          userName: user.name ?? "No name",
        );
        cloudService.createUserWorkday(
          userId: user.id,
          userName: user.name ?? "No name",
        );
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.sendEmailVerification();
      } catch (_) {
        throw GenericAuthException();
      }
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
