import 'dart:async';
import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/background_settings.dart';
import 'package:Athena/design/card_settings.dart';
import 'package:Athena/design/dyslexia_friendly_settings.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/design/font_settings.dart';
import 'package:Athena/design/icon_settings.dart';
import 'package:Athena/design/theme_settings.dart';
import 'package:Athena/journal/journal_date_picker.dart';
import 'package:Athena/reminders/notifications.dart';
import 'package:Athena/subjects/homework_page.dart';
import 'package:Athena/subjects/materials.dart';
import 'package:Athena/subjects/progress.dart';
import 'package:Athena/subjects/subject.dart';
import 'package:Athena/subjects/subject_hub.dart';
import 'package:Athena/subjects/test_results.dart';
import 'package:Athena/subjects/virtual_hardback.dart';
import 'package:Athena/tags/tag.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:Athena/by_tag.dart';
import 'package:Athena/Timetables/timetable_page.dart';
import 'package:Athena/utilities/request_manager.dart';

class RecordingManger
{
  static final RecordingManger singleton = new RecordingManger._internal();

  factory RecordingManger() {
    return singleton;
  }

  RecordingManger._internal();

  State<dynamic> _parent;
  State<dynamic> _oldParent;

  set parent (State<dynamic> newParent) => _parent = newParent;
  set oldParent (State<dynamic> currentParent) => _oldParent = currentParent;

  bool _recorderLoading = false;
  bool _recording = false;

  bool get recording => _recording;
  bool get recorderLoading => _recorderLoading;

  RequestManager requestManager = RequestManager.singleton;

  //URI for audio file from recording
  String uri = "";

  //object used to access the devices microphone
  FlutterSound flutterSound = new FlutterSound();

  //stream subscription is used to keep track of the user recording
  StreamSubscription<RecordStatus> audioSubscription = null;

  //method that records audio
  void recordAudio() async
  {
    _parent.setState((){
      this._recorderLoading = true;
      this._recording = true;
    });

    //get the file URI and start recording
    this.uri =  await flutterSound.startRecorder(null);
    audioSubscription = flutterSound.onRecorderStateChanged.listen((e) {});
  }

  //method to cancel recording at any time
  void cancelRecording() async
  {
    if(_recording){
      //stop the recorder
      await flutterSound.stopRecorder();
    }

    _parent.setState((){this._recording = false;});

    //cancel the audio subscription
    if (audioSubscription != null) {
      audioSubscription.cancel();
      audioSubscription = null;
    }
  }

  void assignParent(State<dynamic> state) {
    if (this._parent == null){
      this.oldParent = state;
    }
    else{
      this.oldParent = this._parent;
    }

    this.parent = state;
  }

  //method called when the user manually stops the recording for their command to be processed
  void stopRecording(BuildContext context, FontData fontData, Color cardColour, Color themeColour, Color backgroundColor, AthenaIconData iconData) async
  {
    //stop the recorder
    await flutterSound.stopRecorder();

    _parent.setState((){
      this._recorderLoading = false;
    });

    //cancel the audio subscription
    if (audioSubscription != null) {
      audioSubscription.cancel();
      audioSubscription = null;

      var result = await requestManager.command(uri);

      if (result == "error") {
        showCannotUnderstandError(context, fontData, cardColour, themeColour);
      }
      else {

        switch(result.data['function'])
        {
          case "timetable":
            _parent.setState((){this._recording = false;});

            //static list of days
            List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

            //if the day from the response object is not in the list, then display and error saying the
            //user does not have classes for that day
            if (!weekdays.contains(result.data['option'])) {
              AlertDialog cannotUnderstand = new AlertDialog(
                backgroundColor: cardColour,
                content: new Text("You don't have any classes for this day", style: TextStyle(
                    fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                    fontFamily: fontData.font,
                    color: fontData.color
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(onPressed: () {
                      Navigator.pop(context);
                    },
                    child: new Text(
                        "OK",
                        style: TextStyle(
                            fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                            fontFamily: fontData.font,
                            fontWeight: FontWeight.bold, color: themeColour
                        )
                    )
                  )
                ],
              );

              showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
            }
            else {
              //else go to the timetables page and pass in the day
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TimetablePage(
                      initialDay: result.data['option']
                  ))
              ).whenComplete(() {
                this.parent = this._oldParent;
              });
            }
            break;

          case "notes":
            _parent.setState((){this._recording = false;});

            List<Tag> reqTags = await requestManager.getTags();
            List<String> tagValues = reqTags.map((tag) => tag.tag.toLowerCase()).toList();

            //if the day from the response object is not in the list, then display and error saying the user does not have classes for that day
            if (!tagValues.contains(result.data['option'].toString().toLowerCase())) {

              AlertDialog cannotUnderstand = new AlertDialog(
                backgroundColor: cardColour,
                content: new Text("You don't have any notes or files with this tag or this tag does not exist", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: fontData.color),),
                actions: <Widget>[
                  new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: themeColour)))
                ],
              );

              showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
            }
            else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ByTagViewer(tag: result.data['option']))).whenComplete(() {
                this.parent = this._oldParent;
              });
            }
            break;

          case "journal":
            _parent.setState((){this._recording = false;});

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => JournalDatePicker())
            ).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;

          case "subjects":
            _parent.setState((){this._recording = false;});

            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubjectHub())
            ).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;

          case "reminders":
            _parent.setState((){this._recording = false;});

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Notifications())
            ).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;

          case "homework":
            _parent.setState((){this._recording = false;});

            Subject fromOption = await Subject.getSubjectByTitle(result.data['option']);

            if (fromOption == null){
              notASubjectDialog(context, fontData, cardColour, themeColour, result.data['option']);
            }
            else{
              Navigator.push
                (context, MaterialPageRoute(
                  builder: (context) => HomeworkPage(subject: fromOption,))
              ).whenComplete(() {
                this.parent = this._oldParent;
              });
            }
            break;

          case "test results":
            _parent.setState((){this._recording = false;});

            Subject fromOption = await Subject.getSubjectByTitle(result.data['option']);

            if (fromOption == null){
              notASubjectDialog(context, fontData, cardColour, themeColour, result.data['option']);
            }
            else{
              Navigator.push(context, MaterialPageRoute(builder: (context) => TestResults(subject: fromOption,))).whenComplete(() {
                this.parent = this._oldParent;
              });
            }
            break;

          case "progress":
            _parent.setState((){this._recording = false;});

            Subject fromOption = await Subject.getSubjectByTitle(result.data['option']);

            if (fromOption == null){
              notASubjectDialog(context, fontData, cardColour, themeColour, result.data['option']);
            }
            else{
              Navigator.push(context, MaterialPageRoute(builder: (context) => Progress(subject: fromOption,))).whenComplete(() {
                this.parent = this._oldParent;
              });
            }
            break;

          case "materials":
            _parent.setState((){this._recording = false;});

            Subject fromOption = await Subject.getSubjectByTitle(result.data['option']);

            if (fromOption == null){
              notASubjectDialog(context, fontData, cardColour, themeColour, result.data['option']);
            }
            else{
              Navigator.push(context, MaterialPageRoute(builder: (context) => Materials(subject: fromOption,))).whenComplete(() {
                this.parent = this._oldParent;
              });
            }
            break;

          case "hardback":
            _parent.setState((){this._recording = false;});

            Subject fromOption = await Subject.getSubjectByTitle(result.data['option']);

            if (fromOption == null){
              notASubjectDialog(context, fontData, cardColour, themeColour, result.data['option']);
            }
            else{
              Navigator.push(context, MaterialPageRoute(builder: (context) => VirtualHardback(subject: fromOption,))).whenComplete(() {
                this.parent = this._oldParent;
              });
            }
            break;

          case "font":
            _parent.setState((){this._recording = false;});

            Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;


          case "icon":
            _parent.setState((){this._recording = false;});

            Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;

          case "background":
            _parent.setState((){this._recording = false;});

            Navigator.push(context, MaterialPageRoute(builder: (context) => BackgroundSettings(
              cardColour: cardColour,
              fontData: fontData,
              themeColour: themeColour,
              iconData: iconData,
            ))).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;

          case "card":
            _parent.setState((){this._recording = false;});

            Navigator.push(context, MaterialPageRoute(builder: (context) => CardSettings(
              backgroundColour: backgroundColor,
              fontData: fontData,
              themeColour: themeColour,
              iconData: iconData,
            ))).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;

          case "theme":
            _parent.setState((){this._recording = false;});

            Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettings(
              backgroundColour: backgroundColor,
              fontData: fontData,
              cardColour: cardColour,
              iconData: iconData,
            ))).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;

          case "dyslexia":
            _parent.setState((){this._recording = false;});

            Navigator.push(context, MaterialPageRoute(builder: (context) => DyslexiaFriendlySettings())).whenComplete(() {
              this.parent = this._oldParent;
            });
            break;
          default:
            showCannotUnderstandError(context, fontData, cardColour, themeColour);
        }
      }
    }
  }

  //alert dialog thats displayed when the recorder could not understand your command
  void showCannotUnderstandError(BuildContext context, FontData fontData, Color cardColour, Color themeColour)
  {
    _parent.setState((){this._recording = false;});
    //cancel the recording
    cancelRecording();

    AlertDialog cannotUnderstand = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("Sorry, I could not understand you! Please try again", style: TextStyle(
          fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: fontData.font,
          color: fontData.color),
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text(
          "OK",
          style: TextStyle(
              fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: fontData.font,
              fontWeight: FontWeight.bold,
              color: themeColour
          ),
        ))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
  }

  void notASubjectDialog(BuildContext context, FontData fontData, Color cardColour, Color themeColour, String notASubject)
  {
    _parent.setState((){this._recording = false;});
    //cancel the recording
    cancelRecording();

    AlertDialog cannotUnderstand = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text(notASubject+" is not a Subject!", style: TextStyle(
          fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: fontData.font,
          color: fontData.color),
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text(
          "OK",
          style: TextStyle(
              fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: fontData.font,
              fontWeight: FontWeight.bold,
              color: themeColour
          ),
        ))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
  }

  Card drawRecordingCard(BuildContext context, FontData fontData, Color cardColour, Color themeColour, AthenaIconData iconData, Color backgroundColour)
  {
    return Card(
        child: Container(
          padding: EdgeInsets.all(20.0*ThemeCheck.orientatedScaleFactor(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0*ThemeCheck.orientatedScaleFactor(context)),
                  child: new Text("Recording",
                    textAlign: TextAlign.center, style:
                    TextStyle(
                        fontSize: 24.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontData.font,
                        color: fontData.color),
                  )
              ),
              //if the user has stopped the recorder then display a circular progress indicator, else display a large stop button
              recorderLoading ?
              IconButton(
                iconSize: 100.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                color: Colors.red,
                icon: Icon(Icons.stop),
                //if the stop button is pressed then stop the recording
                onPressed: () => stopRecording(context, fontData, cardColour, themeColour, backgroundColour, iconData),
              ) : new Padding(
                  padding: EdgeInsets.all(20.0*ThemeCheck.orientatedScaleFactor(context)),
                  child: new SizedBox(
                      width: 50.0*ThemeCheck.orientatedScaleFactor(context),
                      height: 50.0*ThemeCheck.orientatedScaleFactor(context),
                      child: new CircularProgressIndicator(
                          strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context),
                          valueColor: AlwaysStoppedAnimation<Color>(themeColour)
                      )
                  )
              ),
            ],
          ),
        )
    );
  }
}