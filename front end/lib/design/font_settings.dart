import 'package:Athena/design/athena_icon_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Athena/utilities/request_manager.dart';

//Class to build the Font Settings page, allows users to change the font, font colour and font size within the application
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
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didUpdateWidget(FontSettings oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
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

  //get current font from the database
  void getCurrentFontData() async {

    FontData data = await requestManager.getFontData();

    setState(() {
      loaded = true;
      currentData = new FontData(data.font, data.color, data.size);
      oldData = new FontData(data.font, data.color, data.size);
    });
  }

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

  //check if the card data has been changed
  bool isFileEdited() {
    if (currentData.font == oldData.font) {
      return false;
    }
    else {
      return true;
    }
  }

  //method to build the font settings page
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
                title: Text("Font Settings", style: TextStyle(fontFamily: loaded ? oldData.font : "")),
                //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
                actions: recorder.recording ? <Widget>[
                  // action button
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
                  ),
                ] : <Widget>[
                  loaded && iconLoaded && themeColourLoaded && cardColourLoaded && backgroundColourLoaded ? IconButton(
                    icon: Icon(Icons.mic),
                    onPressed: () {setState(() {recorder.recordAudio();});},
                  ) : new Container(),
                  loaded && iconLoaded && themeColourLoaded && cardColourLoaded && backgroundColourLoaded ? IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false);
                      }
                  ) : new Container(),
                ]
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
                              new Container(
                                margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                //draw dropdown with different font options
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
                                                        new IconButton(
                                                            iconSize: 32*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                                                            icon: Icon(Icons.close),
                                                            color: ThemeCheck.colorCheck(cardColour),
                                                            onPressed: () => Navigator.pop(context)
                                                        ),
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
                  ),
                  new Container(
                      alignment: Alignment.center,
                      child: recorder.recording ?
                      new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                              margin: MediaQuery.of(context).viewInsets,
                              child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, oldData, cardColour, themeColour, iconData, backgroundColour)],) : new Container()
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

  //method that changes the colour chosen by the user from the colour picker widget, then pops the dialog
  changeColorAndPopout(Color color) => setState(() {
    currentData.color = color;
    Navigator.of(context).pop();
  });

  //method to submit the new font data
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

  //method that is called when the user attempts to exit the page
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

  //dialog that displays when the user submits the page without selecting a font
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
