import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'request_manager.dart';
import 'note.dart';
import 'dart:convert';
import 'subject.dart';
import 'tag.dart';

class TextFileEditor extends StatefulWidget {

  final Note note;
  final Subject subject;

  TextFileEditor({Key key, this.note, this.subject}) : super(key: key);

  @override
  _TextFileEditorState createState() => _TextFileEditorState();
}

class _TextFileEditorState extends State<TextFileEditor> {

  RequestManager requestManager = RequestManager.singleton;

  bool submitting = false;

  bool currentlySaved = false;

  String currentTag;
  String previousTag;

  ZefyrController _controller;
  FocusNode _focusNode;
  final fileNameController = new TextEditingController();
  String title;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    NotusDocument document;

    if (widget.note != null) {
      document = NotusDocument.fromJson(json.decode(widget.note.delta));
      fileNameController.text = widget.note.fileName;
      title = "Editing "+widget.note.fileName;
    }
    else {
      currentTag = "";
      previousTag = "";
      document = new NotusDocument();
      title = "Editing New Note";
    }

    _controller = new ZefyrController(document);
    _focusNode = new FocusNode();
  }

  bool isFileEdited() {
    if (currentlySaved == true) {
      return false;
    }
    else {
      if (widget.note == null) {
        if (fileNameController.text == "" && _controller.document.toPlainText() == "\n") {
          return false;
        }
        else {
          return true;
        }
      }
      else {
        if (fileNameController.text != widget.note.fileName || json.encode(_controller.document.toJson()).toString() != widget.note.delta) {
          return true;
        }
        else {
          return false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: exitCheck,
        child: new Stack(children: <Widget>[
            Scaffold(
                resizeToAvoidBottomPadding: true,
                key: _scaffoldKey,
                appBar: AppBar(
                    title: new Text(title),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.local_offer),
                        iconSize: 30.0,
                        onPressed: () => showTagDialog(false, null),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        iconSize: 30.0,
                        onPressed: showAreYouSureDialog,
                      )
                    ]
                ),
                body: new Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      new TextFormField(
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                        keyboardType: TextInputType.text,
                        autofocus: false,
                        controller: fileNameController,
                        decoration: InputDecoration(
                          hintText: "Note Name",
                          contentPadding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      new Flexible(
                          child: Container(
                              child: Card(
                                  elevation: 18.0,
                                  child: new ZefyrScaffold(
                                      child: new ZefyrTheme(
                                        data: new ZefyrThemeData(
                                            toolbarTheme: ZefyrToolbarTheme.fallback(context).copyWith(
                                                color: Theme.of(context).accentColor,
                                                iconColor: Theme.of(context).canvasColor,
                                                disabledIconColor: Theme.of(context).disabledColor)),
                                        child: ZefyrEditor(
                                          autofocus: true,
                                          controller: _controller,
                                          focusNode: _focusNode,
                                        ),
                                      )
                                  )
                              )
                          )
                      )
                    ],
                  ),
                )
            ),
            submitting ? new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                    margin: MediaQuery.of(context).padding,
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
              ],
            ): new Container()
          ],
        )
    );
  }

  void showAreYouSureDialog() {

    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to SAVE this Note?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
            if (fileNameController.text == "") {
              Navigator.pop(context);
              showYouMustHaveFileNameDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await uploadNote();
              submit(false);
            }
          }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        content: new Text("Do you want to SAVE this Note?", /*style: TextStyle(fontFamily: font),*/),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
          new FlatButton(onPressed: () async {
            if (fileNameController.text == "") {
              Navigator.pop(context, false);
              showYouMustHaveFileNameDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await uploadNote();
              submit(false);
              Navigator.pop(context, true);
            }
          }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        ],
      );

      return showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
    }
    else {
      return true;
    }
  }

  void showYouMustHaveFileNameDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("You must have a Note Name", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }
  
  void getCurrentTag() async {

    if (widget.note == null) {
      setState(() {
        previousTag = "No Tag";
        currentTag = "No Tag";
      });
    }
    else {
      String tag = await requestManager.getTagForNote({"id": widget.note.id, "subjectID": widget.subject.id});
      setState(() {
        previousTag = tag;
        currentTag = previousTag;
      });
    }
  }

  void showTagDialog(bool fromWithin, List<String> currentTags) async {

    List<String> tagValues;

    if(!fromWithin) {
      submit(true);

      List<Tag> tags = await requestManager.getTags();
      await getCurrentTag();

      submit(false);

      tagValues = tags.map((tag) => tag.tag).toList();
    }
    else {
      tagValues = currentTags;
    }

    tagValues.add("No Tag");

    AlertDialog tagDialog = new AlertDialog(
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Text("Current Tag is: ", style: TextStyle(fontSize: 20.0)),
              new Text(previousTag, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ],
          ),
          new SizedBox(height: 20.0,),
          new DropdownButton<String>(
            //initial value
            value: currentTag,
            hint: new Text("Choose a Tag", style: TextStyle(fontSize: 20.0)),
            items: tagValues.map((String tag) {
              return new DropdownMenuItem<String>(
                value: tag,
                child: new Text(tag,  style: TextStyle(fontSize: 20.0)),
              );
            }).toList(),
            //when the font is changed in the dropdown, change the current font state
            onChanged: (String val){
              setState(() {
                currentTag = val;
                Navigator.pop(context);
                showTagDialog(true, tagValues);
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("Close", style: TextStyle(fontSize: 18.0),)),
        new FlatButton(onPressed: () async {
          submit(true);
          Navigator.pop(context);
          await addTagToNote();
          submit(false);
        }, child: new Text("Add Tag", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => tagDialog);
  }


  Future<void> uploadNote() async {

    //create map of note data
    Map map = {
      "id": widget.note == null ? null : widget.note.id,
      "fileName": fileNameController.text,
      "delta": json.encode(_controller.document.toJson()).toString(),
      "subjectID": widget.subject.id,
      "tag": currentTag
    };

    var response = await requestManager.putNote(map);

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Note Saved!')));

      currentlySaved = true;

      setState(() {
        title = "Editing "+fileNameController.text;
      });
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error has occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void addTagToNote() async {
    if (widget.note == null) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Tag Added!')));
    }
    else {
      Map map = {"id": widget.note.id, "tag": currentTag, "subjectID": widget.subject.id};

      var response = await requestManager.putTagOnNote(map);

      //if null, then the request was a success, retrieve the information
      if (response ==  "success"){
        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Tag Added!')));
      }
      //else the response ['response']  is not null, then print the error message
      else{
        //display alertdialog with the returned message
        AlertDialog responseDialog = new AlertDialog(
          content: new Text("An error occured please try again"),
          actions: <Widget>[
            new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
          ],
        );

        showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
      }
    }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
