import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learning_project/firebase_options.dart';
import 'package:learning_project/views/login_view.dart';
import 'package:learning_project/views/register_view.dart';
import 'package:learning_project/views/verifyEmail_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      //movement b/w screens. These are named routes
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    );
  }
}

//widget:elements of UI on screen of fluuter app.
//stateful widget:
/*
    state: data mutated(chaneged) by user or application.
    > on the screen that can be seen.
    > contains data changing and can read/write itself.

 */

//stateless widget: cannot redraw itself and contain mutable data.

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //Future Builder: for firebase initialiazation before app starts it takes future and return callback on the basis of success or error
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        //while waiting on firebase connection we tell user that its loading
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser != null) {
              if (currentUser.emailVerified) {
                print('Email is Verified!');
              } else {
                return const VerificationView();
              }
            } else {
              return const LoginView();
            }
            return const Text("Done!");
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
