import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/add_result.dart';
import 'package:my_school_life_prototype/athena_icon_data.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/font_settings.dart';
import 'package:my_school_life_prototype/home_page.dart';
import 'package:my_school_life_prototype/icon_settings.dart';
import 'package:my_school_life_prototype/login_page.dart';
import 'package:my_school_life_prototype/recording_manager.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/subject.dart';
import 'package:my_school_life_prototype/tag_manager.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_result.dart';

class TestResults extends StatefulWidget {

  final Subject subject;

  TestResults({Key key, this.subject}) : super(key: key);

  @override
  _TestResultsState createState() => _TestResultsState();
}

class _TestResultsState extends State<TestResults> {

  bool submitting = false;

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String font = "";

  List<TestResult> resultsList = new List<TestResult>();
  bool resultsLoaded = false;

  bool fontLoaded = false;
  FontData fontData;

  AthenaIconData iconData;
  bool iconLoaded = false;

  //get current font from shared preferences if present
  void getFontData() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState((){
        fontLoaded = true;
        fontData = new FontData(prefs.getString("font"), Color(prefs.getInt("fontColour")), prefs.getDouble("fontSize"));
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

  void retrieveData() async {
    fontLoaded = false;
    iconLoaded = false;
    resultsList.clear();
    resultsLoaded = false;
    await getIconData();
    await getFontData();
    await getTestResults();
  }

  @override
  void initState() {
    retrieveData();
    super.initState();
  }


  Widget build(BuildContext context) {

    ListView rList;

    if (resultsList.length == 0 && resultsLoaded) {
      rList = new ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          new Container(
              margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: new GestureDetector(
                  onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(subject: widget.subject,))).whenComplete(retrieveData);},
                  child: new Card(
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text("Add Test Results By Using the", textAlign: TextAlign.center, style: TextStyle(fontSize: 24*fontData.size, fontFamily: fontData.font, color: fontData.color,), ),
                          new SizedBox(height: 10.0,),
                          new Icon(Icons.add_circle, size: 40.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: Colors.grey,),
                        ]
                    ),
                  ),
                ),
              )
          ),
        ],
      );
    }
    else {
      rList = ListView.builder(
        itemCount: resultsList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(currentResult: resultsList[position], subject: widget.subject, fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0)))).whenComplete(retrieveData),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context)),
                  Card(
                    margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    elevation: 3.0,
                    child: new Container(
                      padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
                      child: new Row(
                        children: <Widget>[
                          Expanded(
                            child: new ConstrainedBox(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                              child: new Wrap(
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.school, color: Color(int.tryParse(widget.subject.colour)), size: 32.0*iconData.size,),
                                  new SizedBox(width: 15.0*ThemeCheck.orientatedScaleFactor(context),),
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        resultsList[position].title,
                                        style: TextStyle(fontSize: 24*fontData.size, fontFamily: fontData.font, color: fontData.color),
                                      ),
                                      SizedBox(height: 5.0*ThemeCheck.orientatedScaleFactor(context)),
                                      Container(
                                        child: Text(
                                          resultsList[position].score.toString()+"%",
                                          style: TextStyle(fontSize: 24*fontData.size, fontFamily: fontData.font, color: fontData.color, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.delete, color: ThemeCheck.errorColorOfColor(iconData.color)),
                              iconSize: 32*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                              onPressed: () => deleteTestResultDialog(resultsList[position])
                          )
                        ],
                      ),
                    ),
                  )
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
                        fontSize: fontLoaded ? 20.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 20.0,
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
                    leading: Icon(Icons.font_download),
                    title: Text('Fonts', style: TextStyle(fontSize: 20.0, fontFamily: fontLoaded ? fontData.font : "")),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete(retrieveData);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.insert_emoticon),
                    title: Text('Icons', style: TextStyle(fontSize: 20.0, fontFamily: fontLoaded ? fontData.font : "")),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete(retrieveData);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.local_offer),
                    title: Text('Tags', style: TextStyle(fontSize: 20.0, fontFamily: fontLoaded ? fontData.font : "")),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TagManager()));
                    },
                  ),
                  //sign out option
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sign Out', style: TextStyle(fontSize: 20.0, fontFamily: fontLoaded ? fontData.font : "")),
                    onTap: () {
                      signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
            appBar: new AppBar(
              backgroundColor: Color(int.tryParse(widget.subject.colour)),
              title: Text("Test Results", style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "")),
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
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(subject: widget.subject, fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0)))).whenComplete(retrieveData);},
                ),
                // else display the mic button and settings button
                IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {if(this.mounted){setState(() {recorder.recordAudio(context);});}},
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ],
            ),
            body: Stack(
                children: <Widget>[
                  new Center(
                  child: resultsLoaded ? rList : new SizedBox(width: 50.0,
                      height: 50.0,
                      child: new CircularProgressIndicator(strokeWidth: 5.0,)),
                    ),
                    //container for the recording card, show if recording, show blank container if not
                    new Container(
                        alignment: Alignment.center,
                        child: recorder.recording ?
                        new Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            new Container(
                                margin: MediaQuery.of(context).viewInsets,
                                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context)],) : new Container()
                    ),
                  ]
              ),
        ),
        //container for the circular progress indicator when submitting an image, show if submitting, show blank container if not
        submitting ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                margin: MediaQuery.of(context).padding,
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
          ],
        ): new Container()
      ],
    );
  }

  //method to display sign out dialog that notifies user that they will be signed out, when OK is pressed, handle the sign out
  void signOut()
  {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text("You are about to be Signed Out", style: TextStyle(fontSize: 18.0*fontData.size, fontFamily: fontData.font)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK", style: TextStyle(fontSize: 18.0*fontData.size, fontFamily: fontData.font)))
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

  void getTestResults() async {
    List<TestResult> reqResults = await requestManager.getTestResults(widget.subject.id);
    this.setState(() {
      resultsList = reqResults;
      resultsLoaded = true;
    });
  }

  void deleteTestResult(TestResult result) async {
    var response = await requestManager.deleteTestResult(result.id, widget.subject.id);

    //if null, then the request was a success, retrieve the information
    if (response == "success") {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Test Result Deleted!', style: TextStyle(fontSize: 18*fontData.size, fontFamily: fontData.font),)));
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

  void deleteTestResultDialog(TestResult result) {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to DELETE this Test Result?", style: TextStyle(fontSize: 18*fontData.size, fontFamily: fontData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
          fontSize: 18*fontData.size, fontFamily: fontData.font,),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteTestResult(result);
          submit(false);
        },
            child: new Text("YES",
              style: TextStyle(fontSize: 18*fontData.size, fontFamily: fontData.font,),)),
      ],
    );

    showDialog(context: context,
        barrierDismissible: false,
        builder: (_) => areYouSure);
  }

  void submit(bool state)
  {
    if (this.mounted) {
      setState(() {
        submitting = state;
      });
    }
  }
}
