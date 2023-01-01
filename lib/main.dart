import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:learning_project/constants/routes.dart';
import 'package:learning_project/services/auth/bloc/auth_bloc.dart';
import 'package:learning_project/services/auth/bloc/auth_events.dart';
import 'package:learning_project/services/auth/firebase_auth_provider.dart';
import 'package:learning_project/views/login_view.dart';
import 'package:learning_project/notes/notes_view.dart';
import 'package:learning_project/views/register_view.dart';
import 'package:learning_project/views/verifyEmail_view.dart';

import 'notes/create_update_note.dart';
import 'services/auth/bloc/auth_state.dart';

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
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      //movement b/w screens. These are named routes
      routes: {
        createUpdateNoteRoute: (context) => const CreateUpdateNotesView(),
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
    context.read<AuthBloc>().add(const AuthEventInitialise());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerificationView();
        } else if (state is AuthStateLogout) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
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
