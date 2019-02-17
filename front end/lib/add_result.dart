import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/recording_manager.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/subject.dart';
import 'package:my_school_life_prototype/test_result.dart';
import 'package:my_school_life_prototype/theme_check.dart';

class AddResult extends StatefulWidget {

  final Subject subject;
  final TestResult currentResult;

  AddResult({Key key, this.subject, this.currentResult}) : super(key: key);

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
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(
                title: widget.subject == null ? new Text("Add a New Test Result") : new Text(widget.subject.name),
              ),
              body: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20.0),
                    new Card(
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
                                style: TextStyle(fontSize: 24.0),
                                decoration: InputDecoration(
                                    hintText: "Test Title",
                                    labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).accentColor),
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
                                        margin: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                                        child: new Text("Result out of 100", style: TextStyle(fontSize: 24.0))
                                    ),
                                    SizedBox(height: 10.0),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                      child: new Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                            child: new Slider(
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
                                          ),
                                          new Text(resultValue.round().toString()+"/100%", style: TextStyle(fontSize: 18.0)),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                            ),
                            new Container(
                                margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                child: ButtonTheme(
                                  height: 50.0,
                                  child: RaisedButton(
                                    elevation: 3.0,
                                    onPressed: showAreYouSureDialog,
                                    child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0))),
                                    color: Theme.of(context).errorColor,

                                    textColor: ThemeCheck.colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
                                  ),
                                )
                            )
                          ],
                        )
                    )
                ],
              ),
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
        content: new Text("Do you want to SAVE this Test Result?", /*style: TextStyle(fontFamily: font),*/),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
          }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
      content: new Text("Do you want to SAVE this Test Result?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
        content: new Text("An error has occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void showYouMustHaveResultTitleDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("You must have a Result Title", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
