import 'package:Athena/design/background_settings.dart';
import 'package:Athena/design/card_settings.dart';
import 'package:Athena/design/dyslexia_friendly_settings.dart';
import 'package:Athena/utilities/sign_out.dart';
import 'package:Athena/design/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:Athena/subjects/add_result.dart';
import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/design/font_settings.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/design/icon_settings.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/request_manager.dart';
import 'package:Athena/subjects/subject.dart';
import 'package:Athena/tags/tag_manager.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Athena/subjects/test_result.dart';

//Class for the page that displays all the test results for a subject
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

  List<TestResult> resultsList = new List<TestResult>();
  bool resultsLoaded = false;

  bool fontLoaded = false;
  FontData fontData;

  AthenaIconData iconData;
  bool iconLoaded = false;

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

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

    cardColourLoaded = false;
    backgroundColourLoaded = false;
    themeColourLoaded = false;

    await getBackgroundColour();
    await getThemeColour();
    await getCardColour();

    await getIconData();
    await getFontData();
    await getTestResults();
  }

  @override
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didUpdateWidget(TestResults oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  //method to build the page
  Widget build(BuildContext context) {

    ListView rList;

    //if list is empty, draw a card telling the user that they can add new test result
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
                  onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(
                    subject: widget.subject,
                    cardColour: cardColour,
                    iconData: iconData,
                    backgroundColour: backgroundColour,
                    themeColour: themeColour,
                  ))).whenComplete((){
                    retrieveData();
                    recorder.assignParent(this);
                  });},
                  child: new Card(
                    color: cardColour,
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text("Add Test Results By Using the", textAlign: TextAlign.center, style: TextStyle(fontSize: 24*fontData.size, fontFamily: fontData.font, color: fontData.color,), ),
                          new SizedBox(height: 10.0,),
                          new Icon(Icons.add_circle, size: 40.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color,),
                        ]
                    ),
                  ),
                ),
              )
          ),
        ],
      );
    }
    //else draw the list
    else {
      rList = ListView.builder(
        itemCount: resultsList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(
                  currentResult: resultsList[position],
                  subject: widget.subject,
                  fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                  cardColour: cardColour,
                  iconData: iconData,
                  backgroundColour: backgroundColour,
                  themeColour: themeColour,
              ))).whenComplete((){
                retrieveData();
                recorder.assignParent(this);
              }),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context)),
                  Card(
                    color: cardColour,
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
                                  Icon(Icons.school, color: Color(int.tryParse(widget.subject.colour)), size: 32.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,),
                                  new SizedBox(width: 15.0*ThemeCheck.orientatedScaleFactor(context),),
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        resultsList[position].title,
                                        style: TextStyle(fontSize: 24*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font, color: fontData.color),
                                      ),
                                      SizedBox(height: 5.0*ThemeCheck.orientatedScaleFactor(context)),
                                      Container(
                                        child: Text(
                                          resultsList[position].score.toString()+"%",
                                          style: TextStyle(fontSize: 24*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font, color: fontData.color, fontWeight: FontWeight.bold),
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
          backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
          key: _scaffoldKey,
            //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
          endDrawer: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && resultsLoaded ?
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
                color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour)))
            ),
            backgroundColor: Color(int.tryParse(widget.subject.colour)),
            title: Text(
                "Test Results",
                style: TextStyle(
                    fontFamily: fontLoaded ? fontData.font : "",
                    color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white
                )
            ),
            //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
            actions: recorder.recording ? <Widget>[
              // action button
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
              ),
            ] : <Widget>[
              fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && resultsLoaded ? IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
              ) : new Container(),
              fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && resultsLoaded ? IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(
                    subject: widget.subject,
                    fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                    cardColour: cardColour,
                    iconData: iconData,
                    backgroundColour: backgroundColour,
                    themeColour: themeColour,
                ))).whenComplete((){
                  retrieveData();
                  recorder.assignParent(this);
                });},
              ) : new Container(),
              // else display the mic button and settings button
              fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && resultsLoaded ? IconButton(
                icon: Icon(Icons.mic),
                onPressed: () {if(this.mounted){setState(() {recorder.recordAudio();});}},
              ) : new Container(),
              fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && resultsLoaded ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ) : new Container(),
            ],
          ),
          body: Stack(
            children: <Widget>[
              new Center(
              child: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && resultsLoaded ? rList : new Stack(
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
              //container for the recording card, show if recording, show blank container if not
              new Container(
                  alignment: Alignment.center,
                  child: recorder.recording ?
                  new Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      new Container(
                          margin: MediaQuery.of(context).viewInsets,
                          child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData, backgroundColour)
                    ],
                  ) : new Container()
              ),
            ]
          ),
        ),
        //container for the circular progress indicator when submitting an image, show if submitting, show blank container if not
        submitting ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                margin: MediaQuery.of(context).viewInsets,
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)
            ),
            new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            )
          ],
        ): new Container()
      ],
    );
  }

  //method to get all the test results for a subject
  void getTestResults() async {
    List<TestResult> reqResults = await requestManager.getTestResults(widget.subject.id);
    this.setState(() {
      resultsList = reqResults;
      resultsLoaded = true;
    });
  }

  //method to delete a test result
  void deleteTestResult(TestResult result) async {
    var response = await requestManager.deleteTestResult(result.id, widget.subject.id);

    //if null, then the request was a success, retrieve the information
    if (response == "success") {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Test Result Deleted!', style: TextStyle(fontSize: 18*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font),)));
      retrieveData();
    }
    //else the response ['response']  is not null, then print the error message
    else {
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: cardColour,
        content: new Text("An error has occured please try again", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: fontData.color)),
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

  //method to draw a dialog when the user attempts delete a test result
  void deleteTestResultDialog(TestResult result) {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("Do you want to DELETE this Test Result?", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: fontData.color),),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
            fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: themeColour),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteTestResult(result);
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
    if (this.mounted) {
      setState(() {
        submitting = state;
      });
    }
  }
}