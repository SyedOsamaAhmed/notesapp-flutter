import 'package:flutter/material.dart';
import 'package:learning_project/constants/routes.dart';
import 'package:learning_project/enums/menu_action.dart';
import 'package:learning_project/services/auth/auth_service.dart';
import 'package:learning_project/services/auth/crud/note_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  //creating note service class instance so we can use it and email is created for calling getorcreate user function to ensure same firebase logged in user is in database
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'), actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add)),
        PopupMenuButton<MenuActions>(onSelected: (value) async {
          switch (value) {
            case MenuActions.logout:
              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout) {
                await AuthService.firebase().logout();
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
      body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return const Text('Waiting for all notes...');
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
          }),
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