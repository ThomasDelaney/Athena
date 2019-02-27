import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/home_page.dart';
import 'package:my_school_life_prototype/recording_manager.dart';
import 'package:my_school_life_prototype/theme_check.dart';
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

  @override
  void initState() {
    getCurrentFontData();
    super.initState();
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
              key: _scaffoldKey,
              endDrawer: new Drawer(
                child: ListView(
                  //Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    //drawer header
                    DrawerHeader(
                      child: Text('Settings', style: TextStyle(fontSize: 25.0, fontFamily: loaded ? oldData.font : "")),
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    //fonts option
                    ListTile(
                      leading: Icon(Icons.font_download),
                      title: Text('Fonts', style: TextStyle(fontSize: 20.0, fontFamily: loaded ? oldData.font : "")),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings()));
                      },
                    ),
                    //sign out option
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Sign Out', style: TextStyle(fontSize: 20.0, fontFamily: loaded ? oldData.font : "")),
                      onTap: () {
                        signOut();
                      },
                    ),
                  ],
                ),
              ),
              appBar: new AppBar(
                backgroundColor: Theme.of(context).accentColor,
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
                              hint: new Text("Choose a Font", style: TextStyle(fontSize: 24.0)),
                              items: <String>['Roboto', 'NotoSansTC', 'Montserrat', 'Arimo', 'B612', 'FiraSans', 'JosefinSans', 'Oxygen', 'Teko', 'Cuprum',
                              'Orbitron', 'Rajdhani', 'Monda', 'Philosopher', 'SignikaNegative', 'Amaranth'].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value,  style: TextStyle(fontSize: 24.0, fontFamily: value)),
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
                                    activeColor: Theme.of(context).accentColor,
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
                                                            builder: SwiperPagination.dots,
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

                                  textColor: ThemeCheck.colorCheck(currentData.color) ? Colors.white : Colors.black,
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
              ) : new Container()
            ),
            submitting || !loaded ? new Stack(
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
        content: new Text("Do you want to change your Font?", style: TextStyle(fontFamily: oldData.font),),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
      content: new Text("Do you want to change your Font?", style: TextStyle(fontFamily: oldData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void showMustHaveFontDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("You must select a Font", style: TextStyle(fontFamily: oldData.font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
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
      content: new Text("An Error has occured. Please try again"),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK"))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  //method which displays a dialog telling the user that they are about to be signed out, if they press okay then handle the sign out
  void signOut()
  {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text("You are about to be Signed Out", style: TextStyle(fontFamily: currentData.font)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK", style: TextStyle(fontFamily: currentData.font)))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => signOutDialog);
  }

  //clear shared preference information and route user back to the log in page
  void handleSignOut() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("id");
    await prefs.remove("refreshToken");


    Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
  }
}
