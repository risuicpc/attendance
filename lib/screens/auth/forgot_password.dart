import 'package:attendance/extensions/velidation/email.dart';
import 'package:attendance/utils/auth/bloc/block.dart';
import 'package:attendance/utils/auth/bloc/event.dart';
import 'package:attendance/utils/auth/bloc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController();
  late bool hasSentEmail = false;
  final String sentMessage =
      "We have sent a password reset link to your_email. Please check your email for further instructions. In case you do not see it in your primary inbox, please check your spam folder or other email folders.";
  late String email;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            setState(() {
              hasSentEmail = true;
              email = _email.text;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Password reset link sent successfully!'),
              ),
            );
            _email.clear();
          }
          if (state.exception != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                    "We could not process your request. Please make sure that you are a registered user!"),
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Forgot Password"),
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
                    "If you forgot your password, simply enter your email and we will send you a password reset link.",
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 32),
                    child: TextFormField(
                      autocorrect: false,
                      enableSuggestions: false,
                      controller: _email,
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                AuthEventForgotPassword(
                                  email: _email.text,
                                ),
                              );
                        }
                      },
                      child: const Text('Send me password reset link'),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text("If you reset your password?"),
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  const AuthEventLogOut(),
                                );
                          },
                          child: const Text('Back to login screen'),
                        ),
                      ],
                    ),
                  ),
                  hasSentEmail
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.amber,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 16, top: 8),
                                child: Text(
                                  sentMessage.replaceFirst(
                                    "your_email",
                                    email,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Text("")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
