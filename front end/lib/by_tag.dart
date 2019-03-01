import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:Athena/file_viewer.dart';
import 'package:Athena/filetype_manager.dart';
import 'package:Athena/note.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/request_manager.dart';
import 'package:Athena/subject.dart';
import 'package:Athena/subject_file.dart';
import 'package:Athena/text_file_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'font_settings.dart';

class ByTagViewer extends StatefulWidget {
  ByTagViewer({Key key, this.tag}) : super(key: key);

  final String tag;

  @override
  _ByTagViewerState createState() => _ByTagViewerState();
}

class _ByTagViewerState extends State<ByTagViewer> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  String font = "";

  Map<Subject, Note> notesList = new Map<Subject, Note>();

  //list for image urls, will be general files in final version
  Map<Subject, SubjectFile> subjectFiles = new Map<Subject, SubjectFile>();
  
  List<Subject> noteKeys = new List<Subject>();
  List<Subject> fileKeys = new List<Subject>();

  bool loaded = false;

  //size of file card
  double fileCardSize = 150.0;

  //get current font from shared preferences if present
  void getFont() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState((){font = prefs.getString("font");});
    }
  }

  void getNotesAndFiles() async {
    List data = await requestManager.getNotesAndFilesByTag(widget.tag);

    setState(() {
      notesList = data[0];
      subjectFiles = data[1];
      noteKeys = notesList.keys.toList();
      fileKeys = subjectFiles.keys.toList();
      loaded = true;
    });
  }

  void retrieveData() async {
    subjectFiles.clear();
    notesList.clear();
    noteKeys.clear();
    fileKeys.clear();
    loaded = false;
    getFont();
    getNotesAndFiles();
  }

  //method called before the page is rendered
  void initState() {
    retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Container subjectList;

    //if the user has no images stored currently, then create a list with one panel that tells the user they can add photos and images
    if (subjectFiles.length == 0 && loaded) {
      subjectList = new Container(
        height: fileCardSize,
        child: new ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            new Container(
                margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: new SizedBox(
                  width: fileCardSize,
                  height: fileCardSize,
                  child: new Card(
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text("You have no Files tagged with this Tag", textAlign: TextAlign.center, style: TextStyle(fontFamily: font),),
                          new SizedBox(height: 15.0,),
                          new Icon(Icons.local_offer, size: 40.0, color: Colors.grey,)
                        ]
                    ),
                  ),
                )
            ),
          ],
        ),
      );
    }
    //else, display the list of images, it is a horizontal list view of cards that are 150px in size, where the images cover the card
    else if (loaded){
      subjectList =  new Container(
          height: fileCardSize,
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
                        child: new Stack(
                          children: <Widget>[
                            Center(
                              //widget that detects gestures made by a user
                              child: GestureDetector(
                                onTap:() {
                                  //go to the file viewer page and pass in the image list, and the index of the image tapped
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(fromTagMap: subjectFiles, i: index))).whenComplete(retrieveData);
                                },
                                //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
                                //the tag allows both pages to know where to return to when the user presses the back button
                                child: new Hero(
                                  tag: "imageView"+index.toString(),
                                  //cached network image from URLs retrieved, witha circular progress indicator placeholder until the image has loaded
                                  child: FileTypeManger.getFileTypeFromURL(subjectFiles.values.elementAt(index).url) == "image" ? CachedNetworkImage(
                                      placeholder: CircularProgressIndicator(),
                                      imageUrl: subjectFiles.values.elementAt(index).url,
                                      height: fileCardSize,
                                      width: fileCardSize,
                                      fit: BoxFit.cover
                                  ) : FileTypeManger.getFileTypeFromURL(subjectFiles.values.elementAt(index).url) == "video" ? new Stack(children: <Widget>[
                                    new Chewie(
                                      controller: new ChewieController(
                                        videoPlayerController: new VideoPlayerController.network(
                                            subjectFiles.values.elementAt(index).url
                                        ),
                                        aspectRatio: 1.15,
                                        autoPlay: false,
                                        autoInitialize: true,
                                        showControls: false,
                                        looping: false,
                                        placeholder: new Center(child: new CircularProgressIndicator(backgroundColor: Theme.of(context).accentColor,)),
                                      ),
                                    ),
                                    new Center(child: new Icon(Icons.play_circle_filled, size: 70.0, color: Color.fromRGBO(255, 255, 255, 0.85),)),
                                  ],) : FileTypeManger.getFileTypeFromURL(subjectFiles.values.elementAt(index).url) == "audio" ?
                                  new Container(
                                    child: new Column(
                                      children: <Widget>[
                                        new SizedBox(height: 27.5,),
                                        new Icon(Icons.volume_up, size: 70.0, color: Colors.red),
                                        new Flexible(
                                            child: Marquee(
                                              text: subjectFiles.values.elementAt(index).fileName,
                                              scrollAxis: Axis.horizontal,
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
                    width: fileCardSize,
                    height: fileCardSize,
                  ),
                );
              }
          )
      );
    }
    else{
      //display a circular progress indicator when the image list is loading
      subjectList =  new Container(child: new Padding(padding: EdgeInsets.all(50.0), child: new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0))));
    }

    ListView textFileList;

    if (notesList.length == 0 && loaded) {
      textFileList = new ListView(
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
                        new Text("You have no Notes tagged with this Tag", textAlign: TextAlign.center, style: TextStyle(fontFamily: font, fontSize: 24.0), ),
                        new SizedBox(height: 10.0,),
                        new Icon(Icons.local_offer, size: 40.0, color: Colors.grey,),
                      ]
                  ),
                ),
              )
          ),
        ],
      );
    }
    else {
      textFileList = ListView.builder(
        itemCount: notesList.length,
        itemBuilder: (context, position) {
          return Card(
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            elevation: 3.0,
            child: new ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(note: notesList.values.elementAt(position), subject: notesList.keys.elementAt(position)))).whenComplete(retrieveData),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))
                ),
                child: Icon(Icons.insert_drive_file, color: Colors.redAccent, size: 32.0,),
              ),
              title: Text(
                notesList.values.elementAt(position).fileName,
                style: TextStyle(fontSize: 20.0, fontFamily: font),
              ),
              trailing: GestureDetector(
                  child: Icon(Icons.delete, size: 32.0, color: Color.fromRGBO(70, 68, 71, 1)),
                  onTap: () => deleteNoteDialog(notesList.values.elementAt(position), notesList.keys.elementAt(position))
              ),
            ),
          );
        },
      );

    }

    return Scaffold(
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
                  //signOut();
                },
              ),
            ],
          ),
        ),
        appBar: new AppBar(
          title: new Text("Tag - "+widget.tag, style: TextStyle(fontFamily: font),),
          //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
          actions: recorder.recording ? <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.close),
              iconSize: 30.0,
              onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
            ),
          ] : <Widget>[
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
        body: LayoutBuilder(
          builder: (context, constraints) =>
          //stack to display the main widgets; the notes and images
          Stack(
              children: <Widget>[
                new Container(
                  //note container, which is 63% the size of the screen
                  height: MediaQuery.of(context).size.height * 0.63,
                  alignment: loaded ? Alignment.topCenter : Alignment.center,
                  child: loaded ? textFileList : new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,)),
                ),
                new Container(
                  //container for the image buttons, one for getting images from the gallery and one for getting images from the camera
                  alignment: Alignment.bottomCenter,
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      //display the image list
                      subjectList,
                    ],
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
                            margin: MediaQuery.of(context).padding,
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context)],) : new Container()
                ),
                //container for the circular progress indicator when submitting an image, show if submitting, show blank container if not
              ]
          ),
        )
    );
  }

  //alert dialog that notifies the user if an error has occurred
  void showErrorDialog()
  {
    AlertDialog errorDialog = new AlertDialog(
      content: new Text("An Error has occured. Please try again", style: TextStyle(fontFamily: font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  void deleteNoteDialog(Note note, Subject subject) {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to DELETE this note?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () {
          deleteNote(note, subject);
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => areYouSure);
  }

  void deleteNote(Note note, Subject subject) async {
    var response = await requestManager.deleteNote(note.id, subject.id);

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Note Deleted!')));
      retrieveData();
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text(response['error']['response']),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); /*submit(false);*/}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: true, builder: (_) => responseDialog);
    }
  }
}
