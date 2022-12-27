import 'package:flutter/material.dart';
// import 'package:learning_project/notes/crud/note_service.dart';
import 'package:learning_project/services/cloud/cloud_note.dart';

import '../utilities/dialogs/delete_dialog.dart';

// typedef NoteCallback = void Function(DatabaseNote note);
typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  // final List<DatabaseNote> notes;
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        // final currentNote = notes[index];
        final currentNote = notes.elementAt(index);
        return ListTile(
          title: Text(
            currentNote.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            onTap(currentNote);
          },
          trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(currentNote);
                }
              },
              icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}
