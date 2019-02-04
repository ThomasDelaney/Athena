import 'package:flutter/material.dart';
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

  List<Subject> subjectList = new List<Subject>();

  String font = "";

  @override
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didUpdateWidget(SubjectHub oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  void retrieveData() {
    subjectsLoaded = false;
    subjectList.clear();
    getSubjects();
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
                        new Text("Add Subjects By Using the", textAlign: TextAlign.center, style: TextStyle(fontFamily: font, fontSize: 24.0), ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  SubjectHubTile(
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
            endDrawer: new Drawer(
              child: ListView(
                //Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  //drawer header
                  DrawerHeader(
                    child: Text('Settings',
                        style: TextStyle(fontSize: 25.0, fontFamily: font)),
                    decoration: BoxDecoration(
                      color: Colors.red,
                    ),
                  ),
                  //fonts option
                  ListTile(
                    leading: Icon(Icons.font_download),
                    title: Text('Fonts',
                        style: TextStyle(fontSize: 20.0, fontFamily: font)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FontSettings()));
                    },
                  ),
                  //sign out option
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sign Out',
                        style: TextStyle(fontSize: 20.0, fontFamily: font)),
                    onTap: () {
                      signOut();
                    },
                  ),
                ],
              ),
            ),
            appBar: new AppBar(
              title: new Text("Subject Hub", style: TextStyle(fontFamily: font),),
              //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
              actions: recorder.recording ? <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.close),
                  iconSize: 30.0,
                  onPressed: () {
                    setState(() {
                      recorder.cancelRecording();
                    });
                  },
                ),
              ] : <Widget>[
                IconButton(
                  icon: Icon(Icons.add_circle),
                  iconSize: 30.0,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddSubject()))
                      .whenComplete(retrieveData),
                ),
                // else display the mic button and settings button
                IconButton(
                  icon: Icon(Icons.mic),
                  iconSize: 30.0,
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
                  child: subjectsLoaded ? sList : new SizedBox(width: 50.0,
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
          "You are about to be Signed Out", style: TextStyle(fontFamily: font)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(),
            child: new Text("OK", style: TextStyle(fontFamily: font)))
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
          new SnackBar(content: Text('Subject Deleted!')));
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

  void deleteSubjectDialog(String id, String title) {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text(
        "Do you want to DELETE this SUBJECT and all its DATA?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
          fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteSubject(id, title);
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
    setState(() {
      submitting = state;
    });
  }
}