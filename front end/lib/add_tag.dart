import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/recording_manager.dart';
import 'package:flutter/material.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/theme_check.dart';
import 'tag.dart';
import 'request_manager.dart';

class AddTag extends StatefulWidget {

  AddTag({Key key, this.tag, this.fontData, this.cardColour, this.themeColour, this.backgroundColour, this.iconData}) : super(key: key);

  final Tag tag;
  final FontData fontData;
  final AthenaIconData iconData;

  final Color backgroundColour;
  final Color cardColour;
  final Color themeColour;

  @override
  _AddTagState createState() => _AddTagState();
}

class _AddTagState extends State<AddTag> {

  RequestManager requestManager = RequestManager.singleton;
  RecordingManger recorder = RecordingManger.singleton;

  final tagController = new TextEditingController();
  FocusNode tagFocusNode;

  bool submitting = false;

  String oldTag = "";

  @override
  void initState() {
    recorder.assignParent(this);

    if (widget.tag != null){
      oldTag = widget.tag.tag;
      tagController.text = widget.tag.tag;
    }else {
      tagController.text = "";
    }

    tagFocusNode = new FocusNode();
    super.initState();
  }

  @override
  void didUpdateWidget(AddTag oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  bool isFileEdited() {
    if (widget.tag == null) {
      if (tagController.text == "") {
        return false;
      }
      else {
        return true;
      }
    }
    else {
      if (tagController.text != widget.tag.tag) {
        return true;
      }
      else {
        return false;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: exitCheck,
        child: Stack(
          children: <Widget>[
            Scaffold(
              resizeToAvoidBottomPadding: false,
              backgroundColor: widget.backgroundColour,
              appBar: new AppBar(
                title: widget.tag == null ? new Text("Add a New Tag", style: TextStyle(
                    fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context),
                    fontFamily: widget.fontData.font,
                    color: ThemeCheck.colorCheck(widget.themeColour)
                )) : new Text(widget.tag.tag),
                backgroundColor: widget.themeColour,
                iconTheme: IconThemeData(
                    color: ThemeCheck.colorCheck(widget.themeColour)
                ),
                actions: recorder.recording ? <Widget>[
                  // action button
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {setState(() {recorder.cancelRecording();});},
                  ),
                ] : <Widget>[
                  // else display the mic button and settings button
                  IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                  ),
                  IconButton(
                    icon: Icon(Icons.mic),
                    onPressed: () {setState(() {recorder.recordAudio(context);});},
                  ),
                ],
              ),
              body: new Stack(
                children: <Widget>[
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      new Card(
                          color: widget.cardColour,
                          margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          elevation: 3.0,
                          child: new Column(
                            children: <Widget>[
                              new Container(
                                margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                child: TextFormField(
                                  focusNode: tagFocusNode,
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  controller: tagController,
                                  style: TextStyle(
                                      fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                      fontFamily: widget.fontData.font,
                                      color: widget.fontData.color
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Tag",
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: widget.themeColour),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.0),
                            ],
                          )
                      ),
                      SizedBox(height: 10.0),
                      new Container(
                          margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          child: ButtonTheme(
                            height: 50.0*ThemeCheck.orientatedScaleFactor(context),
                            child: RaisedButton(
                              elevation: 3.0,
                              onPressed: showAreYouSureDialog,
                              child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font,))),
                              color: widget.themeColour,

                              textColor: ThemeCheck.colorCheck(widget.themeColour),
                            ),
                          )
                      )
                    ],
                  ),
                  new Container(
                      child: recorder.recording ?
                      new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                              margin: MediaQuery.of(context).viewInsets,
                              child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, widget.fontData, widget.cardColour, widget.themeColour, widget.iconData)],
                      ) : new Container()
                  ),
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
      content: new Text("Do you want to ADD this Tag to your Tags?", style: TextStyle(
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
          color: widget.fontData.color
      )),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.themeColour
        ),)),
        new FlatButton(onPressed: () async {

          submit(true);
          Navigator.pop(context);
          List<Tag> currentTags = await requestManager.getTags();
          submit(false);

          List<String> tagsAsStrings = currentTags.map((tag) => tag.tag.toLowerCase()).toList();

          if (tagController.text == "") {
            showYouMustHaveTagDialog();
          }
          else if (tagsAsStrings.contains(tagController.text.toLowerCase())){
            showDuplicateTagDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            String result = await addTag();
            if (result != "error") {
              Navigator.pop(context);
            }
            else{
              submit(false);
            }
          }
        }, child: new Text("YES", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            fontWeight: FontWeight.bold,
            color: widget.themeColour
        ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text("Do you want to SAVE this Tag?", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
        )),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              color: widget.themeColour
          ),)),
          new FlatButton(onPressed: () async {

            submit(true);
            Navigator.pop(context);
            List<Tag> currentTags = await requestManager.getTags();
            submit(false);

            List<String> tagsAsStrings = currentTags.map((tag) => tag.tag.toLowerCase()).toList();

            if (tagController.text == "") {
              showYouMustHaveTagDialog();
            }
            else if (tagsAsStrings.contains(tagController.text.toLowerCase())){
              showDuplicateTagDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await addTag();
              submit(false);
              Navigator.pop(context, true);
            }
          }, child: new Text("YES", style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
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

  void showYouMustHaveTagDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("You must have a Tag", style: TextStyle(
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
          color: widget.fontData.color
      )),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            fontWeight: FontWeight.bold,
            color: widget.themeColour
        ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void showDuplicateTagDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("You Already Have a Tag with this Name", style: TextStyle(
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
          color: widget.fontData.color
      )),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            fontWeight: FontWeight.bold,
            color: widget.themeColour
        ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }


  Future<String> addTag() async {
    //create map of tag data
    Map map = {"id": widget.tag == null ? null : widget.tag.id, "tag": tagController.text, "oldTag": oldTag};

    var response = await requestManager.putTag(map);

    //if null, then the request was a success, retrieve the information
    if (response !=  "success"){
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text("An error has occurred. Please try again", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
        )),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK", style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
              color: widget.themeColour
          ),))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);

      return "error";
    }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
