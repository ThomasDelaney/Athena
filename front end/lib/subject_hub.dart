import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/athena_icon_data.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/home_page.dart';
import 'package:my_school_life_prototype/icon_settings.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'home_tile.dart';
import 'recording_manager.dart';
import 'request_manager.dart';
import 'font_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'add_subject.dart';
import 'subject.dart';
import 'subject_hub_tile.dart';

class SubjectHub extends StatefulWidget {
  @override
  SubjectHubState createState() => SubjectHubState();
}

class SubjectHubState extends State<SubjectHub> {

  RequestManager requestManager = RequestManager.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  bool subjectsLoaded = false;

  bool submitting = false;

  bool fontLoaded = false;
  bool iconLoaded = false;

  List<Subject> subjectList = new List<Subject>();

  FontData fontData;
  AthenaIconData iconData;

  @override
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
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
  void didUpdateWidget(SubjectHub oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  void retrieveData() {
    iconLoaded = false;
    fontLoaded = false;
    subjectsLoaded = false;
    subjectList.clear();
    getSubjects();
    getIconData();
    getFontData();
  }

  @override
  Widget build(BuildContext context) {

    ListView sList;

    if (subjectList.length == 0 && subjectsLoaded) {
      sList = new ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          new Container(
              margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: new Card(
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text("Add Subjects By Using the", textAlign: TextAlign.center, style: TextStyle(fontFamily: fontData.font, fontSize: 24.0), ),
                        new SizedBox(height: 10.0,),
                        new Icon(Icons.add_circle, size: 40.0, color: Colors.grey,),
                      ]
                  ),
                ),
              )
          ),
        ],
      );
    }
    else {
      sList = ListView.builder(
        itemCount: subjectList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
              onLongPress: () => {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  SubjectHubTile(
                    iconData: iconData,
                    fontData: fontData,
                    subject: subjectList.elementAt(position), state: this,)
                ],
              )
          );
        },
      );
    }

    return Stack(
      children: <Widget>[
        Scaffold(
            key: _scaffoldKey,
            //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
            endDrawer: Container(
              width: MediaQuery.of(context).size.width/1.25,
              child: new Drawer(
                child: ListView(
                  //Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    //drawer header
                    DrawerHeader(
                      child: Text('Settings', style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: ThemeCheck.colorCheck(Theme.of(context).accentColor) ? Colors.white : Colors.black,
                      )
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                      ),
                    ),
                    //fonts option
                    ListTile(
                      leading: Icon(
                        Icons.font_download,
                        size: iconLoaded ? 20.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                        color: iconLoaded ? iconData.color : Colors.red,
                      ),
                      title: Text('Fonts', style: TextStyle(fontSize: fontLoaded ? 20.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 20.0, fontFamily: fontLoaded ? fontData.font : "")),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete(retrieveData);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.insert_emoticon,
                        size: iconLoaded ? 20.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                        color: iconLoaded ? iconData.color : Colors.red,
                      ),
                      title: Text('Icons', style: TextStyle(fontSize: fontLoaded ? 20.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 20.0, fontFamily: fontLoaded ? fontData.font : "")),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete(retrieveData);
                      },
                    ),
                    //sign out option
                    ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        size: iconLoaded ? 20.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                        color: iconLoaded ? iconData.color : Colors.red,
                      ),
                      title: Text('Sign Out', style: TextStyle(fontSize: fontLoaded ? 20.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 20.0, fontFamily: fontLoaded ? fontData.font : "")),
                      onTap: () {
                        signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),
            appBar: new AppBar(
              title: new Text("Subject Hub", style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : ""),),
              //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
              actions: recorder.recording ? <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      recorder.cancelRecording();
                    });
                  },
                ),
              ] : <Widget>[
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                ),
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddSubject(fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),)))
                      .whenComplete(retrieveData),
                ),
                // else display the mic button and settings button
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    setState(() {
                      recorder.recordAudio(context);
                    });
                  },
                ),
                Builder(
                  builder: (context) =>
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                ),
              ],
            ),
            body: new Stack(
              children: <Widget>[
                new Center(
                  child: subjectsLoaded && fontLoaded && iconLoaded ? sList : new SizedBox(width: 50.0,
                      height: 50.0,
                      child: new CircularProgressIndicator(strokeWidth: 5.0,)),
                ),
                new Container(
                    child: recorder.recording ?
                    new Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        new Container(
                            child: new ModalBarrier(
                              color: Colors.black54, dismissible: false,)),
                        recorder.drawRecordingCard(context)
                      ],) : new Container()
                ),
              ],
            )

        ),
        submitting ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
          ],
        )
            : new Container()
      ],
    );
  }

  //method to display sign out dialog that notifies user that they will be signed out, when OK is pressed, handle the sign out
  void signOut() {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text(
          "You are about to be Signed Out", style: TextStyle(fontFamily: fontData.font)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(),
            child: new Text("OK", style: TextStyle(fontFamily: fontData.font)))
      ],
    );

    showDialog(context: context,
        barrierDismissible: false,
        builder: (_) => signOutDialog);
  }

  //clear relevant shared preference data
  void handleSignOut() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("id");
    await prefs.remove("refreshToken");

    //clear the widget stack and route user to the login page
    Navigator.pushNamedAndRemoveUntil(
        context, LoginPage.routeName, (Route<dynamic> route) => false);
  }

  void getSubjects() async {
    List<Subject> reqSubjects = await requestManager.getSubjects();
    this.setState(() {
      subjectList = reqSubjects;
      subjectsLoaded = true;
    });
  }

  void deleteSubject(String id, String title) async {
    var response = await requestManager.deleteSubject(id, title);

    //if null, then the request was a success, retrieve the information
    if (response == "success") {
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content: Text('Subject Deleted!', style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font),)));
      retrieveData();
    }
    //else the response ['response']  is not null, then print the error message
    else {
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error has occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {
            Navigator.pop(context);
          }, child: new Text("OK"))
        ],
      );

      showDialog(context: context,
          barrierDismissible: true,
          builder: (_) => responseDialog);
    }
  }

  void deleteSubjectDialog(String id, String title) {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text(
        "Do you want to DELETE this SUBJECT and all its DATA?", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
          fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteSubject(id, title);
          submit(false);
        },
            child: new Text("YES",
              style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold,),)),
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