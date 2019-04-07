import 'package:Athena/design/athena_icon_data.dart';
import 'package:flutter/material.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/request_manager.dart';
import 'package:Athena/subjects/subject.dart';
import 'package:Athena/subjects/test_result.dart';
import 'package:Athena/utilities/theme_check.dart';

//Class for the page to add a test result for a subject
class AddResult extends StatefulWidget {

  final Subject subject;
  final TestResult currentResult;
  final FontData fontData;
  final AthenaIconData iconData;

  final Color cardColour;
  final Color backgroundColour;
  final Color themeColour;

  AddResult({Key key, this.subject, this.currentResult, this.fontData, this.cardColour, this.themeColour, this.backgroundColour, this.iconData}) : super(key: key);

  @override
  _AddResultState createState() => _AddResultState();
}

class _AddResultState extends State<AddResult> {

  bool submitting = false;

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final testTitleController = new TextEditingController();
  FocusNode testTitleFocusNode;

  double resultValue;

  //method to check if the page has been edited since opened
  bool isFileEdited() {
    if (widget.currentResult == null) {
      if (testTitleController.text == "") {
        return false;
      }
      else {
        return true;
      }
    }
    else {
      if (testTitleController.text != widget.currentResult.title || resultValue != widget.currentResult.score) {
        return true;
      }
      else {
        return false;
      }
    }
  }

  @override
  void initState() {
    recorder.assignParent(this);

    if (widget.currentResult != null) {
      testTitleController.text = widget.currentResult.title;
      resultValue = widget.currentResult.score;
    }
    else{
      resultValue = 100.0;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(AddResult oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  //method to build the page
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: exitCheck,
        child: Stack(
          children: <Widget>[
            Scaffold(
              backgroundColor: widget.backgroundColour,
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(
                backgroundColor: Color(int.tryParse(widget.subject.colour)),
                iconTheme: IconThemeData(
                    color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour)))
                ),
                title: new Text("Add a New Test Result", style: TextStyle(
                  fontFamily: widget.fontData.font,
                  color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour
                ))))),
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
                    onPressed: () {setState(() {recorder.recordAudio();});},
                  ),
                ],
              ),
              body: new Stack(
                children: <Widget>[
                  new SingleChildScrollView(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        new Card(
                            color: widget.cardColour,
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            elevation: 3.0,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  child: TextFormField(
                                    focusNode: testTitleFocusNode,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    controller: testTitleController,
                                    style: TextStyle(fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, color: widget.fontData.color),
                                    decoration: InputDecoration(
                                      hintText: "Test Title",
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: widget.themeColour),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                new Container(
                                    margin: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.fromLTRB(20.0*ThemeCheck.orientatedScaleFactor(context), 0.0, 0.0, 0.0),
                                            child: new Text("Result out of 100", style: TextStyle(
                                                fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                fontFamily: widget.fontData.font,
                                                color: widget.fontData.color
                                            )
                                            )
                                        ),
                                        SizedBox(height: 10.0),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(5.0*ThemeCheck.orientatedScaleFactor(context), 0.0, 0.0, 0.0),
                                          child: new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Slider(
                                                activeColor: Color(int.tryParse(widget.subject.colour)),
                                                value: resultValue,
                                                min: 0.0,
                                                onChanged: (newVal) {
                                                  setState(() {
                                                    resultValue = newVal;
                                                  });
                                                },
                                                max: 100.0,
                                              ),
                                              new Container(
                                                margin: EdgeInsets.fromLTRB(15.0*ThemeCheck.orientatedScaleFactor(context), 0.0, 0.0, 0.0),
                                                child: Text(
                                                    resultValue.round().toString()+"/100%",
                                                    style: TextStyle(
                                                        fontSize: 20.0*widget.fontData.size,
                                                        fontFamily: widget.fontData.font,
                                                        color: widget.fontData.color
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                ),
                                new Container(
                                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                    child: ButtonTheme(
                                      height: 50.0*ThemeCheck.orientatedScaleFactor(context),
                                      child: RaisedButton(
                                        elevation: 3.0,
                                        onPressed: showAreYouSureDialog,
                                        child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font,))),
                                        color: ThemeCheck.errorColorOfColor(Color(int.tryParse(widget.subject.colour))),

                                        textColor: ThemeCheck.colorCheck(ThemeCheck.errorColorOfColor(Color(int.tryParse(widget.subject.colour)))),
                                      ),
                                    )
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                  new Container(
                      child: recorder.recording ?
                      new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                              child: new ModalBarrier(
                                color: Colors.black54, dismissible: false,)),
                          recorder.drawRecordingCard(context, widget.fontData, widget.cardColour, widget.themeColour, widget.iconData, widget.backgroundColour)
                        ],) : new Container()
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

  //method that is called when the user exits the page
  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text(
          "Do you want to SAVE this Test Result?",
          style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              color: widget.fontData.color
          ),),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text(
            "NO",
            style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              color: widget.themeColour
            ),)),
          new FlatButton(onPressed: () async {
            if (testTitleController.text == "") {
              Navigator.pop(context, false);
              showYouMustHaveResultTitleDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await putTestResult();
              submit(false);
              Navigator.pop(context, true);
            }
          }, child: new Text(
              "YES",
              style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,
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

  void showAreYouSureDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text(
        "Do you want to SAVE this Test Result?",
        style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
        ),),
      actions: <Widget>[
        new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text(
          "NO",
          style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            fontWeight: FontWeight.bold,
            color: widget.themeColour
          ),)),
        new FlatButton(onPressed: () async {
          if (testTitleController.text == "") {
            Navigator.pop(context, false);
            showYouMustHaveResultTitleDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            await putTestResult();
            submit(false);
            Navigator.pop(context);
          }
        }, child: new Text(
          "YES",
          style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            fontWeight: FontWeight.bold,
            color: widget.themeColour
          ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  //method to create or update a test result
  void putTestResult() async {

    //create map of subject data
    Map map = {
      "id": widget.currentResult == null ? null : widget.currentResult.id,
      "subjectID": widget.subject.id,
      "title": testTitleController.text,
      "score": resultValue.round()
    };

    var response = await requestManager.putTestResult(map);

    //if null, then the request was a success, retrieve the information
    if (response !=  "success"){
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text("An error has occured please try again", style: TextStyle(
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
          )))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  //method to draw a dialog when the user attempts to submit a test result without a title
  void showYouMustHaveResultTitleDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("You must have a Result Title", style: TextStyle(
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
          color: widget.fontData.color
      ),),
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


  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
