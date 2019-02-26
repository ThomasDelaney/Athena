import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/home_page.dart';
import 'package:my_school_life_prototype/icon_settings.dart';
import 'package:my_school_life_prototype/tag.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'dart:async';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'font_settings.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
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
  _VirtualHardbackState createState() => _VirtualHardbackState();
}

class _VirtualHardbackState extends State<VirtualHardback> {

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
  double fileCardSize = 185.0;

  FontData fontData;
  bool fontLoaded = false;

  AthenaIconData iconData;
  bool iconLoaded = false;

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
    subjectFiles.clear();
    notesList.clear();
    oldSubjectFiles.clear();
    oldNotesList.clear();
    getFiles();
    getNotes();
    getFontData();
    getIconData();
  }

  @override
  Widget build(BuildContext context) {

    Container subjectList;

    //if the user has no images stored currently, then create a list with one panel that tells the user they can add photos and images
    if (subjectFiles.length == 0 && filesLoaded) {
      subjectList = new Container(
        alignment: Alignment.center,
        height: fileCardSize * ThemeCheck.orientatedScaleFactor(context),
        child: new ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SingleChildScrollView(
              child: new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: new SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: fileCardSize * ThemeCheck.orientatedScaleFactor(context),
                    child: GestureDetector(
                      onTap: () => getImage(),
                      child: new Card(
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
          height: fileCardSize * ThemeCheck.orientatedScaleFactor(context),
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
                                onTap:() async {
                                  //go to the file viewer page and pass in the image list, and the index of the image tapped
                                  final bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(list: subjectFiles, i: index, subject: widget.subject,))).whenComplete(retrieveData);

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
                                      placeholder: CircularProgressIndicator(),
                                      imageUrl: subjectFiles[index].url,
                                      height: fileCardSize * ThemeCheck.orientatedScaleFactor(context),
                                      width: fileCardSize * ThemeCheck.orientatedScaleFactor(context),
                                      fit: BoxFit.cover
                                  ) : FileTypeManger.getFileTypeFromURL(subjectFiles[index].url) == "video" ? new Stack(children: <Widget>[
                                    new Chewie(
                                      controller: new ChewieController(
                                        videoPlayerController: new VideoPlayerController.network(
                                            subjectFiles[index].url
                                        ),
                                        aspectRatio: 1.15,
                                        autoPlay: false,
                                        autoInitialize: true,
                                        showControls: false,
                                        looping: false,
                                        placeholder: new Center(child: new CircularProgressIndicator(backgroundColor: Theme.of(context).accentColor,)),
                                      ),
                                    ),
                                    new Center(child: new Icon(Icons.play_circle_filled, size: 70.0*ThemeCheck.orientatedScaleFactor(context), color: Color.fromRGBO(255, 255, 255, 0.85),)),
                                  ],) : FileTypeManger.getFileTypeFromURL(subjectFiles[index].url) == "audio" ?
                                  new Container(
                                    child: new Column(
                                      children: <Widget>[
                                        new SizedBox(height: 40*ThemeCheck.orientatedScaleFactor(context),),
                                        new Icon(Icons.volume_up, size: 70.0*ThemeCheck.orientatedScaleFactor(context), color: Color(int.tryParse(widget.subject.colour))),
                                        new Flexible(
                                            child: Marquee(
                                              text: subjectFiles[index].fileName,
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
                    width: fileCardSize * ThemeCheck.orientatedScaleFactor(context),
                    height: fileCardSize * ThemeCheck.orientatedScaleFactor(context),
                  ),
                );
              }
          )
      );
    }
    else{
      //display a circular progress indicator when the image list is loading
      subjectList =  new Container(child: new Padding(padding: EdgeInsets.all(50.0*ThemeCheck.orientatedScaleFactor(context)), child: new SizedBox(width: 50.0*ThemeCheck.orientatedScaleFactor(context), height: 50.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context)))));
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
                    onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(subject: widget.subject, fontData: fontData,))).whenComplete(retrieveData);},
                    child: new Card(
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
              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              elevation: 3.0,
              child: new ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(note: notesList[position], subject: widget.subject, fontData: fontData))).whenComplete(retrieveData),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
          iconTheme: IconThemeData(
              color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour))) ? Colors.white : Colors.black
          ),
          backgroundColor: Color(int.tryParse(widget.subject.colour)),
          title: new Text(widget.subject.name, style: TextStyle(
              fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: fontLoaded ? fontData.font : "",
              color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour))) ? Colors.white : Colors.black
            )
          ),
          //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
          actions: recorder.recording ? <Widget>[
            // action button
            IconButton(
                icon: Icon(Icons.home),
                iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
            ),
            IconButton(
              icon: Icon(Icons.close),
              iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
              onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
            ),
          ] : <Widget>[
            IconButton(
              icon: Icon(Icons.note_add),
              iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
              onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(subject: widget.subject, fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0)))).whenComplete(retrieveData);},
            ),
            filterTag != "" ? IconButton(
              icon: Icon(Icons.close),
              iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
              onPressed: () {
                setState(() {
                  filterTag = "";
                  notesList = oldNotesList;
                  subjectFiles = oldSubjectFiles;
                });
              },
            ) : IconButton(
              icon: Icon(Icons.filter_list),
              iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
              onPressed: () => showTagDialog(false, null),
            ),
            // else display the mic button and settings button
            IconButton(
              icon: Icon(Icons.mic),
              iconSize: 30.0*ThemeCheck.orientatedScaleFactor(context),
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
          MediaQuery.of(context).orientation == Orientation.portrait ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new Container(
                  //note container, which is 60% the size of the screen
                  height: MediaQuery.of(context).size.height * ((0.45 + (iconData.size/10) / iconData.size)) * ThemeCheck.orientatedScaleFactor(context),
                  alignment: notesLoaded ? Alignment.topCenter : Alignment.center,
                  child: notesLoaded ? textFileList : new SizedBox(width: 50.0*ThemeCheck.orientatedScaleFactor(context), height: 50.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context),)),
                ),
                new SizedBox(height: 15/iconData.size,),
                new Container(
                  //container for the image buttons, one for getting images from the gallery and one for getting images from the camera
                  alignment: Alignment.bottomCenter,
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
          ) :
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  alignment: notesLoaded ? Alignment.topCenter : Alignment.center,
                  child: notesLoaded ? textFileList : new SizedBox(width: 50.0*ThemeCheck.orientatedScaleFactor(context), height: 50.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context),)),
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
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context)],) : new Container()
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
                margin: MediaQuery.of(context).padding,
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0*ThemeCheck.orientatedScaleFactor(context), height: 50.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context),))
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
      content: new Text("An Error has occured. Please try again", style: TextStyle(fontFamily: fontData.font, fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: fontData.font, fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  void deleteNoteDialog(Note note) {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to DELETE this Note?", style: TextStyle(fontFamily: fontData.font, fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context)),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontWeight: FontWeight.bold, fontFamily: fontData.font),)),
        new FlatButton(onPressed: () {
          deleteNote(note);
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => areYouSure);
  }

  void deleteNote(Note note) async {
    var response = await requestManager.deleteNote(note.id, widget.subject.id);

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Note Deleted!', style: TextStyle(fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font),)));
      retrieveData();
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text(response['error']['response']),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: true, builder: (_) => responseDialog);
    }
  }

  //method to display sign out dialog that notifies user that they will be signed out, when OK is pressed, handle the sign out
  void signOut()
  {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text("You are about to be Signed Out", style: TextStyle(fontFamily: fontData.font, fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context))),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK", style: TextStyle(fontFamily: fontData.font, fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context))))
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

  //method for uploading user chosen image
  Future<SubjectFile> uploadFile(String filePath) async
  {
    submit(true);

    SubjectFile responseFile = await requestManager.uploadFile(filePath, widget.subject.id, context);

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

    AlertDialog tagDialog = new AlertDialog(
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Text("Select a Tag to filter Files and Notes", style: TextStyle(fontSize: 20.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font)),
          new SizedBox(height: 20.0,),
          new Flexible(
            child: Container(
                child: ButtonTheme(
                  child: RaisedButton(
                    elevation: 3.0,
                    onPressed: () => showTagList(tagValues),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          filterTag == "" ? 'Choose a Tag' : filterTag,
                          style: TextStyle(
                            fontSize: 20.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size,
                            fontFamily: fontData.font,
                          )
                        )
                    ),
                    color: Theme.of(context).errorColor,

                    textColor: ThemeCheck.colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
                  ),
                )
            )
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context); setState(() {
          filterTag = "";
        });}, child: new Text("Close", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font),)),
        new FlatButton(onPressed: () async {
          submit(true);
          Navigator.pop(context);
          await filterByTag();
          submit(false);
        }, child: new Container(
            width: MediaQuery.of(context).orientation == Orientation.portrait ? 65*ThemeCheck.orientatedScaleFactor(context)*fontData.size : null,
            child: new Text(
              "Filter By Tag",
              style: TextStyle(
                  fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                  fontWeight: FontWeight.bold,
                  fontFamily: fontData.font
              ),
            ),
           )
        ),
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => tagDialog, );
  }

  void showTagList(List<String> tagValues){
    AlertDialog tags = new AlertDialog(
      content: new Container(
        width: MediaQuery.of(context).size.width,
        child: new ListView.builder(
          shrinkWrap: true,
          itemCount: tagValues.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new RadioListTile<String>(
              value: tagValues[index],
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

    showDialog(context: context, barrierDismissible: false, builder: (_) => tags, );
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
