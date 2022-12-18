import 'dart:io';

import 'package:notekeeper_app/model/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;
  static final String tablename = 'notekeeper';
  static final String coltitle = 'title';
  static final String coldescription = 'description';
  static final  String coldate = 'date';
  static final  String colid = 'id';
  static final  String colpriority = 'priority';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> initialiseDatabase() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //path_provider package
    String path = directory.path + "notekeeper.db";
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initialiseDatabase();
    }
    return _database;
  }

  void _createDb(Database db, int newversion) async {
    await db.execute(
        'CREATE TABLE $tablename($colid INTEGER PRIMARY KEY AUTOINCREMENT, $colpriority INTEGER,'
        '  $coltitle TEXT, $coldescription TEXT, $coldate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = db.query(tablename, orderBy: '$colpriority ASC');
    return result;
  }


  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(tablename, note.toMap());
    return result;
  }




  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(tablename, note.toMap(), where: '$colid = ?', whereArgs: [note.id]);
    return result;
  }



  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $tablename WHERE $colid = $id');
    return result;
  }



  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tablename');
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  Future<List<Note>> getNoteList() async {

    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count = noteMapList.length;         // Count the number of map entries in db table

    List<Note> noteList = List<Note>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

}
