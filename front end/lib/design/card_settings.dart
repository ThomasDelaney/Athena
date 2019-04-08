import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:Athena/utilities/request_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

//Class to build the Card Settings page, allows users to change the card colour within the application
class CardSettings extends StatefulWidget {

  CardSettings({Key key, this.fontData, this.backgroundColour, this.themeColour, this.iconData}) : super(key: key);

  final FontData fontData;
  final Color backgroundColour;
  final Color themeColour;
  final AthenaIconData iconData;

  @override
  _CardSettingsState createState() => _CardSettingsState();
}

class _CardSettingsState extends State<CardSettings> {

  RequestManager requestManager = RequestManager.singleton;
  RecordingManger recorder = RecordingManger.singleton;

  bool submitting = false;

  bool loaded = false;

  Color currentColour;
  Color oldColour;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    recorder.assignParent(this);
    getCurrentCardColour();
    super.initState();
  }

  @override
  void didUpdateWidget(CardSettings oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  //get current card colour from the database
  void getCurrentCardColour() async {

    Color data = await requestManager.getCardColour();

    setState(() {
      loaded = true;
      currentColour = data;
      oldColour = data;
    });
  }

  ValueChanged<Color> onColorChanged;

  //method that changes the colour chosen by the user from the colour picker widget, then pops the dialog
  changeColorAndPopout(Color color) => setState(() {
    currentColour = color;
    Navigator.of(context).pop();
  });

  //build Card settings page
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
                key: _scaffoldKey,
                appBar: new AppBar(
                  backgroundColor: widget.themeColour,
                  title: new Text("Card Colour Settings", style: TextStyle(fontFamily: widget.fontData.font),),
                  actions: recorder.recording ? <Widget>[
                    // action button
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
                    ),
                  ] : <Widget>[
                    loaded ? IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {setState(() {recorder.recordAudio();});},
                    ) : new Container(),
                    loaded ? IconButton(
                        icon: Icon(Icons.home),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false);
                        }
                    ) : new Container(),
                  ]
                ),
                body: new Stack(
                  children: <Widget>[
                    loaded ? SingleChildScrollView(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          new Card(
                              color: currentColour,
                              margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              elevation: 3.0,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
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
                                                      color: oldColour,
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 30.0*ThemeCheck.orientatedScaleFactor(context)),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: <Widget>[
                                                            new IconButton(
                                                                iconSize: 32*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size,
                                                                icon: Icon(Icons.close),
                                                                color: ThemeCheck.colorCheck(oldColour),
                                                                onPressed: () => Navigator.pop(context)
                                                            ),
                                                            new SizedBox(height: 20.0,),
                                                            Text(
                                                                'Select a Colour for the Card Colour',
                                                                style: TextStyle(
                                                                    fontSize: 20.0*widget.fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                    color: widget.fontData.color,
                                                                    fontFamily: widget.fontData.font,
                                                                    fontWeight: FontWeight.bold
                                                                )
                                                            ),
                                                            new SizedBox(height: 20.0,),
                                                            //build colour picker
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
                                                                      color: Theme.of(context).accentColor,
                                                                      padding: EdgeInsets.zero,
                                                                      size: 24*ThemeCheck.orientatedScaleFactor(context)
                                                                  ),
                                                                  itemCount: 3,
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
                                                                                  pickerColor: currentColour,
                                                                                  onColorChanged: changeColorAndPopout,
                                                                                ),
                                                                              )
                                                                          )
                                                                        ],
                                                                      );
                                                                    }
                                                                    else if (index == 1){
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
                                                                                  pickerColor: currentColour,
                                                                                  onColorChanged: changeColorAndPopout,
                                                                                ),
                                                                              )
                                                                          )
                                                                        ],
                                                                      );
                                                                    }
                                                                    else{
                                                                      return Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: <Widget>[
                                                                          Text(
                                                                              "Dyslexia Friendly Colours",
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
                                                                                  availableColors: ThemeCheck.dyslexiaFriendlyColours(),
                                                                                  pickerColor: currentColour,
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
                                          child: Align(alignment: Alignment.centerLeft, child: Text('Select Card Colour', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font))),
                                          color: widget.themeColour,
                                          textColor: ThemeCheck.colorCheck(widget.themeColour),
                                        ),
                                      )
                                  ),
                                  SizedBox(height: 20.0),
                                  new Container(
                                      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                      child: Text(
                                          "Test the Card Colour Here!",
                                          style: TextStyle(
                                              fontFamily: widget.fontData.font,
                                              color: widget.fontData.color,
                                              fontSize: 24*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size
                                          ))
                                  ),
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
                    ) : new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                              margin: MediaQuery.of(context).viewInsets,
                              child: new Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    new Container(
                                      child: Image.asset("assets/icon/icon3.png", width: 200*ThemeCheck.orientatedScaleFactor(context), height: 200*ThemeCheck.orientatedScaleFactor(context),),
                                    ),
                                    new ModalBarrier(color: Colors.black54, dismissible: false,),
                                  ]
                              )
                          ),
                          new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),))
                        ]
                    ),
                    new Container(
                        alignment: Alignment.center,
                        child: recorder.recording ?
                        new Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            new Container(
                                margin: MediaQuery.of(context).viewInsets,
                                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, widget.fontData, oldColour, widget.themeColour, widget.iconData, widget.backgroundColour)],) : new Container()
                    ),
                  ],
                )
            ),
            submitting ? new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                    margin: MediaQuery.of(context).viewInsets,
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              ],
            ): new Container()
          ],
        )
    );
  }

  //method to submit the new card colour
  void putCardColour() async
  {
    submit(true);

    String result = await requestManager.putCardColour(this.currentColour);

    if (result == "error") {
      showErrorDialog();
    }
    else {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Card Colour Updated!', style: TextStyle(fontSize: 18*widget.fontData.size, fontFamily: widget.fontData.font))));
      submit(false);
    }
  }

  //check if the card data has been changed
  bool isFileEdited() {
    if (currentColour == oldColour) {
      return false;
    }
    else {
      return true;
    }
  }

  //method that is called when the user attempts to exit the page
  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        content: new Text("Do you want to change your Card Colour?", style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font),),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontWeight: FontWeight.bold,),)),
          new FlatButton(onPressed: () async {
            submit(true);
            Navigator.pop(context);
            await putCardColour();
            submit(false);
            Navigator.pop(context);
          }, child: new Text("YES", style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontWeight: FontWeight.bold, fontFamily: widget.fontData.font),)),
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
      backgroundColor: oldColour,
      content: new Text("Do you want to change your Card Colour?", style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontWeight: FontWeight.bold, fontFamily: widget.fontData.font),)),
        new FlatButton(onPressed: () async {
          submit(true);
          Navigator.pop(context);
          await putCardColour();
          submit(false);
          Navigator.pop(context);
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }


  //change submission state
  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }

  //create an error alert dialog and display it to the user
  void showErrorDialog()
  {
    submit(false);

    AlertDialog errorDialog = new AlertDialog(
      backgroundColor: oldColour,
      content: new Text("An Error has occured. Please try again", style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontFamily: widget.fontData.font)),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size, fontWeight: FontWeight.bold, fontFamily: widget.fontData.font)))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }
}