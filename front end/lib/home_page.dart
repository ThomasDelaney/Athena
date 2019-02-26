import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/athena_icon_data.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/icon_settings.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'home_tile.dart';
import 'recording_manager.dart';
import 'request_manager.dart';
import 'font_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
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

  bool fontLoaded = false;
  bool iconLoaded = false;

  @override
  void initState() {
    receiveData();
    recorder.assignParent(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    receiveData();
    recorder.assignParent(this);
    super.didChangeDependencies();
  }

  void receiveData() async{
    setState(()  {
      fontLoaded = false;
      iconLoaded = false;
      getCurrentIconData();
      getCurrentFontData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
      endDrawer: new Drawer(
        child: ListView(
          //Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            //drawer header
            DrawerHeader(
              child: Text('Settings', style: TextStyle(fontSize: 25.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "", color: ThemeCheck.colorCheck(Theme.of(context).accentColor) ? Colors.white : Colors.black)),
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
            //fonts option
            ListTile(
              leading: Icon(
                Icons.font_download,
                size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                color: iconLoaded ? iconData.color : Colors.red,
              ),
              title: Text('Fonts', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "")),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete(receiveData);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.insert_emoticon,
                size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                color: iconLoaded ? iconData.color : Colors.red,
              ),
              title: Text('Icons', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "")),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete(receiveData);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.local_offer,
                size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                color: iconLoaded ? iconData.color : Colors.red,
              ),
              title: Text('Tags', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "")),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TagManager()));
              },
            ),
            //sign out option
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                color: iconLoaded ? iconData.color : Colors.red,),
              title: Text('Sign Out', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "")),
              onTap: () {
                signOut();
              },
            ),
          ],
        ),
      ),
      appBar: new AppBar(
        title: new Text("Home", style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : ""),),
        //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
        actions: recorder.recording ? <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.close),
            iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
            onPressed: () {setState(() {recorder.cancelRecording();});},
          ),
        ] : <Widget>[
          // else display the mic button and settings button
          IconButton(
            icon: Icon(Icons.mic),
            iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
            onPressed: () {setState(() {recorder.recordAudio(context);});},
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: fontLoaded && iconLoaded ? new Stack(
        children: <Widget>[
          new Center(
            child: SingleChildScrollView(
              child: new Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
                    child: new HomeTile(title: "Timetables",  icon: Icons.insert_invitation, fontData: fontData, iconData: iconData, route: TimetablePage(initialDay: DateTime.now().weekday > 5 ? "Monday" : weekdays.elementAt(DateTime.now().weekday-1),)),
                  ),
                  new Container(
                    padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
                    child: new HomeTile(title: "Subject Hub",  icon: Icons.school, route: SubjectHub(), fontData: fontData, iconData: iconData),
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
                  child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context)],
            ) : new Container()
          ),
        ],
      ) : new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new Container(
              margin: MediaQuery.of(context).viewInsets,
              child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
        ],
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

  void getCurrentIconData() async {

    AthenaIconData data = await requestManager.getIconData();

    setState(() {
      iconLoaded = true;
      iconData = new AthenaIconData(data.color, data.size);
    });
  }

  //method to display sign out dialog that notifies user that they will be signed out, when OK is pressed, handle the sign out
  void signOut()
  {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text("You are about to be Signed Out", style: TextStyle(fontFamily: fontData.font)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK", style: TextStyle(fontFamily: fontData.font)))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => signOutDialog);
  }

  //clear relevant shared preference data
  void handleSignOut() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("id");
    await prefs.remove("refreshToken");

    //clear the widget stack and route user to the login page
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
  }
}
