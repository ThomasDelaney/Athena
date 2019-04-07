import 'package:Athena/reminders/notification_plugin.dart';
import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/reminders/athena_notification.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/request_manager.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:math';

//Class for the page to add a notification
class AddNotification extends StatefulWidget {

  AddNotification({Key key, this.currentNotification, this.fontData, this.cardColour, this.themeColour, this.backgroundColour, this.iconData}) : super(key: key);

  final AthenaNotification currentNotification;
  final FontData fontData;
  final AthenaIconData iconData;

  final Color backgroundColour;
  final Color cardColour;
  final Color themeColour;

  @override
  _AddNotificationState createState() => _AddNotificationState();
}

class _AddNotificationState extends State<AddNotification> {

  RequestManager requestManager = RequestManager.singleton;
  RecordingManger recorder = RecordingManger.singleton;

  final timeController = new TextEditingController();
  final dateController = new TextEditingController();
  final descriptionController = new TextEditingController();

  String currentTime;
  String currentDate;

  FocusNode timeFocusNode;
  FocusNode dateFocusNode;
  FocusNode descriptionFocusNode;

  bool submitting = false;

  //init page, get current time and set up controllers
  @override
  void initState() {
    recorder.assignParent(this);

    if (widget.currentNotification != null) {
      currentTime = widget.currentNotification.time.split(' ')[0];
      descriptionController.text = widget.currentNotification.description;
      timeController.text = widget.currentNotification.time.split(' ')[0];
      dateController.text = widget.currentNotification.time.split(' ')[1];
    }else{
      descriptionController.text = "";
    }

    dateFocusNode = new FocusNode();
    descriptionFocusNode = new FocusNode();
    timeFocusNode = new FocusNode();
    super.initState();
  }

  @override
  void didUpdateWidget(AddNotification oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  //method to check if the page has been edited since opened
  bool isFileEdited() {
    if (widget.currentNotification == null) {
      if (descriptionController.text == "") {
        return false;
      }
      else {
        return true;
      }
    }
    else {
      if (descriptionController.text != widget.currentNotification.description) {
        return true;
      }
      else {
        return false;
      }
    }
  }

  //method to build the page
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
                  title: widget.currentNotification == null ? new Text("Add a New Reminder", style: TextStyle(
                      fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context),
                      fontFamily: widget.fontData.font,
                      color: ThemeCheck.colorCheck(widget.themeColour)
                  )) : new Text(widget.currentNotification.description),
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
                      onPressed: () {setState(() {recorder.recordAudio();});},
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
                                    focusNode: descriptionFocusNode,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    controller: descriptionController,
                                    style: TextStyle(
                                        fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                        fontFamily: widget.fontData.font,
                                        color: widget.fontData.color
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Description",
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: widget.themeColour),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                new SingleChildScrollView(
                                  child: Container(
                                      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                      child: new Theme(
                                          data: ThemeData(
                                              accentColor: widget.themeColour,
                                              dialogBackgroundColor: widget.cardColour,
                                              primaryColor: widget.themeColour,
                                              primaryColorDark: widget.themeColour
                                          ),
                                          //date picker
                                          child: DateTimePickerFormField(
                                              controller: dateController,
                                              initialValue: widget.currentNotification == null ? null :
                                              DateTime(
                                                  int.tryParse(widget.currentNotification.time.split(' ')[0].split('-')[0]),
                                                  int.tryParse(widget.currentNotification.time.split(' ')[0].split('-')[1]),
                                                  int.tryParse(widget.currentNotification.time.split(' ')[0].split('-')[2]),
                                                  0,
                                                  0
                                              ),
                                              format: DateFormat('yyyy-MM-dd'),
                                              inputType: InputType.date,
                                              editable: false,
                                              onChanged: (DateTime dt) {
                                                setState(() =>
                                                dt != null ? currentDate = (dt.year.toString()+"/"+dt.month.toString()+"/"+dt.day.toString()) : null
                                                );

                                                FocusScope.of(context).requestFocus(new FocusNode());
                                              },
                                              style: TextStyle(fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, color: widget.fontData.color),
                                              decoration: InputDecoration(
                                                hintText: "Reminder Date?",
                                                hintStyle: TextStyle(fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),
                                                hasFloatingPlaceholder: false,
                                              ),
                                              initialTime: null
                                          )
                                      )
                                  ),
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
                                        //time picker
                                        child: DateTimePickerFormField(
                                            controller: timeController,
                                            initialValue: widget.currentNotification == null ? null :
                                            DateTime(2000, 03, 07, int.tryParse(widget.currentNotification.time.split(' ')[1].split(':')[0]),
                                                int.tryParse(widget.currentNotification.time.split(' ')[1].split(':')[1])),
                                            format: DateFormat("HH:mm"),
                                            inputType: InputType.time,
                                            editable: false,
                                            onChanged: (DateTime dt) {
                                              setState(() =>
                                              dt != null ? currentTime = (dt.hour.toString()+":"+dt.minute.toString()) : null
                                              );

                                              FocusScope.of(context).requestFocus(new FocusNode());
                                            },
                                            style: TextStyle(fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font, color: widget.fontData.color),
                                            decoration: InputDecoration(
                                              hintText: "Reminder Time?",
                                              hintStyle: TextStyle(fontSize: 24.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),
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
                                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, widget.fontData, widget.cardColour, widget.themeColour, widget.iconData, widget.backgroundColour)],
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
      content: new Text("Do you want to ADD this Reminder to your Reminders?", style: TextStyle(
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

          if (descriptionController.text == "") {
            showYouMustHaveDescriptionDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            String result = await addNotification();
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

  //method that is called when the user exits the page
  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text("Do you want to SAVE this Reminder?", style: TextStyle(
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
            if (descriptionController.text == "") {
              showYouMustHaveDescriptionDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await addNotification();
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

  //method to draw a dialog when the user attempts to submit a reminder without a description
  void showYouMustHaveDescriptionDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("You must have a Description for your Reminder", style: TextStyle(
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

  //method to create or update a reminder
  Future<String> addNotification() async {
    Random random = new Random();
    int id = 0 + random.nextInt(2^53 - 0);

    //create map of tag data
    Map map = {"id": widget.currentNotification == null ? id.toString() : widget.currentNotification.id, "description": descriptionController.text, "time": dateController.text+" "+timeController.text};

    var response = await requestManager.putNotification(map);

    //if null, then the request was a success, retrieve the information
    if (response != "success"){
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
    else{
      //schedule notification
      NotificationPlugin notificationPlugin = NotificationPlugin.singleton;

      var scheduledNotificationDateTime = DateTime.parse(dateController.text+" "+timeController.text);

      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          '01189998819901197253',
          'Athena',
          'Student Life Manager'
      );

      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

      NotificationDetails platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

      await notificationPlugin.localNotificationPlugin.schedule(
          id,
          'You have a reminder',
          descriptionController.text,
          scheduledNotificationDateTime,
          platformChannelSpecifics);
      }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
