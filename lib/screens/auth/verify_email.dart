import 'package:attendance/utils/bloc/block.dart';
import 'package:attendance/utils/bloc/event.dart';
import 'package:attendance/utils/bloc/state.dart';
import 'package:attendance/helpers/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateNeedsVerification && !state.isLoading) {
          showSuccess(context, "Email verification link sent successfully!");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Verify email"),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 100),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "We've sent you an email verification. Please open it to verify your account. If you haven't received a verification email yet, press the button below!",
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventSendEmailVerification(),
                          );
                    },
                    child: const Text(
                      "Send email verification",
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text("If you verify your email?"),
                    TextButton(
                      onPressed: () async {
                        context.read<AuthBloc>().add(
                              const AuthEventLogOut(),
                            );
                      },
                      child: const Text("Go to login screen"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
