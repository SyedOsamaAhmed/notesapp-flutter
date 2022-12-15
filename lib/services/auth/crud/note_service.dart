import 'dart:html';

import 'package:flutter/cupertino.dart';
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

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class NotesService {
  Database? _db;
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
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

const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';
