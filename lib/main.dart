import 'package:attendance/constants/routes.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/screens/attendance/location.dart';
import 'package:attendance/screens/attendance/dashboard.dart';
import 'package:attendance/screens/attendance/setting.dart';
import 'package:attendance/screens/attendance/workday_edit.dart';
import 'package:attendance/screens/attendance/workday.dart';
import 'package:attendance/screens/auth/forgot_password.dart';
import 'package:attendance/screens/auth/login.dart';
import 'package:attendance/screens/auth/register.dart';
import 'package:attendance/screens/auth/verify_email.dart';
import 'package:attendance/utils/auth/bloc/block.dart';
import 'package:attendance/utils/auth/bloc/event.dart';
import 'package:attendance/utils/auth/bloc/state.dart';
import 'package:attendance/utils/auth/firebase_provider.dart';
import 'package:attendance/utils/cloud/user_workday.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        locationRoute: (context) => const Location(),
        settingRoute: (context) => const Setting(),
        workdayListRoute: (context) => const Workday(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == workdayEditRoute) {
          final args = settings.arguments as UserWorkday;
          return MaterialPageRoute(
            builder: (context) {
              return WorkdayEdit(
                workday: args,
              );
            },
          );
        }
        // The code only supports
        // PassArgumentsScreen.routeName right now.
        // Other values need to be implemented if we
        // add them. The assertion here will help remind
        // us of that higher up in the call stack, since
        // this assertion would otherwise fire somewhere
        // in the framework.
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const Attendance();
        } else if (state is AuthStateLoggedOut) {
          return const Login();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPassword();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmail();
        } else if (state is AuthStateRegister) {
          return const Register();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
