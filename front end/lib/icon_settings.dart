import 'package:Athena/background_settings.dart';
import 'package:Athena/card_settings.dart';
import 'package:Athena/sign_out.dart';
import 'package:Athena/tag_manager.dart';
import 'package:Athena/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/font_settings.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'request_manager.dart';
import 'athena_icon_data.dart';

class IconSettings extends StatefulWidget {
  @override
  _IconSettingsState createState() => _IconSettingsState();
}

class _IconSettingsState extends State<IconSettings> {
  bool submitting = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  bool loaded = false;

  AthenaIconData currentData;
  AthenaIconData oldData;

  FontData fontData;
  bool fontLoaded = false;

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

  @override
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didUpdateWidget(IconSettings oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  void retrieveData() async {
    fontLoaded = false;
    loaded = false;
    cardColourLoaded = false;
    themeColourLoaded = false;
    backgroundColourLoaded = false;
    await getFontData();
    await getCurrentIconData();
    await getBackgroundColour();
    await getThemeColour();
    await getCardColour();
  }

  //get current font from shared preferences if present
  void getFontData() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState(() {
        fontLoaded = true;
        fontData = new FontData(
            prefs.getString("font"), Color(prefs.getInt("fontColour")),
            prefs.getDouble("fontSize"));
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

  //get current font from shared preferences if present
  void getCurrentIconData() async {

    AthenaIconData data = await requestManager.getIconData();

    setState(() {
      loaded = true;
      currentData = new AthenaIconData(data.color, data.size);
      oldData = new AthenaIconData(data.color, data.size);
    });
  }

  bool isFileEdited() {
    if (currentData.size == oldData.size && currentData.color.value == oldData.color.value) {
      return false;
    }
    else {
      return true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: exitCheck,
        child: Stack(
          children: <Widget>[
            Scaffold(
                backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
                key: _scaffoldKey,
                appBar: new AppBar(
                  iconTheme: IconThemeData(
                      color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white
                  ),
                  backgroundColor: themeColourLoaded ? themeColour : Color.fromRGBO(113, 180, 227, 1),
                  title: Text("Icon Settings", style: TextStyle(fontFamily: fontLoaded ? fontData.font : "")),
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
                    // else display the mic button and settings button
                    IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {if(this.mounted){setState(() {recorder.recordAudio(context);});}},
                    ),
                  ],
                ),
                resizeToAvoidBottomPadding: false,
                body: new Stack(
                  children: <Widget>[
                    loaded ? new ListView(
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        new Card(
                            color: cardColour,
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            elevation: 3.0,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(5.0, 0.0, 20.0, 0.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: new Slider(
                                          activeColor: themeColour,
                                          inactiveColor: ThemeCheck.lightColorOfColor(themeColour),
                                          divisions: 20,
                                          value: currentData.size != null ? currentData.size : 1.0,
                                          min: 0.5,
                                          onChanged: (newVal) {
                                            setState(() {
                                              currentData.size = newVal;
                                            });
                                          },
                                          max: 2.5,
                                        ),
                                      ),
                                      new Text(currentData.size.toStringAsFixed(1), style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font, color: fontData.color)),
                                    ],
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
                                                      color: cardColour,
                                                      child: new Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 30.0*ThemeCheck.orientatedScaleFactor(context)),
                                                        child: Column(
                                                          children: <Widget>[
                                                            new IconButton(
                                                                iconSize: 32*ThemeCheck.orientatedScaleFactor(context)*oldData.size,
                                                                icon: Icon(Icons.close),
                                                                color: ThemeCheck.colorCheck(cardColour),
                                                                onPressed: () => Navigator.pop(context)
                                                            ),
                                                            new SizedBox(height: 20.0,),
                                                            Text(
                                                                'Select a Colour for your Icons',
                                                                style: TextStyle(
                                                                    fontSize: 20.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                    color: fontData.color,
                                                                    fontFamily: fontData.font,
                                                                    fontWeight: FontWeight.bold
                                                                )
                                                            ),
                                                            new SizedBox(height: 20.0,),
                                                            Flexible(
                                                              child: Container(
                                                                alignment: Alignment.center,
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
                                                                          activeColor: themeColour
                                                                      )
                                                                  ),
                                                                  scrollDirection: Axis.horizontal,
                                                                  control: SwiperControl(
                                                                      color: Theme.of(context).accentColor,
                                                                      padding: EdgeInsets.zero,
                                                                      size: 24*ThemeCheck.orientatedScaleFactor(context)
                                                                  ),
                                                                  itemCount: 2,
                                                                  itemBuilder: (BuildContext context, int index){
                                                                    if (index == 0) {
                                                                      return Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Text(
                                                                              "Basic Colours",
                                                                              style: TextStyle(
                                                                                  fontSize: 20.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                                  color: fontData.color,
                                                                                  fontFamily: fontData.font
                                                                              )
                                                                          ),
                                                                          new SizedBox(height: 20.0,),
                                                                          Flexible(
                                                                              child: Container(
                                                                                height: MediaQuery.of(context).size.height,
                                                                                child: BlockPicker(
                                                                                  pickerColor: currentData.color,
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
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Text(
                                                                              "Colourblind Friendly Colours",
                                                                              style: TextStyle(
                                                                                  fontSize: 20.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                                  color: fontData.color,
                                                                                  fontFamily: fontData.font
                                                                              )
                                                                          ),
                                                                          new SizedBox(height: 20.0,),
                                                                          Flexible(
                                                                              child: Container(
                                                                                height: MediaQuery.of(context).size.height,
                                                                                child: BlockPicker(
                                                                                  availableColors: ThemeCheck.colorBlindFriendlyColours(),
                                                                                  pickerColor: currentData.color,
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
                                                      )
                                                  )
                                              );},
                                          );},
                                        child: Align(alignment: Alignment.centerLeft, child: Text('Select Icon Colour', style: TextStyle(fontSize: 24.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font))),
                                        color: currentData.color,

                                        textColor: ThemeCheck.colorCheck(currentData.color),
                                      ),
                                    )
                                ),
                                SizedBox(height: 20.0),
                                new Container(
                                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  child: Icon(
                                    Icons.insert_emoticon,
                                    size: 32*currentData.size,
                                    color: currentData.color,
                                  ),
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
                                child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size, fontFamily: fontData.font,))),
                                color: ThemeCheck.errorColorOfColor(themeColour),

                                textColor: ThemeCheck.colorCheck(ThemeCheck.errorColorOfColor(ThemeCheck.errorColorOfColor(themeColour))),
                              ),
                            )
                        )
                      ],
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
                                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, oldData)],) : new Container()
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

  changeColorAndPopout(Color color) => setState(() {
    currentData.color = color;
    Navigator.of(context).pop();
  });

  //method to submit the new font
  void putIconData() async
  {
    submit(true);

    String result = await requestManager.putIconData(this.currentData);

    if (result == "error") {
      showErrorDialog();
    }
    else {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Icon Settings Updated!')));
      submit(false);
    }
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        backgroundColor: cardColour,
        content: new Text("Do you want to change your Icon Settings?", style: TextStyle(
            fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: fontData.font,
            color: fontData.color
        ),),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(
              fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: fontData.font,
              color: themeColour
          ),)),
          new FlatButton(onPressed: () async {
            submit(true);
            Navigator.pop(context);
            await putIconData();
            submit(false);
            Navigator.pop(context);
          }, child: new Text("YES", style: TextStyle(
              fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: fontData.font,
              fontWeight: FontWeight.bold,
              color: themeColour
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
      backgroundColor: cardColour,
      content: new Text("Do you want to change your Icon Settings?", style: TextStyle(
          fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: fontData.font,
          color: fontData.color
      ),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(
            fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: fontData.font,
            color: themeColour
        ),)),
        new FlatButton(onPressed: () async {
            submit(true);
            Navigator.pop(context);
            await putIconData();
            submit(false);
            Navigator.pop(context);
        }, child: new Text("YES", style: TextStyle(
            fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: fontData.font,
            fontWeight: FontWeight.bold,
            color: themeColour
        ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  //create an error alert dialog and display it to the user
  void showErrorDialog()
  {
    submit(false);

    AlertDialog errorDialog = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("An Error has occured. Please try again", style: TextStyle(
          fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: fontData.font,
          color: fontData.color
      )),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(
            fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: fontData.font,
            fontWeight: FontWeight.bold,
            color: themeColour
        )))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  //change submission state
  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
