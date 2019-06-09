import 'package:flutter/material.dart';
import 'dart:async';
import '../database_helper.dart';
import '../Note.dart';
import 'note_detail.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList =List<Note>();
      updateViewList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO APP",style:TextStyle(color: Colors.white,fontStyle:FontStyle.italic),),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
        onPressed: (){
          navigateToDetail(Note('','',2),'Add Note');
        },
      ),
    );
  }

  ListView getNoteListView(){
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position){
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Colors.orangeAccent,
          elevation: 4.0,
          child: ListTile(
            title: Text(this.noteList[position].title,style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:20.0 )),
            subtitle: Text(this.noteList[position].date,style:TextStyle(color:Colors.white,)),
            trailing: GestureDetector(
              child: Icon(Icons.edit,color:Colors.white),
              onTap: (){
                navigateToDetail(this.noteList[position],'Edit TODO');
              },
            ),
          ),
        );
      },
    );
  }

  void navigateToDetail(Note note,String title) async{
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
      return NoteDetail(note,title);
    }));

    if (result == true) {
      //update view
      updateViewList();
    }
  }

  void updateViewList(){
    final Future<Database> dbFuture = databaseHelper.initalizeDatabase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
                  this.noteList = noteList;
                  this.count = noteList.length;
                });
      });
    });
  }
}