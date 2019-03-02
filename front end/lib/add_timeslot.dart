import 'package:Athena/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/theme_check.dart';
import 'request_manager.dart';
import 'package:flutter/material.dart';
import 'subject.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'timetable_slot.dart';

class AddTimeslot extends StatefulWidget {

  AddTimeslot({Key key, this.day, this.lastTime, this.currentTimeslot, this.fontData, this.cardColour, this.themeColour, this.backgroundColour}) : super(key: key);

  final String day;
  final String lastTime;
  final TimetableSlot currentTimeslot;
  final FontData fontData;

  final Color cardColour;
  final Color backgroundColour;
  final Color themeColour;

  @override
  _AddTimeslotState createState() => _AddTimeslotState();
}

class _AddTimeslotState extends State<AddTimeslot> {

  RequestManager requestManager = RequestManager.singleton;

  final timeController = new TextEditingController();
  final teacherController = new TextEditingController();
  final roomController = new TextEditingController();

  Subject selectedSubject;
  Subject oldSubject;

  bool subjectsLoaded = false;

  String currentTime;

  FocusNode teacherFocusNode;
  FocusNode roomFocusNode;
  FocusNode timeFocusNode;

  List<Subject> subjects = new List<Subject>();

  bool submitting = true;

  @override
  void initState() {

    if (widget.currentTimeslot != null) {
      currentTime = widget.currentTimeslot.time;
      roomController.text = widget.currentTimeslot.room;
      timeController.text = widget.currentTimeslot.time;
      teacherController.text = widget.currentTimeslot.teacher;
    }

    getSubjects();
    teacherFocusNode = new FocusNode();
    roomFocusNode = new FocusNode();
    timeFocusNode = new FocusNode();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool isFileEdited() {
    if (widget.currentTimeslot == null) {
      if (teacherController.text == "" && timeController.text == "" && roomController.text == "" && selectedSubject == null) {
        return false;
      }
      else {
        return true;
      }
    }
    else {
      if (teacherController.text != widget.currentTimeslot.teacher || timeController.text != widget.currentTimeslot.time || selectedSubject.name != oldSubject.name || roomController.text != widget.currentTimeslot.room) {
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
              backgroundColor: widget.backgroundColour,
              appBar: new AppBar(
                backgroundColor: widget.themeColour,
                iconTheme: IconThemeData(
                    color: ThemeCheck.colorCheck(widget.themeColour)
                ),
                title: widget.currentTimeslot == null ? new Text(
                    "Add a New Timeslot",
                    style: TextStyle(
                        fontFamily: widget.fontData.font
                    ),
                  ) : new Text(
                    widget.currentTimeslot.subjectTitle+" at "+widget.currentTimeslot.time,
                    style: TextStyle(
                        fontFamily: widget.fontData.font
                    ),
                ),
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.home),
                        onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                    ),
                    widget.currentTimeslot != null ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: deleteTimeslotDialog,
                    ): new Container()
                  ]
              ),
              resizeToAvoidBottomPadding: false,
              body: new ListView(
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
                            child: !submitting ?
                            new Container(
                                child: ButtonTheme(
                                  height: 50.0*ThemeCheck.orientatedScaleFactor(context),
                                  child: RaisedButton(
                                    elevation: 3.0,
                                    onPressed: () => showSubjectList(),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            selectedSubject == null ? 'Choose a Subject' : selectedSubject.name,
                                            style: TextStyle(
                                              fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                              fontFamily: widget.fontData.font,
                                            )
                                        )
                                    ),
                                    color: widget.themeColour,
                                    textColor: ThemeCheck.colorCheck(widget.themeColour),
                                  ),
                                )
                            ) : new Container(),
                          ),
                          SizedBox(height: 10.0),
                          new Container(
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: Theme(
                                data: ThemeData(
                                  primaryColor: widget.themeColour,
                                ),
                                child: TextFormField(
                                  focusNode: roomFocusNode,
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  controller: roomController,
                                  style: TextStyle(fontSize: 24.0*widget.fontData.size, fontFamily: widget.fontData.font, color: widget.fontData.color),
                                  onFieldSubmitted: (String value) {
                                    FocusScope.of(context).requestFocus(teacherFocusNode);
                                  },
                                  decoration: InputDecoration(
                                    hintText: "What's the Room name?",
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: widget.themeColour),
                                    ),
                                  ),
                                  cursorColor: widget.themeColour,
                                ),
                            )
                          ),
                          SizedBox(height: 20.0),
                          new Container(
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: widget.themeColour,
                              ),
                              child: TextFormField(
                                focusNode: teacherFocusNode,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                controller: teacherController,
                                style: TextStyle(fontSize: 24.0*widget.fontData.size, fontFamily: widget.fontData.font, color: widget.fontData.color),
                                onFieldSubmitted: (String value) {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                },
                                decoration: InputDecoration(
                                  hintText: "What's the Teacher's name?",
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: widget.themeColour),
                                  ),
                                ),
                                cursorColor: widget.themeColour,
                              ),
                            )
                          ),
                          SizedBox(height: 20.0),
                          new Container(
                              margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              child: new Theme(
                                  data: ThemeData(
                                    accentColor: widget.themeColour,
                                    dialogBackgroundColor: widget.cardColour,
                                    primaryColor: widget.themeColour,
                                    primaryColorDark: widget.themeColour
                                  ),
                                  child: DateTimePickerFormField(
                                      controller: timeController,
                                      initialValue: widget.currentTimeslot == null ? null :
                                      DateTime(2000, 03, 07, int.tryParse(widget.currentTimeslot.time.split(':')[0]), int.tryParse(widget.currentTimeslot.time.split(':')[1])),
                                      format: DateFormat("HH:mm"),
                                      inputType: InputType.time,
                                      editable: false,
                                      onChanged: (DateTime dt) {
                                        setState(() =>
                                        dt != null ? currentTime = (dt.hour.toString()+":"+dt.minute.toString()) : null
                                        );

                                        FocusScope.of(context).requestFocus(new FocusNode());
                                      },
                                      style: TextStyle(fontSize: 24.0*widget.fontData.size, fontFamily: widget.fontData.font, color: widget.fontData.color),
                                      decoration: InputDecoration(
                                        hintText: "What Time is the class at?",
                                        hintStyle: TextStyle(fontSize: 24.0*widget.fontData.size, fontFamily: widget.fontData.font),
                                        hasFloatingPlaceholder: false,
                                      ),
                                      initialTime: null
                                  )
                              )
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
                          child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size))),
                          color: ThemeCheck.errorColorOfColor(widget.themeColour),

                          textColor: ThemeCheck.colorCheck(ThemeCheck.errorColorOfColor(widget.themeColour)),
                        ),
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
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              ],
            ): new Container()
          ],
        )
    );
  }

  void showSubjectList(){
    AlertDialog tags = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Container(
        width: MediaQuery.of(context).size.width,
        child: new ListView.builder(
            shrinkWrap: true,
            itemCount: subjects.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return new RadioListTile<Subject>(
                activeColor: widget.themeColour,
                value: subjects[index],
                groupValue: selectedSubject == null ? null : selectedSubject,
                title: Text(
                  subjects[index].name, style: TextStyle(
                    fontSize: 20.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                    fontFamily: widget.fontData.font,
                    color: widget.fontData.color
                  ),
                ),
                onChanged: (Subject val) {
                  setState(() {
                    selectedSubject = val;
                    Navigator.pop(context);
                  });
                },
              );
            }
        ),
      ),
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => tags, );
  }

  void getSubjects() async {
    List<Subject> reqSubjects = await requestManager.getSubjects();

    Subject subjectForTitle;

    if (widget.currentTimeslot != null) {
      reqSubjects.forEach((subject){
        if (subject.name == widget.currentTimeslot.subjectTitle) {
          subjectForTitle = subject;
        }
      });
    }

    this.setState(() {
      selectedSubject = subjectForTitle;
      oldSubject = subjectForTitle;
      subjects = reqSubjects;
      submit(false);
    });
  }

  void showAreYouSureDialog() {

    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text(
          "Do you want to ADD this Timeslot to your Timetable?",
          style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
          )
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.themeColour
        ),)),
        new FlatButton(onPressed: () async {
          if (currentTime == null) {
            Navigator.pop(context);
            showMustHaveTimeDialog();
          }
          else if (widget.lastTime != null && (
              DateTime(2000, 03, 07, int.tryParse(currentTime.split(':')[0]), int.tryParse(currentTime.split(':')[1])).isBefore(
                  DateTime(2000, 03, 07, int.tryParse(widget.lastTime.split(':')[0]), int.tryParse(widget.lastTime.split(':')[1]))
              )
          ))
          {
            Navigator.pop(context);
            showTimeErrorDialog();
          }
          else if (selectedSubject == null) {
            Navigator.pop(context);
            showMustHaveSubjectDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            await addTimeslot();
            submit(false);
            Navigator.pop(context);
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
        content: new Text(
            "Do you want to SAVE this Timeslot?",
            style: TextStyle(
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
            if (currentTime == null) {
              Navigator.pop(context);
              showMustHaveTimeDialog();
            }
            else if (widget.lastTime != null && (
                DateTime(2000, 03, 07, int.tryParse(currentTime.split(':')[0]), int.tryParse(currentTime.split(':')[1])).isBefore(
                    DateTime(2000, 03, 07, int.tryParse(widget.lastTime.split(':')[0]), int.tryParse(widget.lastTime.split(':')[1]))
                )
            ))
            {
              Navigator.pop(context);
              showTimeErrorDialog();
            }
            else if (selectedSubject == null) {
              Navigator.pop(context);
              showMustHaveSubjectDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await addTimeslot();
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

  void showTimeErrorDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("The chosen time cannot be before the last timeslot in your Timetable", style: TextStyle(
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

  void showMustHaveSubjectDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("You must select a Subject for this timeslot", style: TextStyle(
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

  void showMustHaveTimeDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("You must select a Time for this timeslot", style: TextStyle(
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

  void addTimeslot() async {

    //create map of subject data
    Map map = {
      "id": widget.currentTimeslot == null ? null : widget.currentTimeslot.id,
      "day": widget.day,
      "subjectTitle": selectedSubject.name,
      "colour": selectedSubject.colour,
      "time": currentTime,
      "room": roomController.text,
      "teacher": teacherController.text
    };

    var response = await requestManager.putTimeslot(map);

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

  void deleteTimeslot() async {
    var response = await requestManager.deleteTimeslot(widget.currentTimeslot.id, widget.day);

    //if null, then the request was a success, retrieve the information
    if (response == "success") {
      Navigator.pop(context, true);
    }
    //else the response ['response']  is not null, then print the error message
    else {
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text("An error has occured please try again", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
        )),
        actions: <Widget>[
          new FlatButton(onPressed: () {
            Navigator.pop(context);
            submit(false);
          }, child: new Text("OK", style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
              color: widget.themeColour
          )))
        ],
      );

      showDialog(context: context,
          barrierDismissible: true,
          builder: (_) => responseDialog);
    }
  }

  void deleteTimeslotDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text(
        "Do you want to DELETE this Timeslot?", style: TextStyle(
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
          color: widget.fontData.color
      )),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.themeColour
        ),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteTimeslot();
        },
            child: new Text("YES",
              style: TextStyle(
                  fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                  fontFamily: widget.fontData.font,
                  fontWeight: FontWeight.bold,
                  color: widget.themeColour
              ),)),
      ],
    );

    showDialog(context: context,
        barrierDismissible: false,
        builder: (_) => areYouSure);
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
