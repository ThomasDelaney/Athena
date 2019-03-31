import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/request_manager.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'subject.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class AddSubject extends StatefulWidget {

  AddSubject({Key key, this.subject, this.fontData, this.themeColour, this.backgroundColour, this.cardColour, this.iconData}) : super(key: key);

  final FontData fontData;
  final Subject subject;
  final AthenaIconData iconData;

  final Color backgroundColour;
  final Color cardColour;
  final Color themeColour;

  @override
  _AddSubjectState createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {

  RequestManager requestManager = RequestManager.singleton;

  final subjectController = new TextEditingController();
  FocusNode subjectFocusNode;
  Color currentColor;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  bool submitting = false;

  @override
  void initState() {
    recorder.assignParent(this);

    subjectFocusNode = new FocusNode();

    if (widget.subject != null) {
      currentColor = Color(int.tryParse(widget.subject.colour));
      subjectController.text = widget.subject.name;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(AddSubject oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  ValueChanged<Color> onColorChanged;

  changeColorAndPopout(Color color) => setState(() {
    currentColor = color;
    Navigator.of(context).pop();
  });

  bool isFileEdited() {
      if (widget.subject == null) {
        if (subjectController.text == "") {
          return false;
        }
        else {
          return true;
        }
      }
      else {
        if (subjectController.text != widget.subject.name || currentColor != Color(int.tryParse(widget.subject.colour))) {
          return true;
        }
        else {
          return false;
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {

          if(await exitCheck() == null){
            Navigator.pop(context, true);
          }
          else{
            Navigator.pop(context, false);
          }
        },
        child: Stack(
          children: <Widget>[
            Scaffold(
              backgroundColor: widget.backgroundColour,
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: ThemeCheck.colorCheck(widget.themeColour)
                ),
                backgroundColor: widget.themeColour,
                title: widget.subject == null ? new Text("Add a New Subject", style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: widget.fontData.font),) : new Text(widget.subject.name),
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
                    onPressed: () {setState(() {recorder.recordAudio();});},
                  ),
                ],
              ),
              body: new Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        new Card(
                            color: widget.cardColour,
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            elevation: 3.0,
                            child: new Column(
                              children: <Widget>[
                                new Container(
                                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: subjectController,
                                    onFieldSubmitted: (String value) {
                                      setState(() {
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                      });
                                    },
                                    style: TextStyle(
                                        color: widget.fontData.color,
                                        fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                        fontFamily: widget.fontData.font
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Subject Name",
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: widget.themeColour),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                new Container(
                                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                    child: ButtonTheme(
                                      height: 50.0,
                                      child: RaisedButton(
                                        elevation: 3.0,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                  height: MediaQuery.of(context).size.height*0.8,
                                                  width: MediaQuery.of(context).size.width*0.985,
                                                  child: Card(
                                                    color: widget.cardColour,
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 30.0*ThemeCheck.orientatedScaleFactor(context)),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: <Widget>[
                                                          new IconButton(
                                                              iconSize: 32*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size,
                                                              icon: Icon(Icons.close),
                                                              color: ThemeCheck.colorCheck(widget.cardColour),
                                                              onPressed: () => Navigator.pop(context)
                                                          ),
                                                          new SizedBox(height: 20.0,),
                                                          Text(
                                                              'Select a Colour for the Subject',
                                                              style: TextStyle(
                                                                  fontSize: 20.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                  color: widget.fontData.color,
                                                                  fontFamily: widget.fontData.font,
                                                                  fontWeight: FontWeight.bold
                                                              )
                                                          ),
                                                          new SizedBox(height: 20.0,),
                                                          Flexible(
                                                            child: Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              child: Swiper(
                                                                outer: true,
                                                                viewportFraction: 0.99999,
                                                                scale: 0.9,
                                                                pagination: new SwiperPagination(
                                                                    builder: DotSwiperPaginationBuilder(
                                                                        size: 20.0,
                                                                        activeSize: 20.0,
                                                                        space: 10.0,
                                                                        activeColor: widget.themeColour
                                                                    )
                                                                ),
                                                                scrollDirection: Axis.horizontal,
                                                                control: SwiperControl(
                                                                    color: widget.themeColour,
                                                                    padding: EdgeInsets.zero,
                                                                    size: 24*ThemeCheck.orientatedScaleFactor(context)
                                                                ),
                                                                itemCount: 2,
                                                                itemBuilder: (BuildContext context, int index){
                                                                  if (index == 0) {
                                                                    return Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: <Widget>[
                                                                        Text(
                                                                            "Basic Colours",
                                                                            style: TextStyle(
                                                                                fontSize: 20.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                                color: widget.fontData.color,
                                                                                fontFamily: widget.fontData.font
                                                                            )
                                                                        ),
                                                                        new SizedBox(height: 20.0,),
                                                                        Flexible(
                                                                            child: Container(
                                                                              height: MediaQuery.of(context).size.height,
                                                                              child: BlockPicker(
                                                                                pickerColor: currentColor,
                                                                                onColorChanged: changeColorAndPopout,
                                                                              ),
                                                                            )
                                                                        )
                                                                      ],
                                                                    );
                                                                  }
                                                                  else {
                                                                    return Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: <Widget>[
                                                                        Text(
                                                                            "Colourblind Friendly Colours",
                                                                            style: TextStyle(
                                                                                fontSize: 20.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                                color: widget.fontData.color,
                                                                                fontFamily: widget.fontData.font
                                                                            )
                                                                        ),
                                                                        new SizedBox(height: 20.0,),
                                                                        Flexible(
                                                                            child: Container(
                                                                              height: MediaQuery.of(context).size.height,
                                                                              child: BlockPicker(
                                                                                availableColors: ThemeCheck.colorBlindFriendlyColours(),
                                                                                pickerColor: currentColor,
                                                                                onColorChanged: changeColorAndPopout,
                                                                              ),
                                                                            )
                                                                        )
                                                                      ],
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                              );},
                                          );},
                                        child: Align(alignment: Alignment.centerLeft, child: Text('Select Subject Colour', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font))),
                                        color: currentColor != null ? currentColor : widget.themeColour,

                                        textColor: ThemeCheck.colorCheck(currentColor != null ? currentColor : widget.themeColour),
                                      ),
                                    )
                                ),
                                SizedBox(height: 20.0),
                              ],
                            )
                        ),
                        SizedBox(height: 10.0),
                        new Container(
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: ButtonTheme(
                              height: 50.0*ThemeCheck.orientatedScaleFactor(context),
                              child: RaisedButton(
                                elevation: 3.0,
                                onPressed: showAreYouSureDialog,
                                child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font,))),
                                color: ThemeCheck.errorColorOfColor(widget.themeColour),

                                textColor: ThemeCheck.colorCheck(ThemeCheck.errorColorOfColor(widget.themeColour)),
                              ),
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
                              margin: MediaQuery.of(context).viewInsets,
                              child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, widget.fontData, widget.cardColour, widget.themeColour, widget.iconData, widget.backgroundColour)],
                      ) : new Container()
                  ),
                ],
              )
            ),
            submitting ? new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                    margin: MediaQuery.of(context).padding,
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0*ThemeCheck.orientatedScaleFactor(context), valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              ],
            ): new Container()
          ],
        )
    );
  }

  void showAreYouSureDialog() {

    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text(
        "Do you want to ADD this Subject to your Subject Hub?",
        style: TextStyle(
          fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: widget.fontData.font,
          color: widget.fontData.color
        ),
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text(
          "NO",
          style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
              color: widget.themeColour
            ),
          ),
        ),
        new FlatButton(onPressed: () async {
          if (subjectController.text == "") {
            Navigator.pop(context);
            showYouMustHaveFileNameDialog();
            return false;
          }
          else {
            submit(true);
            Navigator.pop(context);
            await addSubject();
            submit(false);
            Navigator.pop(context);
            return true;
          }
        }, child: new Text(
          "YES",
          style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
              color: widget.themeColour
            ),
          ),
        ),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text(
          "Do you want to SAVE this Subject?",
          style: TextStyle(
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
                color: widget.themeColour
              ),
            ),
          ),
          new FlatButton(onPressed: () async {
            if (subjectController.text == "") {
              showYouMustHaveFileNameDialog();
              return false;
            }
            else {
              submit(true);
              Navigator.pop(context);
              await addSubject();
              submit(false);
              Navigator.pop(context);
              return true;
            }
          }, child: new Text("YES",
            style: TextStyle(
                fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                fontFamily: widget.fontData.font,
                fontWeight: FontWeight.bold,
                color: widget.themeColour
              ),
            )
          ),
        ],
      );

      return showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
    }
    else {
      return true;
    }
  }

  void showYouMustHaveFileNameDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: widget.cardColour,
      content: new Text(
        "You must have a Subject Name",
        style: TextStyle(
            fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: widget.fontData.font,
            color: widget.fontData.color
        ),
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text(
          "OK",
          style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              fontWeight: FontWeight.bold,
              color: widget.themeColour
            ),
          )
        ),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void addSubject() async {
    //create map of subject data
    Map map = {
      "id": widget.subject == null ? null : widget.subject.id,
      "name": subjectController.text,
      "colour": currentColor != null ? currentColor.value.toString() : Theme.of(context).accentColor.value.toString(),
      "oldTitle": widget.subject == null ? null : widget.subject.name,
    };

    var response = await requestManager.putSubject(map);

    //if null, then the request was a success, retrieve the information
    if (response !=  "success"){
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: widget.cardColour,
        content: new Text(
            "An error has occured please try again",
            style: TextStyle(
              fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: widget.fontData.font,
              color: widget.fontData.color
            ),
        ),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text(
              "OK",
              style: TextStyle(
                  fontSize: 18.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                  fontFamily: widget.fontData.font,
                  fontWeight: FontWeight.bold,
                  color: widget.themeColour
              ),
            )
          )
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
