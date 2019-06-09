import 'Note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper{

  static DatabaseHelper _databaseHelper; //Singleton
  static Database _database; //Singleton

  String noteTable = 'note_table';
  String colID = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper ._createInstance();

  factory DatabaseHelper(){

    //Check database present or not
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  //Custom getter for database
  Future<Database> get database async{
    if (_database == null) {
      _database = await initalizeDatabase();
    }
    return _database;
  }

  //initalizing Database
  Future<Database> initalizeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //Open a database
    var notesDatabase = await openDatabase(
      path, version:1, onCreate: _createDb  //_createDB is method
    );
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async{
    db.execute(
      'CREATE TABLE $noteTable($colID INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT,$colPriority INTEGER ,$colDate TEXT)'
    );
  }


  Future<List<Map<String , dynamic>>> getNoteMapList() async{
    Database db = await this.database;
    //SELECT * FROM TABLE
    var result = await db.query(noteTable,orderBy:'$colPriority ASC');
    return result;
  }

  //Insert
  Future<int> insertNote(Note note)async{
    Database db = await this.database;  //database referance
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //Update
  Future<int> updateNote(Note note)async{
    Database db = await this.database;  //database referance
    var result = await db.update(noteTable, note.toMap(), where:'$colID = ?',whereArgs:[note.id]);
    return result;
  }

  //Delete
  Future<int> deleteNote(int id)async{
    Database db = await this.database;  //database referance
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colID =$id');
    return result;
  }

  //Counting values in a database
  Future<int> getCount()async{
    Database db = await this.database;  //database referance
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result; 
  }

  //Convert Note list to Map list
  Future<List<Note>> getNoteList() async{

    var noteMapList = await getNoteMapList();

    int count = noteMapList.length;
    List<Note> noteList = List<Note>();
    for (var i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}