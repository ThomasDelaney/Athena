import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/text_file_tag_picker_dialog.dart';
import 'package:Athena/theme_check.dart';
import 'package:zefyr/zefyr.dart';
import 'request_manager.dart';
import 'note.dart';
import 'dart:convert';
import 'subject.dart';
import 'tag.dart';

class TextFileEditor extends StatefulWidget {

  final Note note;
  final Subject subject;
  final FontData fontData;

  final Color cardColour;
  final Color backgroundColour;
  final Color themeColour;

  final String date;

  TextFileEditor({Key key, this.note, this.backgroundColour, this.themeColour, this.cardColour, this.subject, this.fontData, this.date}) : super(key: key);

  @override
  TextFileEditorState createState() => TextFileEditorState();
}

class TextFileEditorState extends State<TextFileEditor> {

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
      currentTag = widget.note.tag;
      previousTag = widget.note.tag;
    }
    else {
      currentTag = "No Tag";
      previousTag = "No Tag";
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
                backgroundColor: widget.backgroundColour,
                resizeToAvoidBottomPadding: true,
                key: _scaffoldKey,
                appBar: AppBar(
                    backgroundColor: Color(int.tryParse(widget.subject.colour)),
                    iconTheme: IconThemeData(
                        color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour)))
                    ),
                    title: new Text(
                        title,
                        style: TextStyle(
                            fontFamily: widget.fontData.font,
                            color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour)))
                        )
                    ),
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(Icons.home),
                          iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
                          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                      ),
                      IconButton(
                        icon: Icon(Icons.local_offer),
                        iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
                        onPressed: () => showTagDialog(false, null),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
                        onPressed: showAreYouSureDialog,
                      )
                    ]
                ),
                body: MediaQuery.of(context).orientation == Orientation.portrait ? new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      new TextFormField(
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font, color: widget.fontData.color),
                        keyboardType: TextInputType.text,
                        autofocus: false,
                        controller: fileNameController,
                        decoration: InputDecoration(
                          hintText: "Note Name",
                          contentPadding: EdgeInsets.fromLTRB(15.0*ThemeCheck.orientatedScaleFactor(context), 15.0*ThemeCheck.orientatedScaleFactor(context), 15.0*ThemeCheck.orientatedScaleFactor(context), 15.0*ThemeCheck.orientatedScaleFactor(context)),
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context)),
                      new Expanded(
                          child: Container(
                              child: Card(
                                  color: widget.cardColour,
                                  elevation: 18.0,
                                  child: new ZefyrScaffold(
                                      child: new ZefyrTheme(
                                        data: new ZefyrThemeData(

                                            paragraphTheme: StyleTheme(
                                                textStyle: TextStyle(
                                                    fontFamily: widget.fontData.font,
                                                    fontSize: 18*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                    color: widget.fontData.color
                                                )
                                            ),
                                            toolbarTheme: ZefyrToolbarTheme.fallback(context).copyWith(
                                                color: widget.themeColour,
                                                iconColor: ThemeCheck.colorCheck(widget.themeColour),
                                                disabledIconColor: Theme.of(context).disabledColor)
                                        ),
                                        child: ZefyrField(
                                          controller: _controller,
                                          focusNode: _focusNode,
                                          autofocus: false,
                                          physics: ClampingScrollPhysics(),
                                        )
                                      )
                                  )
                              )
                          )
                      )
                    ],
                ) :
                    new Row(
                      children: <Widget>[
                        Flexible(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              MediaQuery.of(context).viewInsets.bottom == 0 ? SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context)) : new Container(),
                              MediaQuery.of(context).viewInsets.bottom == 0 ? new TextFormField(
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                controller: fileNameController,
                                decoration: InputDecoration(
                                  hintText: "Note Name",
                                  contentPadding: EdgeInsets.fromLTRB(15.0*ThemeCheck.orientatedScaleFactor(context), 15.0*ThemeCheck.orientatedScaleFactor(context), 15.0*ThemeCheck.orientatedScaleFactor(context), 15.0*ThemeCheck.orientatedScaleFactor(context)),
                                  border: InputBorder.none,
                                ),
                              ) : new Container(),
                              MediaQuery.of(context).viewInsets.bottom == 0 ? SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context)) : new Container(),
                              new Expanded(
                                  child: Container(
                                      child: Card(
                                          color: widget.cardColour,
                                          elevation: 18.0,
                                          child: new ZefyrScaffold(
                                              child: new ZefyrTheme(
                                                  data: new ZefyrThemeData(
                                                    paragraphTheme: StyleTheme(
                                                      textStyle: TextStyle(
                                                        fontFamily: widget.fontData.font,
                                                          fontSize: 18*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                        color: widget.fontData.color
                                                      )
                                                    ),
                                                    toolbarTheme: ZefyrToolbarTheme.fallback(context).copyWith(
                                                        color: widget.themeColour,
                                                        iconColor: ThemeCheck.colorCheck(widget.themeColour),
                                                        disabledIconColor: Theme.of(context).disabledColor)
                                                  ),
                                                  child: ZefyrField(
                                                    controller: _controller,
                                                    focusNode: _focusNode,
                                                    autofocus: false,
                                                    physics: ClampingScrollPhysics(),
                                                  )
                                              )
                                          )
                                      )
                                  )
                              )
                            ],
                          ),
                        ),
                        MediaQuery.of(context).viewInsets.bottom != 0 ? new Container(
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: ButtonTheme(
                              height: 25.0,
                              child: RaisedButton(
                                elevation: 3.0,
                                onPressed: () => FocusScope.of(context).requestFocus(new FocusNode()),
                                child: Align(alignment: Alignment.centerLeft, child: Text('Done', style: TextStyle(fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font))),
                                color: ThemeCheck.errorColorOfColor(widget.themeColour),

                                textColor: ThemeCheck.colorCheck(ThemeCheck.errorColorOfColor(widget.themeColour)),
                              ),
                            )
                        ) : new Container()
                      ],
                    )
            ),
            submitting ? new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                    margin: MediaQuery.of(context).padding,
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              ],
            ): new Container()
          ],
        )
    );
  }

  void showAreYouSureDialog() {

    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("Do you want to SAVE this Note?", style: TextStyle(fontSize: 18.0*widget.fontData.size, fontFamily: widget.fontData.font)),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0*widget.fontData.size,
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
        ),)),
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
          }, child: new Text("YES", style: TextStyle(
          fontSize: 18.0*widget.fontData.size,
          fontFamily: widget.fontData.font,
          fontWeight: FontWeight.bold,
          color: widget.fontData.color
        ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  Future<bool> exitCheck() async{
    FocusScope.of(context).requestFocus(new FocusNode());

    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text("Do you want to SAVE this Note?", style: TextStyle(
            fontSize: 18*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
        )),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(
              fontSize: 18*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, color: widget.themeColour),)),
          new FlatButton(onPressed: () async {
            if (fileNameController.text == "") {
              showYouMustHaveFileNameDialog();
              return false;
            }
            else {
              submit(true);
              Navigator.pop(context);
              await uploadNote();
              submit(false);
              return true;
            }
          }, child: new Text("YES", style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontWeight: FontWeight.bold,
              fontFamily: widget.fontData.font,
              color: widget.themeColour
          ),)),
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
      backgroundColor: widget.cardColour,
      content: new Text("You must have a Note Name", style: TextStyle(
          fontFamily: widget.fontData.font,
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          color: widget.fontData.color
      )),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0*widget.fontData.size, fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void showTagDialog(bool fromWithin, List<String> currentTags) async {

    List<String> tagValues;

    if(!fromWithin) {
      submit(true);

      List<Tag> tags = await requestManager.getTags();

      submit(false);

      tagValues = tags.map((tag) => tag.tag).toList();
      tagValues.add("No Tag");
    }
    else {
      tagValues = currentTags;
    }

    showDialog(context: context, barrierDismissible: true, builder: (_) => new TextFileTagPickerDialog(
        fontData: widget.fontData,
        backgroundColour: widget.backgroundColour,
        themeColour: widget.themeColour,
        cardColour: widget.cardColour,
        previousTag: previousTag,
        parent: this,
        tagValues: tagValues,
        currentTag: currentTag,
      )
    );
  }

  void showTagList(List<String> tagValues){
    AlertDialog tags = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Container(
        width: MediaQuery.of(context).size.width,
        child: new ListView.builder(
            shrinkWrap: true,
            itemCount: tagValues.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return new RadioListTile<String>(
                value: tagValues[index],
                groupValue: currentTag == "" ? null : currentTag,
                title: Text(
                  tagValues[index], style: TextStyle(
                    fontSize: 20.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                    fontFamily: widget.fontData.font,
                    color: widget.fontData.color
                ),
                ),
                onChanged: (String value) {
                  setState(() {
                    currentTag = value;
                    Navigator.pop(context); //pop this dialog
                    Navigator.pop(context); //pop context of previous dialog
                    showTagDialog(true, tagValues);
                  });
                },
              );
            }
        ),
      ),
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => tags, );
  }

  Future<void> uploadNote() async {

    //create map of note data
    Map map = {
      "id": widget.note == null ? null : widget.note.id,
      "fileName": fileNameController.text,
      "delta": json.encode(_controller.document.toJson()).toString(),
      "subjectID": widget.subject.id,
      "tag": currentTag,
      "date": widget.date != null ? widget.date : "null"
    };

    var response = await requestManager.putNote(map);

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Note Saved!', style: TextStyle(
          fontSize: 18*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
      ),)));

      currentlySaved = true;

      setState(() {
        title = "Editing "+fileNameController.text;
      });
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text("An error has occured please try again", style: TextStyle(
            fontFamily: widget.fontData.font,
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            color: widget.fontData.color
        )),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK", style: TextStyle(
              fontFamily: widget.fontData.font,
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontWeight: FontWeight.bold,
              color: widget.themeColour
          )))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void addTagToNote() async {
    if (widget.note == null) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Tag Added!', style: TextStyle(
          fontSize: 18*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
      ),)));
    }
    else {
      Map map = {
        "id": widget.note.id,
        "tag": currentTag,
        "subjectID": widget.subject.id,
        "date": widget.date != null ? widget.date : "null"
      };

      var response = await requestManager.putTagOnNote(map);

      //if null, then the request was a success, retrieve the information
      if (response ==  "success"){
        setState(() {
          previousTag = currentTag;
        });
        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Tag Added!', style: TextStyle(
            fontSize: 18*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
        ),)));
      }
      //else the response ['response']  is not null, then print the error message
      else{
        //display alertdialog with the returned message
        AlertDialog responseDialog = new AlertDialog(
          backgroundColor: widget.cardColour,
          content: new Text("An error occured please try again", style: TextStyle(
              fontSize: 18*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              color: widget.fontData.color
          )),
          actions: <Widget>[
            new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK", style: TextStyle(
                fontFamily: widget.fontData.font,
                fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                fontWeight: FontWeight.bold,
                color: widget.themeColour
            )))
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
