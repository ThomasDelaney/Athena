import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/MaterialViewer.dart';
import 'package:my_school_life_prototype/class_material.dart';
import 'package:my_school_life_prototype/recording_manager.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/subject.dart';
import 'package:my_school_life_prototype/theme_check.dart';

class AddMaterial extends StatefulWidget {

  final Subject subject;
  final ClassMaterial currentMaterial;

  AddMaterial({Key key, this.subject, this.currentMaterial}) : super(key: key);

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

  double tileSize = 150;
  bool fileChanged = false;

  String font = "";

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

    if (widget.currentMaterial != null) {
      fileName = widget.currentMaterial.fileName;
      materialNameController.text = widget.currentMaterial.name;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (widget.currentMaterial != null) {
      if(!fileChanged) {
        if (widget.currentMaterial.photoUrl == ""){

          materialImage = GestureDetector(
              onTap: () => getImage(),
              child: new SizedBox(
                width: tileSize * ThemeCheck.orientatedScaleFactor(context),
                height: tileSize * ThemeCheck.orientatedScaleFactor(context),
                child: new Card(
                  elevation: 3,
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text("Add Photos of the Material!", textAlign: TextAlign.center, style: TextStyle(fontFamily: font),),
                        new Icon(Icons.cloud_upload, size: 40.0, color: Colors.grey,)
                      ]
                  ),
                ),
              )
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
                          placeholder: CircularProgressIndicator(),
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
          child: new SizedBox(
            width: tileSize * ThemeCheck.orientatedScaleFactor(context),
            height: tileSize * ThemeCheck.orientatedScaleFactor(context),
            child: new Card(
              elevation: 3,
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text("Add Photos of the Material!", textAlign: TextAlign.center, style: TextStyle(fontFamily: font),),
                    new Icon(Icons.cloud_upload, size: 40.0, color: Colors.grey,)
                  ]
              ),
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
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(
                title: new Text("Add a New Material"),
              ),
              body: new Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  new Card(
                      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      elevation: 3.0,
                      child: MediaQuery.of(context).orientation == Orientation.portrait ?
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: TextFormField(
                              focusNode: materialNameFocusNode,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              controller: materialNameController,
                              style: TextStyle(fontSize: 24.0),
                              decoration: InputDecoration(
                                  hintText: "Material Name",
                                  labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).accentColor),
                                  border: UnderlineInputBorder()
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          new Container(
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: new Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new IconButton(
                                    color: Color(int.tryParse(widget.subject.colour)),
                                    icon: Icon(Icons.photo_library, size: 35.0),
                                    onPressed: () => getImage(),
                                  ),
                                  new IconButton(
                                    color: Color(int.tryParse(widget.subject.colour)),
                                    icon: Icon(Icons.camera_alt, size: 35.0),
                                    onPressed: () => getCameraImage(),
                                  ),
                                  fileName != "" ? new IconButton(
                                    color: Color(int.tryParse(widget.subject.colour)),
                                    icon: Icon(Icons.close, size: 35.0),
                                    onPressed: () => setState((){
                                      fileChanged = true;
                                      fileName = "";
                                      materialImage = GestureDetector(
                                        onTap: () => getImage(),
                                        child: new SizedBox(
                                          width: tileSize * ThemeCheck.orientatedScaleFactor(context),
                                          height: tileSize * ThemeCheck.orientatedScaleFactor(context),
                                          child: new Card(
                                            elevation: 3,
                                            child: new Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  new Text("Add Photos of the Material!", textAlign: TextAlign.center, style: TextStyle(fontFamily: font),),
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
                                height: 50.0,
                                child: RaisedButton(
                                  elevation: 3.0,
                                  onPressed: showAreYouSureDialog,
                                  child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0))),
                                  color: Theme.of(context).errorColor,

                                  textColor: ThemeCheck.colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
                                ),
                              )
                          )
                        ],
                      ) :
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Flexible(
                                child: new Container(
                                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  child: TextFormField(
                                    focusNode: materialNameFocusNode,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    controller: materialNameController,
                                    style: TextStyle(fontSize: 24.0),
                                    decoration: InputDecoration(
                                        hintText: "Material Name",
                                        labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).accentColor),
                                        border: UnderlineInputBorder()
                                    ),
                                  ),
                                ),
                              ),
                              new Container(
                                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  child: new Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new IconButton(
                                          color: Color(int.tryParse(widget.subject.colour)),
                                          icon: Icon(Icons.photo_library, size: 35.0),
                                          onPressed: () => getImage(),
                                        ),
                                        new IconButton(
                                          color: Color(int.tryParse(widget.subject.colour)),
                                          icon: Icon(Icons.camera_alt, size: 35.0),
                                          onPressed: () => getCameraImage(),
                                        ),
                                        fileName != "" ? new IconButton(
                                          color: Color(int.tryParse(widget.subject.colour)),
                                          icon: Icon(Icons.close, size: 35.0),
                                          onPressed: () => setState((){
                                            fileChanged = true;
                                            fileName = "";
                                            materialImage = GestureDetector(
                                                onTap: () => getImage(),
                                                child: new SizedBox(
                                                  width: tileSize * ThemeCheck.orientatedScaleFactor(context),
                                                  height: tileSize * ThemeCheck.orientatedScaleFactor(context),
                                                  child: new Card(
                                                    elevation: 3,
                                                    child: new Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          new Text("Add Photos of the Material!", textAlign: TextAlign.center, style: TextStyle(fontFamily: font),),
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
                              )
                            ],
                          ),
                          new Container(
                              margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              child: ButtonTheme(
                                height: 50.0,
                                child: RaisedButton(
                                  elevation: 3.0,
                                  onPressed: showAreYouSureDialog,
                                  child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0))),
                                  color: Theme.of(context).errorColor,

                                  textColor: ThemeCheck.colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
                                ),
                              )
                          )
                        ],
                      )
                  )
                ],
              ),
            ),
            submitting ? new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                    margin: MediaQuery.of(context).padding,
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
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
        content: new Text("Do you want to SAVE this Material?", /*style: TextStyle(fontFamily: font),*/),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
          }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
      content: new Text("Do you want to SAVE this Material?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
        content: new Text("An error has occured please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void showYouMustHaveMaterialNameDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("The Material must have a Name!", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
