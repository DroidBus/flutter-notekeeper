import 'package:flutter/material.dart';
import 'databasehelper/database_helper.dart';
import 'model/note.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {

    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['high', 'low'];
  var _currentItemSelected = '';
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;
  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  NoteDetailState(this.note, this.appBarTitle);

  @override
  void initState() {
     super.initState();
    _currentItemSelected = _priorities[0];
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;
    _currentItemSelected=getPriorityAsString(note.priority);
    return WillPopScope(
        onWillPop: () {


          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
          ),
          body: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem, style: textStyle),
                          );
                        }).toList(),
                        onChanged: (String newValueSelected) {
                           // Your code to execute, when a menu item is selected from drop down
                          _onDropDownItemSelected(newValueSelected);
                        },
                        style: textStyle,
                        value: _currentItemSelected),
                  ),
                  //second element
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: TextField(

                      style: textStyle,
                      controller: titleController,
                      onChanged: (value) {
                        debugPrint('Something changed in Title Text Field');
                        updateTitle();
                      },
                      decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: textStyle,
                          errorStyle: TextStyle(
                          color: Colors.yellowAccent, fontSize: 15.0),
                          hintText: 'Enter title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: TextField(

                      style: textStyle,
                      controller: descriptionController,
                      onChanged: (value) {
                        debugPrint('Something changed in Description Text Field');
                        updateDescription();
                      },
                      decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: textStyle,
                          errorStyle: TextStyle(
                              color: Colors.yellowAccent, fontSize: 15.0),
                          hintText: 'Enter description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                              textColor: Theme.of(context).primaryColorLight,
                              color: Theme.of(context).primaryColorDark,
                              child: Text(
                                "Save",
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                setState(() {
                                  _save();
                                });
                              }),
                        ),
                        Container(width: 5.0),
                        Expanded(
                          child: RaisedButton(
                              textColor: Theme.of(context).primaryColorLight,
                              color: Theme.of(context).primaryColorDark,
                              child: Text("Delete", textScaleFactor: 1.5),
                              onPressed: () {
                                setState(() {
                                  _delete();
                                });
                              }),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ));
  }

  /*void _clear() {
    titleController.text = '';
    descriptionController.text = '';
    _currentItemSelected = _priorities[0];
  }*/

  void _onDropDownItemSelected(String value) {
    setState(() {
      this._currentItemSelected = value;
      debugPrint('User Selected $value');
      updatePriorityAsInt(value);
    });
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }


  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'high':
        note.priority = 1;
        break;
      case 'low':
        note.priority = 2;
        break;
    }
  }



  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }



  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {

      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {

      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }


    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
