import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/add_result.dart';
import 'package:my_school_life_prototype/font_settings.dart';
import 'package:my_school_life_prototype/login_page.dart';
import 'package:my_school_life_prototype/recording_manager.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_result.dart';

class TestResults extends StatefulWidget {

  final Subject subject;

  TestResults({Key key, this.subject}) : super(key: key);

  @override
  _TestResultsState createState() => _TestResultsState();
}

class _TestResultsState extends State<TestResults> {
  @override

  bool submitting = false;

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String font = "";

  List<TestResult> resultsList = new List<TestResult>();
  bool resultsLoaded = false;

  void retrieveData() async {
    resultsList.clear();
    resultsLoaded = false;
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
                child: new Card(
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text("Add Test Results By Using the", textAlign: TextAlign.center, style: TextStyle(fontFamily: font, fontSize: 24.0), ),
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
      rList = ListView.builder(
        itemCount: resultsList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
              onLongPress: () => {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Card(
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      elevation: 3.0,
                      child: new ListTile(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(currentResult: resultsList[position], subject: widget.subject,))).whenComplete(retrieveData),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        leading: Container(
                          padding: EdgeInsets.only(right: 12.0),
                          decoration: new BoxDecoration(
                              border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))
                          ),
                          child: Icon(Icons.school, color: Colors.redAccent, size: 32.0,),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                resultsList[position].title,
                                style: TextStyle(fontSize: 24.0, fontFamily: font),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width/3.5,
                              child: Text(
                                resultsList[position].score.toString()+"%",
                                style: TextStyle(fontSize: 24.0, fontFamily: font, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        trailing: GestureDetector(
                          child: Icon(Icons.delete, size: 32.0, color: Color.fromRGBO(70, 68, 71, 1)),
                          onTap: () => deleteTestResultDialog(resultsList[position])
                          ),
                      )
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
            endDrawer: new Drawer(
              child: ListView(
                //Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  //drawer header
                  DrawerHeader(
                    child: Text('Settings', style: TextStyle(fontSize: 25.0, fontFamily: font)),
                    decoration: BoxDecoration(
                      color: Colors.red,
                    ),
                  ),
                  //fonts option
                  ListTile(
                    leading: Icon(Icons.font_download),
                    title: Text('Fonts', style: TextStyle(fontSize: 20.0, fontFamily: font)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings()));
                    },
                  ),
                  //sign out option
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sign Out', style: TextStyle(fontSize: 20.0, fontFamily: font)),
                    onTap: () {
                      signOut();
                    },
                  ),
                ],
              ),
            ),
            appBar: new AppBar(
              title: Text("Test Results", style: TextStyle(fontFamily: font)),
              //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
              actions: recorder.recording ? <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.close),
                  iconSize: 30.0,
                  onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
                ),
              ] : <Widget>[
                IconButton(
                  icon: Icon(Icons.add_circle),
                  iconSize: 30.0,
                  onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(subject: widget.subject,))).whenComplete(retrieveData);},
                ),
                // else display the mic button and settings button
                IconButton(
                  icon: Icon(Icons.mic),
                  iconSize: 30.0,
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
                                margin: MediaQuery.of(context).padding,
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
      content: new Text("You are about to be Signed Out", style: TextStyle(fontFamily: font)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK", style: TextStyle(fontFamily: font)))
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
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Test Result Deleted!')));
      retrieveData();
    }
    //else the response ['response']  is not null, then print the error message
    else {
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error has occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {
            Navigator.pop(context); /*submit(false);*/
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
      content: new Text("Do you want to DELETE this Test Result?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
          fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteTestResult(result);
          submit(false);
        },
            child: new Text("YES",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
