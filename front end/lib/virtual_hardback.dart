import 'package:flutter/material.dart';
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

  bool submitting = false;

  String check = "";

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  //container for the image list
  Container fileList;
  bool filesLoaded = false;

  bool notesLoaded = false;

  //size of file card
  double fileCardSize = 150.0;
  String font = "";

  //get user images
  void getImages() async
  {
    List<SubjectFile> reqFiles = await requestManager.getFiles(widget.subject.id);

    if (this.mounted) {
      this.setState((){subjectFiles = reqFiles; filesLoaded = true;});
    }
  }

  //get user images
  void getNotes() async
  {
    List<Note> reqNotes = await requestManager.getNotes(widget.subject.id);

    if (this.mounted) {
      this.setState((){notesList = reqNotes; notesLoaded = true;});
    }
  }

  //get current font from shared preferences if present
  void getFont() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState((){font = prefs.getString("font");});
    }
  }

  //method called before the page is rendered
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  void retrieveData() {
    filesLoaded = false;
    notesLoaded = false;
    subjectFiles.clear();
    notesList.clear();
    getImages();
    getNotes();
    getFont();
  }

  @override
  Widget build(BuildContext context) {
    Container subjectList;

    //if the user has no images stored currently, then create a list with one panel that tells the user they can add photos and images
    if (subjectFiles.length == 0 && filesLoaded) {
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
                          new Text("Add Photos and Videos!", textAlign: TextAlign.center, style: TextStyle(fontFamily: font),),
                          new Icon(Icons.cloud_upload, size: 40.0, color: Colors.grey,)
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
    else if (filesLoaded){
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(list: subjectFiles, i: index, subject: widget.subject,))).whenComplete(retrieveData);
                                },
                                //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
                                //the tag allows both pages to know where to return to when the user presses the back button
                                child: new Hero(
                                  tag: "imageView"+index.toString(),
                                  //cached network image from URLs retrieved, witha circular progress indicator placeholder until the image has loaded
                                  child: FileTypeManger.getFileTypeFromURL(subjectFiles[index].url) == "image" ? CachedNetworkImage(
                                      placeholder: CircularProgressIndicator(),
                                      imageUrl: subjectFiles[index].url,
                                      height: fileCardSize,
                                      width: fileCardSize,
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
                                        placeholder: new Center(child: new CircularProgressIndicator()),
                                      ),
                                    ),
                                    new Center(child: new Icon(Icons.play_circle_filled, size: 70.0, color: Colors.white,)),
                                  ],) : FileTypeManger.getFileTypeFromURL(subjectFiles[index].url) == "audio" ?
                                  new Container(
                                    child: new Column(
                                      children: <Widget>[
                                        new SizedBox(height: 27.5,),
                                        new Icon(Icons.volume_up, size: 70.0, color: Colors.red),
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

    if (notesList.length == 0 && notesLoaded) {
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
                        new Text("Add Notes By Using the", textAlign: TextAlign.center, style: TextStyle(fontFamily: font, fontSize: 24.0), ),
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
      textFileList = ListView.builder(
        itemCount: notesList.length,
        itemBuilder: (context, position) {
          return Card(
              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              elevation: 3.0,
              child: new ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(note: notesList[position], subject: widget.subject,))).whenComplete(retrieveData),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))
                  ),
                  child: Icon(Icons.insert_drive_file, color: Colors.redAccent, size: 32.0,),
                ),
                title: Text(
                  notesList[position].fileName,
                  style: TextStyle(fontSize: 20.0, fontFamily: font),
                ),
                trailing: GestureDetector(
                  child: Icon(Icons.delete, size: 32.0, color: Color.fromRGBO(70, 68, 71, 1)),
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
          title: new Text(widget.subject.name, style: TextStyle(fontFamily: font),),
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
              onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => TextFileEditor(subject: widget.subject,))).whenComplete(retrieveData);},
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
        body: LayoutBuilder(
          builder: (context, constraints) =>
          //stack to display the main widgets; the notes and images
          Stack(
              children: <Widget>[
                new Container(
                  //note container, which is 63% the size of the screen
                  height: MediaQuery.of(context).size.height * 0.63,
                  alignment: notesLoaded ? Alignment.topCenter : Alignment.center,
                  child: notesLoaded ? textFileList : new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,)),
                ),
                new Container(
                  //container for the image buttons, one for getting images from the gallery and one for getting images from the camera
                  alignment: Alignment.bottomCenter,
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new IconButton(
                              color: Colors.red,
                              icon: Icon(Icons.perm_media, size: 35.0),
                              onPressed: () => getImage(),
                            ),
                            new IconButton(
                              color: Colors.red,
                              icon: Icon(Icons.camera_alt, size: 35.0),
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
                            margin: MediaQuery.of(context).padding,
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context)],) : new Container()
                ),
                //container for the circular progress indicator when submitting an image, show if submitting, show blank container if not
                new Container(
                    alignment: Alignment.center,
                    child: submitting ? new Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        new Container(
                            margin: MediaQuery.of(context).padding,
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
                      ],
                    )
                        : new Container()
                ),
              ]
          ),
        )
    );

    return page;
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
      content: new Text("An Error has occured. Please try again", style: TextStyle(fontFamily: font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  void deleteNoteDialog(Note note) {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to DELETE this note?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () {
          deleteNote(note);
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => areYouSure);
  }

  void deleteNote(Note note) async {
    var response = await requestManager.deleteNote(note.id, widget.subject.id);

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

  void submit(bool state)
  {
    if (this.mounted) {
      setState(() {
        submitting = state;
      });
    }
  }
}
