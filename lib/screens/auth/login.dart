import 'package:attendance/extensions/velidation/email.dart';
import 'package:attendance/utils/bloc/block.dart';
import 'package:attendance/utils/bloc/event.dart';
import 'package:attendance/utils/bloc/state.dart';
import 'package:attendance/api/auth/exceptions.dart';
import 'package:attendance/helpers/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  bool _submitted = false;

  void _submit() {
    if (!_submitted) setState(() => _submitted = true);
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthEventLogIn(
              _email,
              _password,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedOut) {
          if (state.exception is WrongPasswordAuthException) {
            showErorr(context, "Incorrect credentials!");
          } else if (state.exception is UserNotFoundAuthException) {
            showErorr(
                context, "Cannot find a user with the entered credentials!");
          } else if (state.exception is InvalidEmailAuthException) {
            showErorr(context,
                "The email address you entered appears to be invalid. Please try another email address!");
          } else if (state.exception is GenericAuthException) {
            showErorr(context, "Authentication failed!");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 100),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Log in with",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 32),
                    child: TextFormField(
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Email Address"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required.';
                        }
                        if (value.isNotValidEmail()) {
                          return "Enter valid email address.";
                        }
                        return null;
                      },
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (text) => setState(() => _email = text),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Password"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }
                        return null;
                      },
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (text) => setState(() => _password = text),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Login'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventForgotPassword());
                        },
                        child: const Text('Forgot password'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventNeedRegister());
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
