import 'package:flutter/material.dart';
import 'package:learning_project/services/auth/auth_service.dart';
import 'package:learning_project/utilities/dialogs/cannot_share_emptynote.dart';
// import 'package:learning_project/notes/crud/note_service.dart';
import 'package:learning_project/utilities/generics/get_arguments.dart';
import 'package:learning_project/services/cloud/cloud_note.dart';
// import 'package:learning_project/services/cloud/cloud_storage_exceptions.dart';
import 'package:learning_project/services/cloud/fireebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNotesView extends StatefulWidget {
  const CreateUpdateNotesView({super.key});

  @override
  State<CreateUpdateNotesView> createState() => _CreateUpdateNotesViewState();
}

class _CreateUpdateNotesViewState extends State<CreateUpdateNotesView> {
  // DatabaseNote?
  //     _note; //every hot reload call build again and again which create notes on every build so we save the reference of note
  // late final NotesService
  //     _notesService; //we dont have to call factory constructor every time when performing database operations
  late final TextEditingController _textController;
  late final FirebaseCloudStorage _noteService;
  CloudNote? _note;

  @override
  void initState() {
    // _notesService = NotesService();
    _noteService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

//update database as user types:
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    // await _notesService.updateNotes(
    //   note: note,
    //   text: text,
    // );

    await _noteService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  //  Future<DatabaseNote> createOrGetExistingNotes(BuildContext context)

  Future<CloudNote> createOrGetExistingNotes(BuildContext context) async {
    //Updating existing note:
    //  final widgetNote = context.getArguments<DatabaseNote>();
    final widgetNote = context.getArguments<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      //to populate existing note on text field we use texteditingcontroller:
      _textController.text = widgetNote.text;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    // final email = currentUser.email;
    // final owner = await _notesService.getUser(email: email);
    // final newNote = await _notesService.createNote(owner: owner);

    final userId = currentUser.id;
    final newNote = await _noteService.createNewNotes(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteOnEmptyText() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      // _notesService.deleteNote(id: note.id);

      _noteService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteOnNonEmptyText() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      // await _notesService.updateNotes(
      //   note: note,
      //   text: text,
      // );

      await _noteService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteOnEmptyText();
    _saveNoteOnNonEmptyText();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New note'),
          actions: [
            IconButton(
              onPressed: () async {
                final text = _textController.text;
                if (_note == null || text.isEmpty) {
                  await cannotShareEmptyNotes(context);
                } else {
                  Share.share(text);
                }
              },
              icon: const Icon(Icons.share),
            )
          ],
        ),
        body: FutureBuilder(
            future: createOrGetExistingNotes(context),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  _setupTextControllerListener();
                  return TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Starting typing notes here....'),
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
            }));
  }
}
