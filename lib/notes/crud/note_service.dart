import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:learning_project/extensions/list/filter.dart';
import 'package:learning_project/notes/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart'; //for database storage and talking
import 'package:path_provider/path_provider.dart'; // for getting docs folder in respective ios and android as code runs in sandbox so they require permission from operating for reading and writing.
import 'package:path/path.dart'
    show
        join; //for joining directory of android with our path to database to get full path

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });
//every row in database is read as hash tables represented by Map<String,Object?> notes service class will read user database and pass it to database user class which it uses to instantiate itself.
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person: id=$id  email=$email';

  //covarient: changing the default input behaviour in super class  as we want to compare two database users as classes with each other i.e objects of other classes are not compared but database users instance
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

//for maps and hash nodes this hashcode plays important role
  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColum] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note: Id=$id UserId=$userId Syncwithcloud=$isSyncedWithCloud text=$text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class NotesService {
  Database? _db;
  //for current user notes protection:
  DatabaseUser? _user;
//Singleton pattern:
/*Since broadcast does not hold value of stream controller when listeners are subscribed to it so we remedy by calling broadcast listen function and assign it values from database making it late final */
  static final _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }

  factory NotesService() => _shared;
  //caching:

  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter(
        (note) {
          final currentUser = _user;
          if (currentUser != null) {
            return note.userId == currentUser.id;
          } else {
            throw UserShouldBeSetBeforeReadingNotes();
          }
        },
      );

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    //converting iterable to list:
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on UserNotFound {
      final createUser_ = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createUser_;
      }
      return createUser_;
    } catch (e) {
      rethrow;
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<DatabaseNote> updateNotes({
    required DatabaseNote note,
    required String text,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    //checking if exists in database:
    await getNote(id: note.id);

    //update in DB:
    final updatedCount = await db.update(
        notesTable,
        {
          textColumn: text,
          isSyncedWithCloudColum: 0,
        },
        where: 'id=?',
        whereArgs: [note.id]);

    if (updatedCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      //updating notes in stream controller and streams:
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      limit: 1,
      notesTable,
      where: 'id=?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      //remove exiting note in cache and add updated note in our cache so changes reflected in database also reflects in cache:
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCounts = await db.delete(notesTable);

    _notes = [];
    _notesStreamController.add(_notes);
    return deletedCounts;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      notesTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);

    //check id of owner matches with database
    if (dbUser != owner) {
      throw UserNotFound();
    }

    const text = '';
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColum: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

//adding notes to list of database note and its stream controller:
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //checking if user already exists in database:
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw UserNotFound();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<void> deleteUser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: email = '?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //checking if user already exists in database:
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExist();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email,
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
//Creating user and notes table:
      await db.execute(createUserTable);
      await db.execute(createNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}

const dbName = 'notes.db';
const notesTable = 'note';
const userTable = 'user';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColum = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';

const createNotesTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';
