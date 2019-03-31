import 'package:Athena/design/background_settings.dart';
import 'package:Athena/design/card_settings.dart';
import 'package:Athena/design/dyslexia_friendly_settings.dart';
import 'package:Athena/design/font_settings.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/request_manager.dart';
import 'package:Athena/utilities/sign_out.dart';
import 'package:Athena/tags/tag_manager.dart';
import 'package:Athena/design/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/design/icon_settings.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Athena/subjects/add_subject.dart';
import 'package:Athena/subjects/subject.dart';
import 'package:Athena/subjects/subject_hub_tile.dart';

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

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

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
    cardColourLoaded = false;
    backgroundColourLoaded = false;
    themeColourLoaded = false;
    iconLoaded = false;
    fontLoaded = false;
    subjectsLoaded = false;
    subjectList.clear();
    getBackgroundColour();
    getThemeColour();
    getCardColour();
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
                child: new GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddSubject(
                        fontData: fontData,
                        backgroundColour: backgroundColour,
                        cardColour: cardColour,
                        themeColour: themeColour,
                        iconData: iconData,
                      )))
                      .whenComplete((){
                    retrieveData();
                    recorder.assignParent(this);
                  }),
                  child: new Card(
                    color: cardColour,
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text("Add Subjects By Using the", textAlign: TextAlign.center, style: TextStyle(fontFamily: fontData.font, fontSize: 24.0*fontData.size, color: fontData.color), ),
                          new SizedBox(height: 10.0,),
                          new Icon(Icons.add_circle, size: 40.0*iconData.size, color: iconData.color,),
                        ]
                    ),
                  ),
                )
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
                    backgroundColour: backgroundColour,
                    themeColour: themeColour,
                    cardColour: cardColour,
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
            backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
            //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
            endDrawer: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && subjectsLoaded ? new SizedBox(
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
              title: new Text("Subject Hub", style: TextStyle(fontFamily: fontLoaded ? fontData.font : "", color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white),),
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
                fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && subjectsLoaded ? IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                ) : new Container(),
                fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && subjectsLoaded ? IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddSubject(
                        fontData: fontData,
                        backgroundColour: backgroundColour,
                        cardColour: cardColour,
                        themeColour: themeColour,
                        iconData: iconData,
                      )))
                      .whenComplete((){
                    retrieveData();
                    recorder.assignParent(this);
                  }),
                ) : new Container(),
                // else display the mic button and settings button
                fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && subjectsLoaded ? IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    setState(() {
                      recorder.recordAudio();
                    });
                  },
                ) : new Container(),
                fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && subjectsLoaded ? Builder(
                  builder: (context) =>
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                ) : new Container(),
              ],
            ),
            body: new Stack(
              children: <Widget>[
                new Center(
                  child: subjectsLoaded && fontLoaded && iconLoaded ? sList : new Stack(
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
                ),
                new Container(
                    child: recorder.recording ?
                    new Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        new Container(
                            margin: MediaQuery.of(context).viewInsets,
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData, backgroundColour)],
                    ) : new Container()
                ),
              ],
            )

        ),
        submitting ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
          ],
        )
            : new Container()
      ],
    );
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
        backgroundColor: cardColour,
        content: new Text("An error has occured please try again", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: fontData.color),),
        actions: <Widget>[
          new FlatButton(onPressed: () {
            Navigator.pop(context);
          }, child: new Text("OK", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: fontData.color)))
        ],
      );

      showDialog(context: context,
          barrierDismissible: true,
          builder: (_) => responseDialog);
    }
  }

  void deleteSubjectDialog(String id, String title) {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text(
        "Do you want to DELETE this SUBJECT and all its DATA?", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: fontData.color),),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
          fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: themeColour),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteSubject(id, title);
          submit(false);
        },
            child: new Text("YES",
              style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: themeColour),)),
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