import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'video_manager.dart';
import 'audio_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'filetype_manager.dart';
import 'subject_file.dart';
import 'tag.dart';
import 'subject.dart';

//Widget that displays an interactive file list
class FileViewer extends StatefulWidget
{
  FileViewer({Key key, this.list, this.i, this.subject}) : super(key: key);

  //list of file URLS
  final List<SubjectFile> list;

  final Subject subject;

  //current selected index (passed in from page in which it was invoked)
  final int i;

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer>
{

  RequestManager requestManager = RequestManager.singleton;

  bool submitting = false;

  bool tagChanged = false;

  String currentTag;
  String previousTag;

  int currentIndex;

  String currentID;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    currentIndex = widget.i;
    previousTag = widget.list[widget.i].tag;
    currentTag = previousTag;
    currentID = widget.list[widget.i].id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
        children: <Widget>[
          Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                backgroundColor: Colors.black,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.local_offer),
                    iconSize: 30.0,
                    color: ThemeCheck.colorCheck(Theme.of(context).backgroundColor) ? Theme.of(context).accentColor : Colors.white,
                    onPressed: () => showTagDialog(false, null),
                  ),
                ]
            ),
            backgroundColor: Colors.black,
            //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
            //the tag allows both pages to know where to return to when the user presses the back button
            body: new Center(
              child: Hero(tag: "imageView"+widget.i.toString(),
                //swiper widget allows to swipe between a list
                child: new Swiper(
                  itemBuilder: (BuildContext context, int index){

                    //photo view allows for zooming in and out of images
                    return FileTypeManger.getFileTypeFromURL(widget.list[index].url) == "image" ? new PhotoView(
                      maxScale: PhotoViewComputedScale.contained * 2.0,
                      minScale: (PhotoViewComputedScale.contained) * 0.5,
                      //get a cached network image from the current URL in the list, this will ensure the image URL does not need to be loaded every time
                      imageProvider: new CachedNetworkImageProvider(widget.list[index].url))
                      : FileTypeManger.getFileTypeFromURL(widget.list[index].url) == "video" ? new VideoManager(controller: new VideoPlayerController.network(widget.list[index].url))
                      : FileTypeManger.getFileTypeFromURL(widget.list[index].url) == "audio" ? new AudioManager(subjectFile: widget.list[index], audioPlayer: new AudioPlayer(),) : new Container();
                  },
                  itemCount: widget.list.length,
                  pagination: new SwiperPagination(),
                  control: new SwiperControl(color: Colors.white70),
                  //start the wiper on the index of the image selected
                  index: currentIndex,
                  onIndexChanged: (int index) => updateInfo(widget.list[index].id, index, widget.list[index].tag),
                ),
              ),
            )
          ),
          submitting ? new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              new Container(
                  margin: MediaQuery.of(context).padding,
                  child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
            ],
          ): new Container()
        ]
    );
  }

  void updateInfo(String newID, int newIndex, String newTag){
    if(this.mounted) {
      setState(() {
        currentID = newID;
        previousTag = newTag;

        if (!tagChanged) {
          currentTag = previousTag;
        }

        currentIndex = newIndex;
      });
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
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Text("Current Tag is: ", style: TextStyle(fontSize: 20.0)),
              new Text(previousTag, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ],
          ),
          new SizedBox(height: 20.0,),
          new DropdownButton<String>(
            //initial value
            value: currentTag,
            hint: new Text("Choose a Tag", style: TextStyle(fontSize: 20.0)),
            items: tagValues.map((String tag) {
              return new DropdownMenuItem<String>(
                value: tag,
                child: new Text(tag,  style: TextStyle(fontSize: 20.0)),
              );
            }).toList(),
            //when the font is changed in the dropdown, change the current font state
            onChanged: (String val){
              if (this.mounted) {
                setState(() {
                  tagChanged = true;
                  currentTag = val;
                  Navigator.pop(context);
                  showTagDialog(true, tagValues);
                });
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("Close", style: TextStyle(fontSize: 18.0),)),
        new FlatButton(onPressed: () async {
          submit(true);
          Navigator.pop(context);
          await addTagToFile();
          submit(false);
        }, child: new Text("Add Tag", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => tagDialog);
  }

  void addTagToFile() async {

    Map map = {"id": currentID, "tag": currentTag, "subjectID": widget.subject.id};

    var response = await requestManager.putTagOnFile(map);

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      setState(() {
        widget.list[currentIndex].tag = currentTag;
        tagChanged = false;
        previousTag = currentTag;
      });
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Tag Added!')));
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void submit(bool state)
  {
    if (this.mounted){
      setState(() {
        submitting = state;
      });
    }
  }
}
