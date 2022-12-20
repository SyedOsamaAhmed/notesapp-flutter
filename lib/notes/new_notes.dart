import 'package:flutter/material.dart';
import 'package:learning_project/services/auth/auth_service.dart';
import 'package:learning_project/services/auth/crud/note_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNoteView> {
  DatabaseNote? _note; //for storing the reference of database
  late final NotesService
      _noteservice; //for storing the instaance of factory of NoteService so that  we don't need to recall it every hot reload.
  late final TextEditingController _textController;

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser;
    final email = currentUser!.email!;
    final owner = await _noteservice.getUser(email: email);
    return await _noteservice.createNote(owner: owner);
  }

  void deleteNoteOnEmptyText() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _noteservice.deleteNote(id: note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note')),
      body: const Text('Write your new note here'),
    );
  }
}
