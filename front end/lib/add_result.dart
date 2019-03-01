import 'package:flutter/material.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/request_manager.dart';
import 'package:Athena/subject.dart';
import 'package:Athena/test_result.dart';
import 'package:Athena/theme_check.dart';

class AddResult extends StatefulWidget {

  final Subject subject;
  final TestResult currentResult;
  final FontData fontData;

  final Color cardColour;
  final Color backgroundColour;
  final Color themeColour;

  AddResult({Key key, this.subject, this.currentResult, this.fontData, this.cardColour, this.themeColour, this.backgroundColour}) : super(key: key);

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
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                  ),
                ],
              ),
              body: new SingleChildScrollView(
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
                                    labelStyle: Theme.of(context).textTheme.caption.copyWith(color: widget.themeColour),
                                    border: UnderlineInputBorder()
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
