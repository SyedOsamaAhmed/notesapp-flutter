import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_project/constants/routes.dart';
import 'package:learning_project/enums/menu_action.dart';
import 'package:learning_project/notes/notes_list_view.dart';
import 'package:learning_project/services/auth/auth_service.dart';
import 'package:learning_project/services/auth/bloc/auth_bloc.dart';
import 'package:learning_project/services/auth/bloc/auth_events.dart';
// import 'package:learning_project/notes/crud/note_service.dart';
import 'package:learning_project/services/cloud/cloud_note.dart';
import 'package:learning_project/services/cloud/fireebase_cloud_storage.dart';

import '../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  //creating note service class instance so we can use it and email is created for calling getorcreate user function to ensure same firebase logged in user is in database
  // late final NotesService _notesService;
  // String get userEmail => AuthService.firebase().currentUser!.email;

  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;
  @override
  void initState() {
    // _notesService = NotesService();
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Notes'), actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createUpdateNoteRoute);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MenuActions>(onSelected: (value) async {
            switch (value) {
              case MenuActions.logout:
                final shouldLogout = await showLogoutDialog(context);

                if (!mounted) {
                  return;
                }
                if (shouldLogout) {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem(value: MenuActions.logout, child: Text('Logout')),
            ];
          })
        ]),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
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
        )

        /*FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                 return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(
                                id: note.id,
                              );
                            },
                            onTap: (note) {
                              Navigator.of(context).pushNamed(
                                createUpdateNoteRoute,
                                arguments: note,
                              );
                            },
                          );
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
          }),*/
        );
  }
}
