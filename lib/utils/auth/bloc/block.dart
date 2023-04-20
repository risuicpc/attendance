import 'package:attendance/utils/auth/bloc/event.dart';
import 'package:attendance/utils/auth/bloc/state.dart';
import 'package:attendance/utils/auth/provider.dart';
import 'package:bloc/bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // Firebase initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    // Start registration
    on<AuthEventNeedRegister>((event, emit) {
      emit(const AuthStateRegister(isLoading: false));
    });

    // Register
    on<AuthEventRegister>((event, emit) async {
      emit(
        const AuthStateRegister(loadingText: "Registering", isLoading: true),
      );
      try {
        await provider.createUser(
          email: event.email,
          name: event.name,
          password: event.password,
        );
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegister(exception: e, isLoading: false));
      }
    });

    // Send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      emit(const AuthStateNeedsVerification(
        isLoading: true,
        loadingText: "Sending",
      ));
      try {
        await provider.sendEmailVerification();
        // ignore: empty_catches
      } on Exception {}
      emit(const AuthStateNeedsVerification(isLoading: false));
    });

// Send password reset
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        hasSentEmail: false,
        isLoading: false,
      ));
      if (event.email == null) {
        return; // user just wants to go to forgot-password screen
      }

      emit(const AuthStateForgotPassword(
        isLoading: true,
        hasSentEmail: false,
        loadingText: "Sending",
      ));

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordResetEmail(email: event.email!);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));
    });

    // Login
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(isLoading: true, loadingText: 'Logging in'),
      );
      try {
        final user = await provider.logIn(
          email: event.email,
          password: event.password,
        );

        if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // Log out
    on<AuthEventLogOut>((event, emit) async {
      if (state is AuthStateLoggedIn) {
        emit(AuthStateLoggedIn(
          user: state.user,
          isLoading: true,
          loadingText: "Logging out",
        ));
      }
      try {
        await Future.delayed(const Duration(seconds: 1));
        await provider.logOut();
        emit(const AuthStateLoggedOut(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
