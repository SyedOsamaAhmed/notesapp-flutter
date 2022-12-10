import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learning_project/constants/routes.dart';
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
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerificationView(),
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

enum MenuActions { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'), actions: [
        PopupMenuButton<MenuActions>(onSelected: (value) async {
          switch (value) {
            case MenuActions.logout:
              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout) {
                await FirebaseAuth.instance.signOut();
                if (!mounted) {
                  return;
                }
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (_) => false,
                );
              }
              break;
          }
        }, itemBuilder: (context) {
          return const [
            PopupMenuItem(value: MenuActions.logout, child: Text('Logout')),
          ];
        })
      ]),
      body: const Text('Main UI'),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      }).then((value) => value ?? false);
}
