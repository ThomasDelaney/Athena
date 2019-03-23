import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/material_viewer.dart';
import 'package:Athena/class_material.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/request_manager.dart';
import 'package:Athena/subject.dart';
import 'package:Athena/theme_check.dart';

class AddMaterial extends StatefulWidget {

  final Subject subject;
  final ClassMaterial currentMaterial;
  final FontData fontData;
  final AthenaIconData iconData;

  final Color cardColour;
  final Color backgroundColour;
  final Color themeColour;

  AddMaterial({Key key, this.subject, this.currentMaterial, this.fontData, this.iconData, this.cardColour, this.themeColour, this.backgroundColour}) : super(key: key);

  @override
  _AddMaterialState createState() => _AddMaterialState();
}

class _AddMaterialState extends State<AddMaterial> {

  bool submitting = false;

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final materialNameController = new TextEditingController();
  FocusNode materialNameFocusNode;

  Widget materialImage;
  String fileName = "";

  double tileSize = 175;
  bool fileChanged = false;

  bool isFileEdited() {
    if (widget.currentMaterial == null) {
      if (materialNameController.text == "" && fileName == "") {
        return false;
      }
      else {
        return true;
      }
    }
    else {
      if (materialNameController.text != widget.currentMaterial.name || fileName != widget.currentMaterial.fileName) {
        return true;
      }
      else {
        return false;
      }
    }
  }

  @override
  void initState() {
    recorder.assignParent(this);

    if (widget.currentMaterial != null) {
      fileName = widget.currentMaterial.fileName;
      materialNameController.text = widget.currentMaterial.name;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(AddMaterial oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    if (widget.currentMaterial != null) {
      if(!fileChanged) {
        if (widget.currentMaterial.photoUrl == ""){

          materialImage = GestureDetector(
              onTap: () => getImage(),
              child: new Card(
                color: widget.cardColour,
                elevation: 3,
                child: new Container(
                  padding: EdgeInsets.all(25 * ThemeCheck.orientatedScaleFactor(context)),
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text("Add Photos of the Material!", textAlign: TextAlign.center, style: TextStyle(
                            fontFamily: widget.fontData.font,
                            color: widget.fontData.color,
                            fontSize: widget.fontData.size <= 1 ? 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size : 14.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size),
                        ),
                        new SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context),),
                        new Icon(Icons.cloud_upload, size: 40.0*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size, color: widget.iconData.color,)
                      ]
                  ),
                ),
              ),
          );
        }
        else{
          materialImage = new Container(
            child: SizedBox(
                width: tileSize * ThemeCheck.orientatedScaleFactor(context),
                height: tileSize * ThemeCheck.orientatedScaleFactor(context),
                child: Center(
                    child: new GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaterialViewer(network: true, source: widget.currentMaterial.photoUrl,))),
                      child: new Hero(
                        tag: "material"+widget.currentMaterial.photoUrl,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: tileSize * ThemeCheck.orientatedScaleFactor(context),
                          height: tileSize * ThemeCheck.orientatedScaleFactor(context),
                          placeholder: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
                          imageUrl: widget.currentMaterial.photoUrl,
                        ),
                      ),
                    )
                )
            ),
          );
        }
      }

    }
    else{
      materialImage = GestureDetector(
          onTap: () => getImage(),
          child: new Card(
            color: widget.cardColour,
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(25 * ThemeCheck.orientatedScaleFactor(context)),
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text("Add Photos of the Material!", textAlign: TextAlign.center, style: TextStyle(
                        fontFamily: widget.fontData.font,
                        color: widget.fontData.color,
                        fontSize: widget.fontData.size <= 1 ? 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size : 14.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size),
                    ),
                    new SizedBox(height: 10.0*ThemeCheck.orientatedScaleFactor(context),),
                    new Icon(Icons.cloud_upload, size: 40.0*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size, color: widget.iconData.color)
                  ]
              ) ,
            ),
          )
      );
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: exitCheck,
        child: Stack(
          children: <Widget>[
            Scaffold(
              backgroundColor: widget.backgroundColour,
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(
                iconTheme: IconThemeData(
                  color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour)))
                ),
                actions: recorder.recording ? <Widget>[
                  // action button
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {setState(() {recorder.cancelRecording();});},
                  ),
                ] : <Widget>[
                  // else display the mic button and settings button
                  IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
                  ),
                  IconButton(
                    icon: Icon(Icons.mic),
                    onPressed: () {setState(() {recorder.recordAudio(context);});},
                  ),
                ],
                backgroundColor: Color(int.tryParse(widget.subject.colour)),
                title: new Text("Add a New Material", style: TextStyle(
                    fontFamily: widget.fontData.font,
                    color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour)))
                  )
                ),
              ),
              body: new Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: new Column(
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        new Card(
                            color: widget.cardColour,
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            elevation: 3.0,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  child: TextFormField(
                                    focusNode: materialNameFocusNode,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    controller: materialNameController,
                                    style: TextStyle(fontSize: 24.0*widget.fontData.size, fontFamily: widget.fontData.font, color: widget.fontData.color),
                                    decoration: InputDecoration(
                                      hintText: "Material Name",
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: widget.themeColour),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                new Container(
                                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                    child: new Wrap(
                                        children: <Widget>[
                                          new IconButton(
                                            color: Color(int.tryParse(widget.subject.colour)),
                                            iconSize: 35.0*widget.iconData.size,
                                            icon: Icon(Icons.photo_library),
                                            onPressed: () => getImage(),
                                          ),
                                          new IconButton(
                                            color: Color(int.tryParse(widget.subject.colour)),
                                            iconSize: 35.0*widget.iconData.size,
                                            icon: Icon(Icons.camera_alt),
                                            onPressed: () => getCameraImage(),
                                          ),
                                          fileName != "" ? new IconButton(
                                            color: Color(int.tryParse(widget.subject.colour)),
                                            iconSize: 35.0*widget.iconData.size,
                                            icon: Icon(Icons.close),
                                            onPressed: () => setState((){
                                              fileChanged = true;
                                              fileName = "";
                                              materialImage = GestureDetector(
                                                  onTap: () => getImage(),
                                                  child: new Card(
                                                    color: widget.cardColour,
                                                    elevation: 3,
                                                    child: Container(
                                                      padding: EdgeInsets.all(25 * ThemeCheck.orientatedScaleFactor(context)),
                                                      child: new Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            new Text("Add Photos of the Material!", textAlign: TextAlign.center, style: TextStyle(
                                                                fontFamily: widget.fontData.font,
                                                                color: widget.fontData.color,
                                                                fontSize: widget.fontData.size <= 1 ? 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size : 14.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size),
                                                            ),
                                                            new Icon(Icons.cloud_upload, size: 40.0, color: Colors.grey,)
                                                          ]
                                                      ),
                                                    ),
                                                  )
                                              );
                                            }),
                                          ) : new Container()
                                        ]
                                    )
                                ),
                                new Container(
                                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                    child: materialImage
                                ),
                                new Container(
                                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                    child: ButtonTheme(
                                      height: 50.0*ThemeCheck.orientatedScaleFactor(context),
                                      child: RaisedButton(
                                        elevation: 3.0,
                                        onPressed: showAreYouSureDialog,
                                        child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font,))),
                                        color: ThemeCheck.errorColorOfColor(Color(int.tryParse(widget.subject.colour))),

                                        textColor: ThemeCheck.colorCheck(ThemeCheck.errorColorOfColor(Color(int.tryParse(widget.subject.colour)))),
                                      ),
                                    )
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                  new Container(
                      child: recorder.recording ?
                      new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                              child: new ModalBarrier(
                                color: Colors.black54, dismissible: false,)),
                          recorder.drawRecordingCard(context, widget.fontData, widget.cardColour, widget.themeColour, widget.iconData)
                        ],) : new Container()
                  ),
                ],
              )
            ),
            submitting ? new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                    margin: MediaQuery.of(context).padding,
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              ],
            ): new Container()
          ],
        )
    );
  }

  //method for getting an image from the gallery
  void getImage() async
  {
    //use filepicker to retrieve image from gallery
    String image = await FilePicker.getFilePath(type: FileType.IMAGE);

    //if image is not null then upload the image and add the url to the image files list
    if (image != null) {
      setState(() {
        fileChanged = true;
        fileName = image;
        materialImage = materialImage = new Container(
            width: tileSize * ThemeCheck.orientatedScaleFactor(context),
            height: tileSize * ThemeCheck.orientatedScaleFactor(context),
            child: new GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaterialViewer(network: false, source: image,))),
              child: new Hero(
                  tag: "material"+image,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: new Image.file(new File(image)),
                  )
              ),
            )
        );
      });
    }
  }

  //method for getting an image from the camera
  void getCameraImage() async
  {
    //use filepicker to retrieve image from camera
    String image = await FilePicker.getFilePath(type: FileType.CAMERA);

    //if image is not null then upload the image and add the url to the image files list
    if (image != null) {
      setState(() {
        fileName = image;
        fileChanged = true;
        materialImage = new Container(
          width: tileSize,
          height: tileSize,
          child: new GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaterialViewer(network: false, source: image,))),
            child: new Hero(
              tag: "material"+image,
              child: FittedBox(
                fit: BoxFit.cover,
                child: new Image.file(new File(image)),
              )
            ),
          )
        );
      });
    }
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text(
          "Do you want to SAVE this Material?",
          style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              color: widget.fontData.color
          ),),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text(
            "NO",
            style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
              color: widget.themeColour
            ),)),
          new FlatButton(onPressed: () async {
            if (materialNameController.text == "") {
              Navigator.pop(context, false);
              showYouMustHaveMaterialNameDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await putMaterial();
              submit(false);
              Navigator.pop(context, true);
            }
          }, child: new Text(
            "YES",
            style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
              color: widget.themeColour
            ),)),
        ],
      );

      return showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
    }
    else {
      return true;
    }
  }

  void showAreYouSureDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text("Do you want to SAVE this Material?", style: TextStyle(
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
          color: widget.fontData.color
        ),
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text(
          "NO",
          style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            fontWeight: FontWeight.bold,
            color: widget.themeColour
        ),)),
        new FlatButton(onPressed: () async {
          if (materialNameController.text == "") {
            Navigator.pop(context, false);
            showYouMustHaveMaterialNameDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            await putMaterial();
            submit(false);
            Navigator.pop(context);
          }
        }, child: new Text(
          "YES",
          style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            fontWeight: FontWeight.bold,
            color: widget.themeColour
          ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void putMaterial() async {

    //create map of subject data
    Map map = {
      "id": widget.currentMaterial == null ? null : widget.currentMaterial.id,
      "subjectID": widget.subject.id,
      "name": materialNameController.text,
      "fileName": fileName,
      "previousFile": widget.currentMaterial == null ? null : widget.currentMaterial.fileName == "" ? null : widget.currentMaterial.fileName,
    };

    var response = await requestManager.putMaterial(map);

    //if null, then the request was a success, retrieve the information
    if (response !=  "success"){
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text("An error has occured please try again", style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
        ),),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK", style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
              color: widget.themeColour
            )
          ))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void showYouMustHaveMaterialNameDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text(
        "The Material must have a Name!",
        style: TextStyle(
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
          color: widget.fontData.color
        ),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text(
          "OK",
          style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            fontWeight: FontWeight.bold,
            color: widget.themeColour
          ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }


  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
