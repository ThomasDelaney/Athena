import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/background_settings.dart';
import 'package:Athena/card_settings.dart';
import 'package:Athena/font_settings.dart';
import 'package:Athena/icon_settings.dart';
import 'package:Athena/sign_out.dart';
import 'package:Athena/tag_manager.dart';
import 'package:Athena/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'request_manager.dart';

//Widget that displays the settings that allow the user to change the font used in the application
class DyslexiaFriendlySettings extends StatefulWidget {
  @override
  _DyslexiaFriendlySettingsState createState() => _DyslexiaFriendlySettingsState();
}

class _DyslexiaFriendlySettingsState extends State<DyslexiaFriendlySettings> {

  bool submitting = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  FontData fontData;
  bool fontLoaded = false;

  AthenaIconData iconData;
  bool iconLoaded = false;

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

  bool enabled = false;
  bool loaded = false;

  @override
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didUpdateWidget(DyslexiaFriendlySettings oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  void retrieveData() async {
    iconLoaded = false;
    fontLoaded = false;
    cardColourLoaded = false;
    themeColourLoaded = false;
    backgroundColourLoaded = false;
    loaded = false;
    await getCurrentDyslexiaFriendlyData();
    await getIconData();
    await getFontData();
    await getBackgroundColour();
    await getThemeColour();
    await getCardColour();
  }

  //get current font from shared preferences if present
  void getCurrentDyslexiaFriendlyData() async {

    bool data = await requestManager.getDyslexiaFriendlyModeEnabled();

    setState(() {
      loaded = true;
      enabled = data;
    });
  }

  //get current font from shared preferences if present
  void getFontData() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        fontLoaded = true;
        fontData = new FontData(
            prefs.getString("font"), Color(prefs.getInt("fontColour")),
            prefs.getDouble("fontSize"));
      });
    }
  }

  //get current font from shared preferences if present
  void getCardColour() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        cardColourLoaded = true;
        cardColour = Color(prefs.getInt("cardColour"));
      });
    }
  }

  void getBackgroundColour() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        backgroundColourLoaded = true;
        backgroundColour = Color(prefs.getInt("backgroundColour"));
      });
    }
  }

  void getThemeColour() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        themeColourLoaded = true;
        themeColour = Color(prefs.getInt("themeColour"));
      });
    }
  }

  //get current icon settings from shared preferences if present
  void getIconData() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        iconLoaded = true;
        iconData = new AthenaIconData(
            Color(prefs.getInt("iconColour")),
            prefs.getDouble("iconSize"));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
            backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
            key: _scaffoldKey,
            appBar: new AppBar(
              iconTheme: IconThemeData(
                  color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white
              ),
              backgroundColor: themeColourLoaded ? themeColour : Color.fromRGBO(113, 180, 227, 1),
              title: Text("Dyslexia Friendly Mode", style: TextStyle(fontSize: 24*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "")),
              //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
              actions: recorder.recording ? <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
                ),
              ] : <Widget>[
                IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                ),
                // else display the mic button and settings button
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {if(this.mounted){setState(() {recorder.recordAudio(context);});}},
                ),
              ],
            ),
            resizeToAvoidBottomPadding: false,
            body: new Stack(
              children: <Widget>[
                loaded && fontLoaded && iconLoaded && themeColourLoaded && cardColourLoaded && backgroundColourLoaded ? new ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    new Card(
                      color: cardColour,
                      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      elevation: 3.0,
                      child: new Container(
                        margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                                child: Text(
                                    "Tap the Switch to Turn on Dylsexia Friendly Mode!",
                                    style: TextStyle(
                                        fontFamily: this.fontData.font,
                                        color: fontData.color != null ? fontData.color : Colors.black,
                                        fontSize: fontData.size != null ? 24.0*fontData.size : 35.0
                                    ))
                            ),
                            SizedBox(height: 20.0*ThemeCheck.orientatedScaleFactor(context)),
                            Container(
                              alignment: Alignment.center,
                              width: 35*1.85*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                              height: 18*1.85*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                              child: Transform.scale(
                                alignment: Alignment.center,
                                scale: 1.5*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                                child: new Switch(
                                  value: enabled,
                                  activeColor: themeColour,
                                  inactiveThumbColor: ThemeCheck.lightColorOfColor(themeColour),
                                  onChanged: ((value) async {

                                    setState(() {
                                      enabled = value;

                                      if (value){
                                        enableDyslexiaFriendlyColours().whenComplete((){
                                          submit(true);
                                          retrieveData();
                                          submit(false);
                                        });
                                      }
                                      else if (!value){
                                        disableDyslexiaFriendlyColours().whenComplete((){
                                          submit(true);
                                          retrieveData();
                                          submit(false);
                                        });
                                      }
                                    });
                                  })
                                )
                              )
                            )
                          ],
                        ),
                      )
                    ),
                  ],
                ) : new Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      new Container(
                          margin: MediaQuery.of(context).viewInsets,
                          child: new Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                new Container(
                                  child: Image.asset("assets/icon/icon3.png", width: 200*ThemeCheck.orientatedScaleFactor(context), height: 200*ThemeCheck.orientatedScaleFactor(context),),
                                ),
                                new ModalBarrier(color: Colors.black54, dismissible: false,),
                              ]
                          )
                      ),
                      new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),))
                    ]
                ),
                new Container(
                    alignment: Alignment.center,
                    child: recorder.recording ?
                    new Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        new Container(
                            margin: MediaQuery.of(context).viewInsets,
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData)],) : new Container()
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
    );
  }

  //method to submit the new font
  Future<void> enableDyslexiaFriendlyColours() async
  {
    submit(true);
    await requestManager.putDyslexiaFriendlyModeEnabled(enabled);
    await ThemeCheck.activateDyslexiaFriendlyMode();
    submit(false);
  }

  //method to submit the new font
  Future<void> disableDyslexiaFriendlyColours() async
  {
    submit(true);
    await requestManager.putDyslexiaFriendlyModeEnabled(enabled);
    await ThemeCheck.disableDyslexiaFriendlyMode();
    submit(false);
  }

  //change submission state
  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }

  //create an error alert dialog and display it to the user
  void showErrorDialog()
  {
    submit(false);

    AlertDialog errorDialog = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("An Error has occured. Please try again", style: TextStyle(
          fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: fontData.font,
          color: fontData.color
      )),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(
            fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: fontData.font,
            fontWeight: FontWeight.bold,
            color: themeColour
        )))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }
}
