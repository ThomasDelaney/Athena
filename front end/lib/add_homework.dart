import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/recording_manager.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/subject.dart';
import 'package:my_school_life_prototype/homework.dart';
import 'package:my_school_life_prototype/theme_check.dart';

class AddHomework extends StatefulWidget {

  final Subject subject;
  final Homework currentHomework;

  AddHomework({Key key, this.subject, this.currentHomework}) : super(key: key);

  @override
  _AddHomeworkState createState() => _AddHomeworkState();
}

class _AddHomeworkState extends State<AddHomework> {

  bool submitting = false;

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final homeworkDescriptionController = new TextEditingController();
  FocusNode homeworkDescriptionFocusNode;

  bool completedValue;

  bool isFileEdited() {
    if (widget.currentHomework == null) {
      if (homeworkDescriptionController.text == "") {
        return false;
      }
      else {
        return true;
      }
    }
    else {
      if (homeworkDescriptionController.text != widget.currentHomework.description || completedValue != widget.currentHomework.isCompleted) {
        return true;
      }
      else {
        return false;
      }
    }
  }

  @override
  void initState() {
    if (widget.currentHomework != null) {
      homeworkDescriptionController.text = widget.currentHomework.description;
      completedValue = widget.currentHomework.isCompleted;
    }
    else{
      completedValue = false;
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
                title: widget.subject == null ? new Text("Add a New Homework") : new Text(widget.subject.name),
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
                              focusNode: homeworkDescriptionFocusNode,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              controller: homeworkDescriptionController,
                              style: TextStyle(fontSize: 24.0),
                              decoration: InputDecoration(
                                  hintText: "Homework Description",
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
                                      child: new Text("Is this Homework already completed?", style: TextStyle(fontSize: 24.0))
                                  ),
                                  SizedBox(height: 10.0),
                                  Container(
                                    child: Transform.scale(
                                      alignment: Alignment.centerLeft,
                                      scale: 1.5,
                                      child: new Checkbox(
                                        materialTapTargetSize: MaterialTapTargetSize.padded,
                                        activeColor: Color(int.tryParse(widget.subject.colour)),
                                        value: completedValue,
                                        onChanged: (newVal) {
                                          setState(() {
                                            completedValue = newVal;
                                          });
                                        },
                                      ),
                                    )
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
        content: new Text("Do you want to SAVE this Homework?", /*style: TextStyle(fontFamily: font),*/),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
          new FlatButton(onPressed: () async {
            if (homeworkDescriptionController.text == "") {
              Navigator.pop(context, false);
              showYouMustHaveHomeworkDescriptionDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await putHomework();
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
      content: new Text("Do you want to SAVE this Homework?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          if (homeworkDescriptionController.text == "") {
            Navigator.pop(context, false);
            showYouMustHaveHomeworkDescriptionDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            await putHomework();
            submit(false);
            Navigator.pop(context);
          }
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void putHomework() async {

    //create map of subject data
    Map map = {
      "id": widget.currentHomework == null ? null : widget.currentHomework.id,
      "subjectID": widget.subject.id,
      "description": homeworkDescriptionController.text,
      "isCompleted": completedValue
    };

    var response = await requestManager.putHomework(map);

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

  void showYouMustHaveHomeworkDescriptionDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("You must have a Homework Description", /*style: TextStyle(fontFamily: font),*/),
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
