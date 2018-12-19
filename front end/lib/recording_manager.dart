import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:dio/dio.dart';
import 'package:my_school_life_prototype/timetable_page.dart';
import 'request_manager.dart';

class RecordingManger
{
  static final RecordingManger singleton = new RecordingManger._internal();

  factory RecordingManger() {
    return singleton;
  }

  RecordingManger._internal();

  bool _recorderLoading = false;
  bool _recording = false;

  bool get recording => _recording;
  bool get recorderLoading => _recorderLoading;

  RequestManager requestManager = RequestManager.singleton;

  //URI for audio file from recording
  String uri = "";

  //object used to access the devices microphone
  FlutterSound flutterSound = new FlutterSound();

  String font = "";

  //Dio object, used to make rich HTTP requests
  Dio dio = new Dio();

  //stream subscription is used to keep track of the user recording
  StreamSubscription<RecordStatus> audioSubscription = null;

  //method that records audio
  void recordAudio(BuildContext context) async
  {
    this._recorderLoading = true;
    this._recording = true;

    //get the file URI and start recording
    this.uri =  await flutterSound.startRecorder(null);
    audioSubscription = flutterSound.onRecorderStateChanged.listen((e) {});
  }

  //method to cancel recording at any time
  void cancelRecording()
  {
    this._recording = false;

    //cancel the audio subscription
    if (audioSubscription != null) {
      audioSubscription.cancel();
      audioSubscription = null;
    }
  }

  //method called when the user manually stops the recording for their command to be processed
  void stopRecording(BuildContext context) async
  {
    //stop the recorder
    await flutterSound.stopRecorder();

    this._recorderLoading = false;

    //cancel the audio subscription
    if (audioSubscription != null) {
      audioSubscription.cancel();
      audioSubscription = null;

      var result = requestManager.command(uri, context);

      if (result == "error") {
        showCannotUnderstandError(context);
      }
      else {
        if (result.data['function'] == "timetable") {

          this._recording = false;

          //static list of days
          List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

          //if the day from the response object is not in the list, then display and error saying the user does not have classes for that day
          if (!weekdays.contains(result.data['day'])) {
            AlertDialog cannotUnderstand = new AlertDialog(
              content: new Text("You don't have any classes for this day", style: TextStyle(fontFamily: font),),
              actions: <Widget>[
                new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font)))
              ],
            );

            showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
          }
          else {
            //else go to the timetables page and pass in the day
            Navigator.push(context, MaterialPageRoute(builder: (context) => TimetablePage(initialDay: result.data['day'])));
          }
        }
        else{
          //else display cannot understand error
          showCannotUnderstandError(context);
        }
      }
    }
  }

  //alert dialog thats displayed when the recorder could not understand your command
  void showCannotUnderstandError(BuildContext context)
  {
    //cancel the recording
    cancelRecording();

    AlertDialog cannotUnderstand = new AlertDialog(
      content: new Text("Sorry, I could not understand you! Please try again", style: TextStyle(fontFamily: font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
  }

  //alert dialog that notifies the user if an error has occurred
  void showErrorDialog(BuildContext context)
  {
    AlertDialog errorDialog = new AlertDialog(
      content: new Text("An Error has occured. Please try again", style: TextStyle(fontFamily: font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  Card drawRecordingCard(BuildContext context)
  {
    return Card(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0), child: new Text("Recording", textAlign: TextAlign.center, textScaleFactor: 1.5, style: TextStyle(fontFamily: font),)),
              //if the user has stopped the recorder then display a circular progress indicator, else display a large stop button
              recorderLoading ?
              IconButton(
                iconSize: 80.0,
                color: Colors.red,
                icon: Icon(Icons.stop),
                //if the stop button is pressed then stop the recording
                onPressed: () => stopRecording(context),
              ) : new Padding(padding: EdgeInsets.all(20.0), child: new SizedBox(width: 45.0, height: 45.0, child: new CircularProgressIndicator(strokeWidth: 5.0))),
            ],
          ),
        )
    );
  }
}