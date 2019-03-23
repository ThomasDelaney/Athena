import 'package:Athena/background_settings.dart';
import 'package:Athena/dyslexia_friendly_settings.dart';
import 'package:Athena/journal_date_picker.dart';
import 'package:Athena/notifications.dart';
import 'package:Athena/sign_out.dart';
import 'package:Athena/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/card_settings.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/icon_settings.dart';
import 'package:Athena/theme_check.dart';
import 'home_tile.dart';
import 'recording_manager.dart';
import 'request_manager.dart';
import 'font_settings.dart';
import 'subject_hub.dart';
import 'timetable_page.dart';
import 'dart:core';
import 'tag_manager.dart';

//Widget that displays the "home" page, this will actually be page for the virtual hardback and journal that displays notes and files, stored by the user
class HomePage extends StatefulWidget {
  HomePage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/HomePage";
  final String pageTitle;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  //list of the days of the week for timetable
  List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

  FontData fontData;
  AthenaIconData iconData;
  Color cardColour;
  Color backgroundColour;
  Color themeColour;

  bool fontLoaded = false;
  bool iconLoaded = false;
  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  @override
  void initState() {
    retrieveData();
    recorder.assignParent(this);
    super.initState();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  void retrieveData() async{
    setState(()  {
      fontLoaded = false;
      themeColourLoaded = false;
      backgroundColourLoaded = false;
      cardColourLoaded = false;
      iconLoaded = false;
      getCurrentBackgroundColour();
      getCurrentThemeColour();
      getCurrentIconData();
      getCurrentFontData();
      getCurrentCardColour();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
      //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
      endDrawer: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded ?
      new SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: new Drawer(
          child: new Container(
            color: cardColour,
            child: ListView(
              //Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                //drawer header
                DrawerHeader(
                  child: Text('Settings', style: TextStyle(fontSize: 25.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "", color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white)),
                  decoration: BoxDecoration(
                    color: themeColour,
                  ),
                ),
                //fonts option
                ListTile(
                  leading: Icon(
                    Icons.font_download,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Fonts',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.insert_emoticon,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Icons',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.color_lens,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Theme Colour',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettings(
                      backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
                      cardColour: cardColourLoaded ? cardColour : Colors.white,
                      fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                      iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                    ))).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.format_paint,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Background Colour',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BackgroundSettings(
                      cardColour: cardColourLoaded ? cardColour : Colors.white,
                      fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                      themeColour: themeColourLoaded ? themeColour : Colors.white,
                      iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                    ))).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.colorize,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Card Colour',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CardSettings(
                      fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                      themeColour: themeColourLoaded ? themeColour : Colors.white,
                      backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
                      iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                    ))).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.invert_colors,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Dyslexia Friendly Mode',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DyslexiaFriendlySettings())).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.local_offer,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TagManager())).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                //sign out option
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),),
                  title: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () => SignOut.signOut(context, fontData, cardColour, themeColour),
                ),
              ],
            ),
          ),
        ),
      ) : new Container(),
      appBar: new AppBar(
        iconTheme: IconThemeData(
          color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white
        ),
        backgroundColor: themeColourLoaded ? themeColour : Color.fromRGBO(113, 180, 227, 1),
        title: new Text("Home", style: TextStyle(fontFamily: fontLoaded ? fontData.font : "", color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white),),
        //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
        actions: recorder.recording ? <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {setState(() {recorder.cancelRecording();});},
          ),
        ] : <Widget>[
          // else display the mic button and settings button
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded? IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {setState(() {recorder.recordAudio(context);});},
          ) : new Container(),
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded ? Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ) : new Container(),
        ],
      ),
      body: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded ? new Stack(
        children: <Widget>[
          new Center(
            child: SingleChildScrollView(
              child: new Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
                    child: new HomeTile(title: "Timetables",  icon: Icons.insert_invitation, state: this, fontData: fontData, themeColour: themeColour, iconData: iconData, route: TimetablePage(initialDay: DateTime.now().weekday > 5 ? "Monday" : weekdays.elementAt(DateTime.now().weekday-1),)),
                  ),
                  new Container(
                    padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
                    child: new HomeTile(title: "Subject Hub",  icon: Icons.school, route: SubjectHub(), fontData: fontData, iconData: iconData, themeColour: themeColour, state: this,),
                  ),
                  new Container(
                    padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
                    child: new HomeTile(title: "Journal",  icon: Icons.import_contacts, route: JournalDatePicker(), fontData: fontData, iconData: iconData, themeColour: themeColour, state: this,),
                  ),
                  new Container(
                    padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
                    child: new HomeTile(title: "Reminders",  icon: Icons.notifications_active, route: Notifications(), fontData: fontData, iconData: iconData, themeColour: themeColour, state: this,),
                  )
                ],
              ),
            ),
          ),
          new Container(
            child: recorder.recording ?
            new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                  margin: MediaQuery.of(context).viewInsets,
                  child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData)],
            ) : new Container()
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
        )
    );
  }

  void getCurrentFontData() async {

    FontData data = await requestManager.getFontData();

    setState(() {
      fontLoaded = true;
      fontData = new FontData(data.font, data.color, data.size);
    });
  }

  void getCurrentCardColour() async {

    Color data = await requestManager.getCardColour();

    setState(() {
      cardColourLoaded = true;
      cardColour = data;
    });
  }

  void getCurrentBackgroundColour() async {

    Color data = await requestManager.getBackgroundColour();

    setState(() {
      backgroundColourLoaded = true;
      backgroundColour = data;
    });
  }

  void getCurrentThemeColour() async {

    Color data = await requestManager.getThemeColour();

    setState(() {
      themeColourLoaded = true;
      themeColour = data;
    });
  }

  void getCurrentIconData() async {

    AthenaIconData data = await requestManager.getIconData();

    setState(() {
      iconLoaded = true;
      iconData = new AthenaIconData(data.color, data.size);
    });
  }
}
