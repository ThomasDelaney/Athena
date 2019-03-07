import 'dart:async';
import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/theme_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:dio/dio.dart';
import 'package:Athena/by_tag.dart';
import 'package:Athena/timetable_page.dart';
import 'request_manager.dart';
import 'tag.dart';

class RecordingManger
{
  static final RecordingManger singleton = new RecordingManger._internal();

  factory RecordingManger() {
    return singleton;
  }

  RecordingManger._internal();

  State<dynamic> _parent;

  set parent (State<dynamic> newParent) => _parent = newParent;

  bool _recorderLoading = false;
  bool _recording = false;

  bool get recording => _recording;
  bool get recorderLoading => _recorderLoading;

  RequestManager requestManager = RequestManager.singleton;

  //URI for audio file from recording
  String uri = "";

  //object used to access the devices microphone
  FlutterSound flutterSound = new FlutterSound();

  //Dio object, used to make rich HTTP requests
  Dio dio = new Dio();

  //stream subscription is used to keep track of the user recording
  StreamSubscription<RecordStatus> audioSubscription = null;

  //method that records audio
  void recordAudio(BuildContext context) async
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
    this.parent = state;
  }

  //method called when the user manually stops the recording for their command to be processed
  void stopRecording(BuildContext context, FontData fontData, Color cardColour, Color themeColour) async
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

      var result = await requestManager.command(uri, context);

      if (result == "error") {
        showCannotUnderstandError(context, fontData, cardColour, themeColour);
      }
      else {
        if (result.data['function'] == "timetable") {

          _parent.setState((){this._recording = false;});

          //static list of days
          List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

          //if the day from the response object is not in the list, then display and error saying the user does not have classes for that day
          if (!weekdays.contains(result.data['option'])) {
            AlertDialog cannotUnderstand = new AlertDialog(
              backgroundColor: cardColour,
              content: new Text("You don't have any classes for this day", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: fontData.color),),
              actions: <Widget>[
                new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: themeColour)))
              ],
            );

            showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
          }
          else {

            //else go to the timetables page and pass in the day
            Navigator.push(context, MaterialPageRoute(builder: (context) => TimetablePage(initialDay: result.data['option'])));
          }
        }
        else if (result.data['function'] == "notes") {
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => ByTagViewer(tag: result.data['option'])));
          }
        }
        else{
          //else display cannot understand error
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

  Card drawRecordingCard(BuildContext context, FontData fontData, Color cardColour, Color themeColour, AthenaIconData iconData)
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
                onPressed: () => stopRecording(context, fontData, cardColour, themeColour),
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