import 'package:attendance/extensions/velidation/email.dart';
import 'package:attendance/utils/bloc/block.dart';
import 'package:attendance/utils/bloc/event.dart';
import 'package:attendance/utils/bloc/state.dart';
import 'package:attendance/api/auth/exceptions.dart';
import 'package:attendance/helpers/popup_message.dart';
import 'package:attendance/utils/determine_position.dart';
import 'package:attendance/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _name;
  late String _password;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    handlePermission();
  }

  void _submit() {
    if (!_submitted) setState(() => _submitted = true);
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthEventRegister(
              email: _email,
              name: _name,
              password: _password,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateRegister) {
          if (state.exception is WeakPasswordAuthException) {
            showErorr(context,
                "This password is not secure enough. Please choose another password!");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            showErorr(context,
                "This email is already registered to another user. Please choose another email!");
          } else if (state.exception is GenericAuthException) {
            showErorr(context, "Failed to register. Please try again later!");
          } else if (state.exception is InvalidEmailAuthException) {
            showErorr(context,
                "The email address you entered appears to be invalid. Please try another email address!");
          } else if (state.exception is DeviceAlreadyInUseAuthException) {
            showErorr(context,
                "This device is already registered to another user. Kindly utilize a different device!");
          } else if (state.exception is EmailDomainAuthException) {
            showErorr(
                context, "This email address is not allowed to register.");
          }
        }
      },
      child: Scaffold(
        appBar: MyAppBar(titleText: "Register"),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                        "Register with your Toptech email address to manage your attendance."),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Name"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required.';
                        }
                        if (value.length < 2) {
                          return "Name must be at least 2 characters long.";
                        }
                        return null;
                      },
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (text) => setState(() => _name = text),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                        if (value.length < 6) {
                          return "Password should be at least 6 characters.";
                        }
                        return null;
                      },
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (text) => setState(() => _password = text),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Register'),
                    ),
                  ),
                  Row(
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
                        child: const Text('Login'),
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
