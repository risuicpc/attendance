import 'package:attendance/constants/routes.dart';
import 'package:attendance/helpers/loading/loading_background.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/screens/attendance/company_calendar.dart';
import 'package:attendance/screens/attendance/location.dart';
import 'package:attendance/screens/attendance/home.dart';
import 'package:attendance/screens/attendance/setting.dart';
import 'package:attendance/screens/attendance/workday_edit.dart';
import 'package:attendance/screens/attendance/workday.dart';
import 'package:attendance/screens/auth/forgot_password.dart';
import 'package:attendance/screens/auth/login.dart';
import 'package:attendance/screens/auth/register.dart';
import 'package:attendance/screens/auth/verify_email.dart';
import 'package:attendance/utils/bloc/block.dart';
import 'package:attendance/utils/bloc/event.dart';
import 'package:attendance/utils/bloc/state.dart';
import 'package:attendance/api/auth/firebase_provider.dart';
import 'package:attendance/api/cloud/user_workday.dart';
import 'package:attendance/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Attendance',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.indigo.shade900,
        secondary: Colors.amber.shade700,
      )),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const BlocPage(),
      ),
      routes: {
        locationRoute: (context) => const Location(),
        settingRoute: (context) => const SettingScreen(),
        workdayListRoute: (context) => const Workday(),
        companyCalendarRoute: (context) => const CompanyCalendar()
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
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    ),
  );
}

class BlocPage extends StatelessWidget {
  const BlocPage({Key? key}) : super(key: key);

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
          return const HomeScreen();
        } else if (state is AuthStateLoggedOut) {
          return const Login();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPassword();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmail();
        } else if (state is AuthStateRegister) {
          return const Register();
        } else {
          return Scaffold(
            appBar: MyAppBar(titleText: ""),
            body: const BackgroundImage(),
          );
        }
      },
    );
  }
}


// internet connection
// google map