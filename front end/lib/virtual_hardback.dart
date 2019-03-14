import 'package:Athena/background_settings.dart';
import 'package:Athena/card_settings.dart';
import 'package:Athena/dyslexia_friendly_settings.dart';
import 'package:Athena/sign_out.dart';
import 'package:Athena/tag_manager.dart';
import 'package:Athena/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/icon_settings.dart';
import 'package:Athena/tag.dart';
import 'package:Athena/tag_filter_dialog.dart';
import 'package:Athena/theme_check.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'font_settings.dart';
import 'filetype_manager.dart';
import 'recording_manager.dart';
import 'request_manager.dart';
import 'text_file_editor.dart';
import 'note.dart';
import 'subject.dart';
import 'subject_file.dart';
import 'package:marquee/marquee.dart';
import 'athena_icon_data.dart';

class VirtualHardback extends StatefulWidget {
  VirtualHardback({Key key, this.subject}) : super(key: key);

  final Subject subject;

  @override
  VirtualHardbackState createState() => VirtualHardbackState();
}

class VirtualHardbackState extends State<VirtualHardback> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //list for image urls, will be general files in final version
  List<SubjectFile> subjectFiles = new List<SubjectFile>();
  List<Note> notesList = new List<Note>();

  List<SubjectFile> oldSubjectFiles = new List<SubjectFile>();
  List<Note> oldNotesList = new List<Note>();

  bool submitting = false;

  bool filtered = false;

  String filterTag = "";

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  //container for the image list
  Container fileList;
  bool filesLoaded = false;

  bool notesLoaded = false;

  //size of file card
  double fileCardSize = 180.0;

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

  //get user files
  void getFiles() async
  {
    List<SubjectFile> reqFiles = await requestManager.getFiles(widget.subject.id);

    if (this.mounted) {
      this.setState((){subjectFiles = reqFiles; oldSubjectFiles = reqFiles; filesLoaded = true;});
    }
  }

  //get user images
  void getNotes() async
  {
    List<Note> reqNotes = await requestManager.getNotes(widget.subject.id);

    if (this.mounted) {
      this.setState((){notesList = reqNotes; oldNotesList = reqNotes; notesLoaded = true;});
    }
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

  //method called before the page is rendered
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didUpdateWidget(VirtualHardback oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  void retrieveData() {
    iconLoaded = false;
    filesLoaded = false;
    notesLoaded = false;
    cardColourLoaded = false;
    backgroundColourLoaded = false;
    themeColourLoaded = false;
    subjectFiles.clear();
    notesList.clear();
    oldSubjectFiles.clear();
    oldNotesList.clear();
    getBackgroundColour();
    getThemeColour();
    getCardColour();
    getFiles();
    getNotes();
    getFontData();
    getIconData();
  }

  @override
  Widget build(BuildContext context) {

    Container subjectList;

    double iconFactor = iconLoaded ? iconData.size*0.875 : 0.875;
    double iconScale = iconLoaded ? (ThemeCheck.orientatedScaleFactor(context))/(iconData.size/iconFactor) : (ThemeCheck.orientatedScaleFactor(context))/(iconFactor);

    //if the user has no images stored currently, then create a list with one panel that tells the user they can add photos and images
    if (subjectFiles.length == 0 && filesLoaded) {
      subjectList = new Container(
        alignment: Alignment.center,
        height:(fileCardSize * iconScale),
        child: new ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SingleChildScrollView(
              child: new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: new SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: (fileCardSize * iconScale),
                    child: GestureDetector(
                      onTap: () => getImage(),
                      child: new Card(
                        color: cardColour,
                        child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                "Add Photos, Audio and Videos!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: fontData.font,
                                    color: fontData.color,
                                    fontSize: fontData.size <= 1 ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 14.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size
                                ),
                              ),
                              new SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context),),
                              new Icon(Icons.cloud_upload, size: 40.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color,)
                            ]
                        ),
                      ),
                    ),
                  )
              ),
            )
          ],
        ),
      );
    }
    //else, display the list of images, it is a horizontal list view of cards that are 150px in size, where the images cover the card
    else if (filesLoaded){
      subjectList =  new Container(
          height: (fileCardSize * iconScale),
          child: new ListView.builder (
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: subjectFiles.length,
              itemBuilder: (BuildContext ctxt, int index)
              {
                return new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: new SizedBox(
                    child: new Card(
                        color: cardColour,
                        child: new Stack(
                          children: <Widget>[
                            Center(
                              //widget that detects gestures made by a user
                              child: GestureDetector(
                                onTap:() async {
                                  //go to the file viewer page and pass in the image list, and the index of the image tapped
                                  final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(
                                      list: subjectFiles,
                                      i: index,
                                      subject: widget.subject,
                                      fontData: fontData,
                                      iconData: iconData,
                                      cardColour: cardColour,
                                      backgroundColour: backgroundColour,
                                      themeColour: themeColour,
                                  ))).whenComplete((){
                                    retrieveData();
                                    recorder.assignParent(this);
                                  });

                                  if (result){
                                    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('File Deleted!', style: TextStyle(fontSize: 18*fontData.size, fontFamily: fontData.font))));
                                  }
                                },
                                //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
                                //the tag allows both pages to know where to return to when the user presses the back button
                                child: new Hero(
                                  tag: "fileAt"+index.toString(),
                                  //cached network image from URLs retrieved, witha circular progress indicator placeholder until the image has loaded
                                  child: FileTypeManger.getFileTypeFromURL(subjectFiles[index].url) == "image" ? CachedNetworkImage(
                                      placeholder: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                      imageUrl: subjectFiles[index].url,
                                      height: (fileCardSize * iconScale),
                                      width: (fileCardSize * iconScale),
                                      fit: BoxFit.cover
                                  ) : FileTypeManger.getFileTypeFromURL(subjectFiles[index].url) == "video" ? new Container(
                                    decoration: new BoxDecoration(
                                        border: new Border.all(color: Colors.white12)
                                    ),
                                    width: (fileCardSize * iconScale),
                                    height: (fileCardSize * iconScale),
                                    child: new Column(
                                      children: <Widget>[
                                        new SizedBox(height: 40*iconScale,),
                                        new Icon(Icons.play_circle_filled, size: 70.0*iconScale, color: Color(int.tryParse(widget.subject.colour))),
                                        new Flexible(
                                            child: Marquee(
                                              text: subjectFiles[index].fileName,
                                              scrollAxis: Axis.horizontal,
                                              velocity: 50.0,
                                              style: TextStyle(
                                                  fontSize: 18*iconScale
                                              ),
                                              pauseAfterRound: Duration(seconds: 2),
                                              blankSpace: 20.0,
                                            )
                                        )
                                      ],
                                    ),
                                  ) : FileTypeManger.getFileTypeFromURL(subjectFiles[index].url) == "audio" ?
                                  new Container(
                                    decoration: new BoxDecoration(
                                        border: new Border.all(color: Colors.white12)
                                    ),
                                    width: (fileCardSize * iconScale),
                                    height: (fileCardSize * iconScale),
                                    child: new Column(
                                      children: <Widget>[
                                        new SizedBox(height: 40*iconScale),
                                        new Icon(Icons.volume_up, size: 70.0*iconScale, color: Color(int.tryParse(widget.subject.colour))),
                                        new Flexible(
                                            child: Marquee(
                                              text: subjectFiles[index].fileName,
                                              scrollAxis: Axis.horizontal,
                                              style: TextStyle(
                                                fontSize: 18*iconScale
                                              ),
                                              velocity: 50.0,
                                              pauseAfterRound: Duration(seconds: 2),
                                              blankSpace: 20.0,
                                            )
                                        )
                                      ],
                                    ),
                                  ) : new Container(),
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                    //Keeps the card the same size when the image is loading
                    width: (fileCardSize * iconScale),
                    height: (fileCardSize * iconScale),
                  ),
                );
              }
          )
      );
    }
    else{
      //display a circular progress indicator when the image list is loading
      subjectList =  new Container(child: new Padding(padding: EdgeInsets.all(50.0*ThemeCheck.orientatedScaleFactor(context)), child: new SizedBox(width: 50.0*ThemeCheck.orientatedScaleFactor(context), height: 50.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context), valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))));
    }

    ListView textFileList;

    if (notesList.length == 0 && notesLoaded) {
      textFileList = new ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          new Container(
                margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: new Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: GestureDetector(
                    onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(
                      subject: widget.subject,
                      fontData: fontData,
                      backgroundColour: backgroundColour,
                      themeColour: themeColour,
                      cardColour: cardColour,
                    ))).whenComplete((){
                      retrieveData();
                      recorder.assignParent(this);
                    });},
                    child: new Card(
                      color: cardColour,
                      child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              "Add Notes By Using the",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: fontData.font,
                                  color: fontData.color,
                                  fontSize: fontData.size <= 1 ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 14.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size
                              ),
                            ),
                            new SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context),),
                            new Icon(
                              Icons.note_add,
                              size: 40.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                              color: iconData.color,
                            ),
                          ]
                      ),
                    ),
                  ),
                )
            )
        ],
      );
    }
    else {
      textFileList = ListView.builder(
        itemCount: notesList.length,
        itemBuilder: (context, position) {
          return Card(
              color: cardColour,
              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              elevation: 3.0,
              child: new ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(
                    note: notesList[position],
                    subject: widget.subject,
                    fontData: fontData,
                    backgroundColour: backgroundColour,
                    themeColour: themeColour,
                    cardColour: cardColour,
                ))).whenComplete((){
                  retrieveData();
                  recorder.assignParent(this);
                }),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0*ThemeCheck.orientatedScaleFactor(context)),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))
                  ),
                  child: Icon(
                    Icons.insert_drive_file,
                    color: Color(int.tryParse(widget.subject.colour)),
                    size: 32.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                  ),
                ),
                title: Text(
                  notesList[position].fileName,
                  style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font, color: fontData.color),
                ),
                trailing: GestureDetector(
                  child: Icon(Icons.delete, size: 32.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: ThemeCheck.errorColorOfColor(iconData.color)),
                  onTap: () => deleteNoteDialog(notesList[position])
                ),
              ),
          );
        },
      );
    }

    //scaffold to encapsulate all the widgets
    final page = Scaffold(
      backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
      endDrawer: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && notesLoaded && filesLoaded ?
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
        title: new Text(widget.subject.name, style: TextStyle(
            fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: fontLoaded ? fontData.font : "",
            color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour)))
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
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && notesLoaded && filesLoaded ? IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
          ) : new Container(),
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && notesLoaded && filesLoaded ? IconButton(
            icon: Icon(Icons.note_add),
            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(
                subject: widget.subject,
                fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                backgroundColour: backgroundColour,
                themeColour: themeColour,
                cardColour: cardColour,
            ))).whenComplete((){
              retrieveData();
              recorder.assignParent(this);
            });},
          ) : new Container(),
          filterTag != "" ? IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                filterTag = "";
                notesList = oldNotesList;
                subjectFiles = oldSubjectFiles;
              });
            },
          ) : fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && notesLoaded && filesLoaded ? IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => showTagDialog(false, null),
          ) : new Container(),
          // else display the mic button and settings button
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && notesLoaded && filesLoaded ? IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {if(this.mounted){setState(() {recorder.recordAudio(context);});}},
          ) : new Container(),
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && notesLoaded && filesLoaded ? Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ) : new Container(),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) =>
        //stack to display the main widgets; the notes and images
        MediaQuery.of(context).orientation == Orientation.portrait ?
        Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Container(
                //note container, which is 60% the size of the screen
                height:  MediaQuery.of(context).size.height * 0.50,
                alignment: notesLoaded ? Alignment.topCenter : Alignment.center,
                child: notesLoaded ? textFileList : new SizedBox(width: 50.0*ThemeCheck.orientatedScaleFactor(context), height: 50.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context), valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
              ),
              new Expanded(
                  child: new Container(
                    //container for the image buttons, one for getting images from the gallery and one for getting images from the camera
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new IconButton(
                                color: Color(int.tryParse(widget.subject.colour)),
                                iconSize: iconLoaded ? 35.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 35.0*ThemeCheck.orientatedScaleFactor(context),
                                icon: Icon(Icons.add_to_photos),
                                onPressed: () => getImage(),
                              ),
                              new IconButton(
                                color: Color(int.tryParse(widget.subject.colour)),
                                iconSize: iconLoaded ? 35.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 35.0*ThemeCheck.orientatedScaleFactor(context),
                                icon: Icon(Icons.camera_alt),
                                onPressed: () => getCameraImage(),
                              )
                            ]
                        ),
                        //display the image list
                        subjectList,
                      ],
                    ),
                  ),
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
                          child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData)],) : new Container()
              ),
            ]
        ) :
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                width: MediaQuery.of(context).size.width * 0.50,
                alignment: notesLoaded ? Alignment.topCenter : Alignment.center,
                child: notesLoaded ? textFileList : new SizedBox(width: 50.0*ThemeCheck.orientatedScaleFactor(context), height: 50.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context), valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
              ),
              new Flexible(
                  child: Container(
                //container for the image buttons, one for getting images from the gallery and one for getting images from the camera
                  alignment: Alignment.center,
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new IconButton(
                              color: Color(int.tryParse(widget.subject.colour)),
                              iconSize: 35.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                              icon: Icon(Icons.add_to_photos),
                              onPressed: () => getImage(),
                            ),
                            new IconButton(
                              color: Color(int.tryParse(widget.subject.colour)),
                              iconSize: 35.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                              icon: Icon(Icons.camera_alt),
                              onPressed: () => getCameraImage(),
                            )
                          ]
                      ),
                      //display the image list
                      subjectList,
                    ],
                  ),
                ),
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
                          child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData)],) : new Container()
              ),
            ]
        ),
      )
    );

    return Stack(
      children: <Widget>[
        page,
        //container for the circular progress indicator when submitting an image, show if submitting, show blank container if not
        submitting ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                margin: MediaQuery.of(context).viewInsets,
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0*ThemeCheck.orientatedScaleFactor(context), height: 50.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context), valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
          ],
        ): new Container()
      ],
    );
  }

  //method for getting an image from the gallery
  void getImage() async
  {
    //use filepicker to retrieve image from gallery
    String image = await FilePicker.getFilePath(type: FileType.ANY);

    //if image is not null then upload the image and add the url to the image files list
    if (image != null) {
      SubjectFile responseFile = await uploadFile(image);

      if (this.mounted) {
        setState(() {
          if (image != null || responseFile.url != "error") {
            subjectFiles.add(responseFile);
          }
        });
      }
    }
  }

  //method for getting an image from the camera
  void getCameraImage() async
  {
    //use filepicker to retrieve image from camera
    String image = await FilePicker.getFilePath(type: FileType.CAMERA);

    //if image is not null then upload the image and add the url to the image files list
    if (image != null) {
      SubjectFile responseFile = await uploadFile(image);

      if (this.mounted) {
        setState(() {
          if (image != null || responseFile.url != "error") {
            subjectFiles.add(responseFile);
          }
        });
      }
    }
  }

  //alert dialog that notifies the user if an error has occurred
  void showErrorDialog()
  {
    AlertDialog errorDialog = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("An Error has occured. Please try again", style: TextStyle(
        fontFamily: fontData.font,
        fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
        color: fontData.color
      ),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text(
          "OK", style: TextStyle(
          fontFamily: fontData.font,
          fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontWeight: FontWeight.bold,
          color: themeColour
        ),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  void deleteNoteDialog(Note note) {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("Do you want to DELETE this Note?", style: TextStyle(
          fontFamily: fontData.font,
          fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
          color: fontData.color
      ),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(
            fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: fontData.font,
            color: themeColour
        ),)),
        new FlatButton(onPressed: () {
          deleteNote(note);
        }, child: new Text("YES", style: TextStyle(
          fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontWeight: FontWeight.bold,
          fontFamily: fontData.font,
          color: themeColour
        ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => areYouSure);
  }

  void deleteNote(Note note) async {
    var response = await requestManager.deleteNote(note.id, widget.subject.id);

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text(
        'Note Deleted!',
        style: TextStyle(
            fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: fontData.font,
            color: fontData.color
        ),)));
      retrieveData();
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: cardColour,
        content: new Text("An Error has occured. Please try again", style: TextStyle(
            fontFamily: fontData.font,
            fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
            color: fontData.color
        )),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(
              fontFamily: fontData.font,
              fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontWeight: FontWeight.bold,
              color: themeColour
          )))
        ],
      );

      showDialog(context: context, barrierDismissible: true, builder: (_) => responseDialog);
    }
  }

  //method for uploading user chosen image
  Future<SubjectFile> uploadFile(String filePath) async
  {
    submit(true);

    SubjectFile responseFile = await requestManager.uploadFile(filePath, widget.subject.id);

    if (responseFile.url == "error") {
      showErrorDialog();
      return responseFile;
    }
    else {
      submit(false);
      return responseFile;
    }
  }

  void showTagDialog(bool fromWithin, List<String> currentTags) async {

    List<String> tagValues;

    if(!fromWithin) {
      submit(true);

      List<Tag> tags = await requestManager.getTags();

      submit(false);

      tagValues = tags.map((tag) => tag.tag).toList();

      tagValues.add("No Tag");
    }
    else {
      tagValues = currentTags;
    }

    showDialog(context: context, barrierDismissible: true, builder: (_) =>
    new TagFilterDialog(
        fontData: fontData,
        backgroundColour: backgroundColour,
        themeColour: themeColour,
        cardColour: cardColour,
        parent: this,
        tagValues: tagValues,
        currentTag: filterTag,
      ),
    );
  }

  void showTagList(List<String> tagValues){
    AlertDialog tags = new AlertDialog(
      backgroundColor: cardColour,
      content: new Container(
        width: MediaQuery.of(context).size.width,
        child: new ListView.builder(
          shrinkWrap: true,
          itemCount: tagValues.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new RadioListTile<String>(
              value: tagValues[index],
              activeColor: themeColour,
              groupValue: filterTag == "" ? null : filterTag,
              title: Text(
                tagValues[index], style: TextStyle(
                  fontSize: 20.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                  fontFamily: fontData.font,
                  color: fontData.color
              ),
              ),
              onChanged: (String value) {
                setState(() {
                  filterTag = value;
                  Navigator.pop(context); //pop this dialog
                  Navigator.pop(context); //pop context of previous dialog
                  showTagDialog(true, tagValues);
                });
              },
            );
          }
        ),
      ),
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => tags, );
  }
  
  void filterByTag() async {
    if (filterTag == ""){
      return;
    }
    else {

      List<SubjectFile> taggedSubjectFiles = new List<SubjectFile>();
      List<Note> taggedNotes = new List<Note>();

      oldSubjectFiles.forEach((file){
        if(file.tag == filterTag){
          taggedSubjectFiles.add(file);
        }
      });

      oldNotesList.forEach((note){
        if(note.tag == filterTag){
          taggedNotes.add(note);
        }
      });

      setState(() {
        notesList = taggedNotes;
        subjectFiles = taggedSubjectFiles;
      });
    }
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
