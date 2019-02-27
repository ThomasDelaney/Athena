import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/athena_icon_data.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/home_page.dart';
import 'package:my_school_life_prototype/recording_manager.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/subject.dart';
import 'package:my_school_life_prototype/homework.dart';
import 'package:my_school_life_prototype/theme_check.dart';

class AddHomework extends StatefulWidget {

  final Subject subject;
  final Homework currentHomework;
  final FontData fontData;
  final AthenaIconData iconData;

  AddHomework({Key key, this.subject, this.currentHomework, this.fontData, this.iconData}) : super(key: key);

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
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                  ),
                ],
                iconTheme: IconThemeData(
                    color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour))) ? Colors.white : Colors.black
                ),
                backgroundColor: Color(int.tryParse(widget.subject.colour)),
                title: new Text("Add a New Homework", style: TextStyle(
                    fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context),
                    fontFamily: widget.fontData.font,
                    color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour))) ? Colors.white : Colors.black
                  )
                ),
              ),
              body: new SingleChildScrollView(
                child: new Column(
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
                                style: TextStyle(
                                    fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                    fontFamily: widget.fontData.font,
                                    color: widget.fontData.color
                                ),
                                decoration: InputDecoration(
                                    hintText: "Homework Description",
                                    labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).accentColor),
                                    border: UnderlineInputBorder()
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            new Container(
                                margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        child: new Text("Is this Homework already completed?", style: TextStyle(
                                            fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                            fontFamily: widget.fontData.font,
                                            color: widget.fontData.color
                                          )
                                        )
                                    ),
                                    SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context)),
                                    Container(
                                      width: 18*1.85*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size,
                                      height: 18*1.85*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size,
                                      child: Transform.scale(
                                        alignment: Alignment.center,
                                        scale: 1.25*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size,
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
                                  height: 50.0*ThemeCheck.orientatedScaleFactor(context),
                                  child: RaisedButton(
                                    elevation: 3.0,
                                    onPressed: showAreYouSureDialog,
                                    child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font,))),
                                    color: Color(int.tryParse(widget.subject.colour)),

                                    textColor: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour))) ? Colors.white : Colors.black,
                                  ),
                                )
                            )
                          ],
                        )
                    )
                  ],
                ),
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
        content: new Text("Do you want to SAVE this Homework?", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
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
          }, child: new Text("YES", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
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
      content: new Text("Do you want to SAVE this Homework?", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
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
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
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
      content: new Text("You must have a Homework Description", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, fontWeight: FontWeight.bold,),)),
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
