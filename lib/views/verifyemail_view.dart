import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Verification')),
      body: Column(
        children: [
          const Text("Verify your email address"),
          TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                devtools.log(user.toString());
                await user?.sendEmailVerification();
              },
              child: const Text('Send email verification'))
        ],
      ),
    );
  }
}
