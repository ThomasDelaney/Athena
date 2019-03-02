import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/background_settings.dart';
import 'package:Athena/card_settings.dart';
import 'package:Athena/icon_settings.dart';
import 'package:Athena/sign_out.dart';
import 'package:Athena/tag_manager.dart';
import 'package:Athena/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'request_manager.dart';

//Widget that displays the settings that allow the user to change the font used in the application
class FontSettings extends StatefulWidget {
  @override
  _FontSettingsState createState() => _FontSettingsState();
}

class _FontSettingsState extends State<FontSettings> {

  bool submitting = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  bool loaded = false;

  FontData currentData;
  FontData oldData;

  AthenaIconData iconData;
  bool iconLoaded = false;

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

  @override
  void initState() {
    retrieveData();
    super.initState();
  }

  void retrieveData() async {
    iconLoaded = false;
    loaded = false;
    cardColourLoaded = false;
    themeColourLoaded = false;
    backgroundColourLoaded = false;
    await getIconData();
    await getCurrentFontData();
    await getBackgroundColour();
    await getThemeColour();
    await getCardColour();
  }

  //get current font from shared preferences if present
  void getCurrentFontData() async {

    FontData data = await requestManager.getFontData();

    setState(() {
      loaded = true;
      currentData = new FontData(data.font, data.color, data.size);
      oldData = new FontData(data.font, data.color, data.size);
    });
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

  bool isFileEdited() {
    if (currentData.font == oldData.font) {
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
              endDrawer: new Drawer(
                child: new Container(
                  color: cardColour,
                  child: ListView(
                    //Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      //drawer header
                      DrawerHeader(
                        child: Text('Settings', style: TextStyle(fontSize: 25.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: loaded ? oldData.font : "", color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white)),
                        decoration: BoxDecoration(
                          color: themeColour,
                        ),
                      ),
                      //fonts option
                      ListTile(
                        leading: Icon(
                          Icons.font_download,
                          size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                          color: iconLoaded ? iconData.color : Colors.red,
                        ),
                        title: Text(
                            'Fonts',
                            style: TextStyle(
                              fontSize: loaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                              fontFamily: loaded ? oldData.font : "",
                              color: loaded ? oldData.color : Colors.black,
                            )
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete(retrieveData);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.insert_emoticon,
                          size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                          color: iconLoaded ? iconData.color : Colors.red,
                        ),
                        title: Text(
                            'Icons',
                            style: TextStyle(
                              fontSize: loaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                              fontFamily: loaded ? oldData.font : "",
                              color: loaded ? oldData.color : Colors.black,
                            )
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete(retrieveData);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.color_lens,
                          size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                          color: iconLoaded ? iconData.color : Colors.red,
                        ),
                        title: Text(
                            'Theme Colour',
                            style: TextStyle(
                              fontSize: loaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                              fontFamily: loaded ? oldData.font : "",
                              color: loaded ? oldData.color : Colors.black,
                            )
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettings(fontData: oldData, backgroundColour: backgroundColour, cardColour: cardColour,))).whenComplete(retrieveData);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.format_paint,
                          size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                          color: iconLoaded ? iconData.color : Colors.red,
                        ),
                        title: Text(
                            'Background Colour',
                            style: TextStyle(
                              fontSize: loaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                              fontFamily: loaded ? oldData.font : "",
                              color: loaded ? oldData.color : Colors.black,
                            )
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BackgroundSettings(fontData: oldData, themeColour: themeColour, cardColour: cardColour,))).whenComplete(retrieveData);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.colorize,
                          size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                          color: iconLoaded ? iconData.color : Colors.red,
                        ),
                        title: Text(
                            'Card Colour',
                            style: TextStyle(
                              fontSize: loaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                              fontFamily: loaded ? oldData.font : "",
                              color: loaded ? oldData.color : Colors.black,
                            )
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CardSettings(fontData: oldData, themeColour: themeColourLoaded ? themeColour : Colors.white, backgroundColour: backgroundColour,))).whenComplete(retrieveData);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.local_offer,
                          size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                          color: iconLoaded ? iconData.color : Colors.red,
                        ),
                        title: Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: loaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                              fontFamily: loaded ? oldData.font : "",
                              color: loaded ? oldData.color : Colors.black,
                            )
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TagManager()));
                        },
                      ),
                      //sign out option
                      ListTile(
                        leading: Icon(
                          Icons.exit_to_app,
                          size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                          color: iconLoaded ? iconData.color : Colors.red,),
                        title: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: loaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                              fontFamily: loaded ? oldData.font : "",
                              color: loaded ? oldData.color : Colors.black,
                            )
                        ),
                        onTap: () => SignOut.signOut(context, oldData, cardColour, themeColour),
                      ),
                    ],
                  ),
                ),
              ),
              appBar: new AppBar(
                iconTheme: IconThemeData(
                    color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white
                ),
                backgroundColor: themeColourLoaded ? themeColour : Color.fromRGBO(113, 180, 227, 1),
                title: Text("Font Settings", style: TextStyle(fontSize: 24*ThemeCheck.orientatedScaleFactor(context), fontFamily: loaded ? oldData.font : "")),
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
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              ),
              resizeToAvoidBottomPadding: false,
              body: loaded ? new ListView(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  new Card(
                      color: cardColour,
                      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      elevation: 3.0,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: new DropdownButton<String>(
                              isExpanded: true,
                              value: this.currentData.font == "" ? null : this.currentData.font,
                              hint: new Text("Choose a Font", style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: oldData.font)),
                              items: <String>['Roboto', 'NotoSansTC', 'Montserrat', 'Arimo', 'B612', 'FiraSans', 'JosefinSans', 'Oxygen', 'Teko', 'Cuprum',
                              'Orbitron', 'Rajdhani', 'Monda', 'Philosopher', 'SignikaNegative', 'Amaranth'].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value,  style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: value, color: oldData.color)),
                                );
                              }).toList(),
                              //when the font is changed in the dropdown, change the current font state
                              onChanged: (String val){
                                setState(() {this.currentData.font = val;});
                              },
                            ),
                          ),
                          SizedBox(height: 20.0),
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
                                new Text(currentData.size.toStringAsFixed(1), style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size, fontFamily: oldData.font, color: oldData.color)),
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
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 30.0*ThemeCheck.orientatedScaleFactor(context)),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: <Widget>[
                                                    new SizedBox(height: 20.0,),
                                                    Text(
                                                        'Select a Colour for the Font',
                                                        style: TextStyle(
                                                            fontSize: 20.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
                                                            color: oldData.color,
                                                            fontFamily: oldData.font,
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
                                                                  activeColor: themeColour
                                                              )
                                                          ),
                                                          scrollDirection: Axis.horizontal,
                                                          control: SwiperControl(
                                                              color: themeColour,
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
                                                                          fontSize: 20.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                          color: oldData.color,
                                                                          fontFamily: oldData.font
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
                                                                children: <Widget>[
                                                                  Text(
                                                                      "Colourblind Friendly Colours",
                                                                      style: TextStyle(
                                                                          fontSize: 20.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
                                                                          color: oldData.color,
                                                                          fontFamily: oldData.font
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
                                              ),
                                            )
                                        );},
                                    );},
                                  child: Align(alignment: Alignment.centerLeft, child: Text('Select Font Colour', style: TextStyle(fontSize: 24.0*oldData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: oldData.font))),
                                  color: currentData.color,

                                  textColor: ThemeCheck.colorCheck(currentData.color),
                                ),
                              )
                          ),
                          SizedBox(height: 20.0),
                          new Container(
                              margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              child: Text(
                                  "Test the Font Here!",
                                  style: TextStyle(
                                      fontFamily: this.currentData.font,
                                      color: currentData.color != null ? currentData.color : Colors.black,
                                      fontSize: currentData.size != null ? 24.0*currentData.size : 35.0
                                  ))
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
                          child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*oldData.size, fontFamily: oldData.font,))),
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
  void changeFont() async
  {
    submit(true);

    String result = await requestManager.putFontData(this.currentData);

    if (result == "error") {
      showErrorDialog();
    }
    else {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Font Updated!')));
      submit(false);
    }
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        backgroundColor: cardColour,
        content: new Text("Do you want to change your Font?", style: TextStyle(
            fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: oldData.font,
            color: oldData.color
        ),),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO",  style: TextStyle(
              fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: oldData.font,
              color: themeColour
          ),)),
          new FlatButton(onPressed: () async {
            if (currentData.font == "") {
              Navigator.pop(context);
              showMustHaveFontDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await changeFont();
              submit(false);
              Navigator.pop(context);
            }
          }, child: new Text("YES",  style: TextStyle(
              fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
              fontFamily: oldData.font,
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
      content: new Text("Do you want to change your Font?", style: TextStyle(
          fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: oldData.font,
          color: oldData.color
      ),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(
            fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: oldData.font,
            color: themeColour
        ),)),
        new FlatButton(onPressed: () async {
          if (currentData.font == "") {
            Navigator.pop(context);
            showMustHaveFontDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            await changeFont();
            submit(false);
            Navigator.pop(context);
          }
        }, child: new Text("YES", style: TextStyle(
            fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: oldData.font,
            fontWeight: FontWeight.bold,
            color: themeColour
        ),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void showMustHaveFontDialog() {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("You must select a Font", style: TextStyle(
          fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: oldData.font,
          color: oldData.color
      ),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(
            fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: oldData.font,
            fontWeight: FontWeight.bold,
            color: themeColour
        ),)),
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
      backgroundColor: cardColour,
      content: new Text("An Error has occured. Please try again", style: TextStyle(
          fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
          fontFamily: oldData.font,
          color: oldData.color
      )),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(
            fontSize: 18.0*oldData.size*ThemeCheck.orientatedScaleFactor(context),
            fontFamily: oldData.font,
            fontWeight: FontWeight.bold,
            color: themeColour
        )))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }
}
