import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:learning_project/constants/routes.dart';

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
          const Text("check your email for verification"),
          const Text("If you haven't recieved press the button below"),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              await user?.sendEmailVerification();
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) {
                return;
              }
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
