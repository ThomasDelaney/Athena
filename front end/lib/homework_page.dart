import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/add_homework.dart';
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
import 'homework.dart';


class HomeworkPage extends StatefulWidget {

  final Subject subject;

  HomeworkPage({Key key, this.subject}) : super(key: key);

  @override
  _HomeworkPageState createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {

  bool submitting = false;

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String font = "";

  List<Homework> homeworkList = new List<Homework>();
  bool homeworkLoaded = false;

  bool fontLoaded = false;
  FontData fontData;

  AthenaIconData iconData;
  bool iconLoaded = false;

  void retrieveData() async {
    iconLoaded = false;
    fontLoaded = false;
    homeworkList.clear();
    homeworkLoaded = false;
    await getIconData();
    await getFontData();
    await getHomework();
  }

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

  @override
  void initState() {
    retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ListView hList;

    if (homeworkList.length == 0 && homeworkLoaded) {
      hList = new ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          new Container(
              margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: GestureDetector(
                  onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddHomework(subject: widget.subject, fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0), iconData: iconLoaded ? iconData : new AthenaIconData(Colors.grey, 35.0)))).whenComplete(retrieveData);},
                  child: new Card(
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text("Add Homework By Using the", textAlign: TextAlign.center, style: TextStyle(
                              fontFamily: fontData.font,
                              fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size,
                              color: fontData.color
                            ),
                          ),
                          new SizedBox(height: 10.0,),
                          new Icon(Icons.add_circle, size: 40.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color),
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
      hList = ListView.builder(
        itemCount: homeworkList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddHomework(currentHomework: homeworkList[position], subject: widget.subject, fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0), iconData: iconLoaded ? iconData : new AthenaIconData(Colors.grey, 35.0)))).whenComplete(retrieveData),
              child: new Column(
                children: <Widget>[
                  SizedBox(height: 10.0),
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
                                    alignment: WrapAlignment.spaceBetween,
                                    runAlignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: <Widget>[
                                      new Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.library_books, color: Color(int.tryParse(widget.subject.colour)), size: 32.0*iconData.size,),
                                          new SizedBox(width: 15.0*ThemeCheck.orientatedScaleFactor(context),),
                                          Text(
                                            homeworkList[position].description,
                                            style: TextStyle(
                                                color: fontData.color,
                                                fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size,
                                                fontFamily: fontData.font
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        width: 18*1.85*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                                        height: 18*1.85*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                                        child: Transform.scale(
                                          alignment: Alignment.center,
                                          scale: 1.25*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                                          child: new Checkbox(
                                            materialTapTargetSize: MaterialTapTargetSize.padded,
                                            activeColor: Color(int.tryParse(widget.subject.colour)),
                                            value: homeworkList[position].isCompleted,
                                            onChanged: (newVal) {
                                              setState(() {
                                                homeworkList[position].isCompleted = newVal;
                                                updateHomework(homeworkList[position]);
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                  iconSize: 32.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                                  icon: Icon(Icons.delete, color: ThemeCheck.errorColorOfColor(iconData.color)),
                                  onPressed: () => deleteHomeworkDialog(homeworkList[position])
                              ),
                            ],
                          )
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
            title: Text("Homework", style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "")),
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
                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddHomework(subject: widget.subject, fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0), iconData: iconLoaded ? iconData : new AthenaIconData(Colors.grey, 35.0)))).whenComplete(retrieveData);},
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
                  child: homeworkLoaded ? hList : new SizedBox(width: 50.0,
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

  void getHomework() async {
    List<Homework> reqHomework = await requestManager.getHomework(widget.subject.id);
    this.setState(() {
      homeworkList = reqHomework;
      homeworkLoaded = true;
    });
  }

  void updateHomework(Homework homework) async{
    //create map of subject data
    Map map = {
      "id": homework.id,
      "subjectID": widget.subject.id,
      "description": homework.description,
      "isCompleted": homework.isCompleted
    };

    var response = await requestManager.putHomework(map);

    //if null, then the request was a success, retrieve the information
    if (response !=  "success"){
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error has occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void deleteHomework(Homework homework) async {
    var response = await requestManager.deleteHomework(homework.id, widget.subject.id);

    //if null, then the request was a success, retrieve the information
    if (response == "success") {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Homework Deleted!', style: TextStyle(fontSize: 18.0*fontData.size, fontFamily: fontData.font),)));
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

  void deleteHomeworkDialog(Homework homework) {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to DELETE this Homework?", style: TextStyle(fontSize: 18.0*fontData.size, fontFamily: fontData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
          fontSize: 18.0*fontData.size, fontFamily: fontData.font, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteHomework(homework);
          submit(false);
        },
            child: new Text("YES",
              style: TextStyle(fontSize: 18.0*fontData.size, fontFamily: fontData.font, fontWeight: FontWeight.bold,),)),
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
