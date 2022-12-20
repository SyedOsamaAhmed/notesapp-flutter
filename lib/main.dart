import 'package:flutter/material.dart';
import 'package:learning_project/constants/routes.dart';

import 'package:learning_project/services/auth/auth_service.dart';
import 'package:learning_project/views/login_view.dart';
import 'package:learning_project/notes/notes_view.dart';

import 'package:learning_project/views/register_view.dart';
import 'package:learning_project/views/verifyEmail_view.dart';

import 'notes/new_notes.dart';

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
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerificationView(),
        newNoteRoute: (context) => const NewNoteView(),
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
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        //while waiting on firebase connection we tell user that its loading
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final currentUser = AuthService.firebase().currentUser;

            if (currentUser != null) {
              if (currentUser.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerificationView();
              }
            } else {
              return const LoginView();
            }

          default:
            return Scaffold(
                body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ));
        }
      },
    );
  }
}
