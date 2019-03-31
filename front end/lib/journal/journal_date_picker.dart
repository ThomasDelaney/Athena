import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/background_settings.dart';
import 'package:Athena/design/card_settings.dart';
import 'package:Athena/design/dyslexia_friendly_settings.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/design/font_settings.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/design/icon_settings.dart';
import 'package:Athena/journal/journal.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/sign_out.dart';
import 'package:Athena/tags/tag_manager.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:Athena/design/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';


class JournalDatePicker extends StatefulWidget {
  @override
  _JournalDatePickerState createState() => _JournalDatePickerState();
}

class _JournalDatePickerState extends State<JournalDatePicker> {
  @override

  RecordingManger recorder = RecordingManger.singleton;

  bool fontLoaded = false;
  FontData fontData;

  AthenaIconData iconData;
  bool iconLoaded = false;

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

  FocusNode dateNode;

  //get current font from shared preferences if present
  void getFontData() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (this.mounted) {
      this.setState((){
        fontLoaded = true;
        fontData = new FontData(prefs.getString("font"), Color(prefs.getInt("fontColour")), prefs.getDouble("fontSize"));
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

  void retrieveData() async {
    fontLoaded = false;
    iconLoaded = false;

    cardColourLoaded = false;
    backgroundColourLoaded = false;
    themeColourLoaded = false;

    await getBackgroundColour();
    await getThemeColour();
    await getCardColour();

    await getIconData();
    await getFontData();
  }

  @override
  void initState() {
    dateNode = new FocusNode();
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    FocusScope.of(context).requestFocus(dateNode);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(JournalDatePicker oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
      //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
      endDrawer: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded ?
      new SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: new Drawer(
          child: new Container(
            color: cardColour,
            child: ListView(
              //Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                //drawer header
                DrawerHeader(
                  child: Text('Settings', style: TextStyle(fontSize: 25.0*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontLoaded ? fontData.font : "", color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white)),
                  decoration: BoxDecoration(
                    color: themeColour,
                  ),
                ),
                //fonts option
                ListTile(
                  leading: Icon(
                    Icons.font_download,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Fonts',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.insert_emoticon,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Icons',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.color_lens,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Theme Colour',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettings(
                      backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
                      cardColour: cardColourLoaded ? cardColour : Colors.white,
                      fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                      iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                    ))).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.format_paint,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Background Colour',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BackgroundSettings(
                      cardColour: cardColourLoaded ? cardColour : Colors.white,
                      fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                      themeColour: themeColourLoaded ? themeColour : Colors.white,
                      iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                    ))).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.colorize,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Card Colour',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CardSettings(
                      fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                      themeColour: themeColourLoaded ? themeColour : Colors.white,
                      backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
                      iconData: iconLoaded ? iconData : new AthenaIconData(Colors.black, 24.0),
                    ))).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.invert_colors,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 20.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Dyslexia Friendly Mode',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DyslexiaFriendlySettings())).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                ListTile(
                  leading: Icon(
                    Icons.local_offer,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),
                  ),
                  title: Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TagManager())).whenComplete((){
                      Navigator.pop(context);
                      retrieveData();
                      recorder.assignParent(this);
                    });
                  },
                ),
                new SizedBox(height: iconLoaded ? 5*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 5*ThemeCheck.orientatedScaleFactor(context),),
                //sign out option
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    size: iconLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size : 24.0,
                    color: iconLoaded ? iconData.color : Color.fromRGBO(113, 180, 227, 1),),
                  title: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: fontLoaded ? 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size : 24.0*ThemeCheck.orientatedScaleFactor(context),
                        fontFamily: fontLoaded ? fontData.font : "",
                        color: fontLoaded ? fontData.color : Colors.black,
                      )
                  ),
                  onTap: () => SignOut.signOut(context, fontData, cardColour, themeColour),
                ),
              ],
            ),
          ),
        ),
      ) : new Container(),
      appBar: new AppBar(
        iconTheme: IconThemeData(
            color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white
        ),
        backgroundColor: themeColourLoaded ? themeColour : Colors.white,
        title: Text(
            "Journal",
            style: TextStyle(
                fontFamily: fontLoaded ? fontData.font : "",
                color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white
            )
        ),
        //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
        actions: recorder.recording ? <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
          ),
        ] : <Widget>[
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded ? IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
          ) : new Container(),
          // else display the mic button and settings button
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded ? IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {if(this.mounted){setState(() {recorder.recordAudio();});}},
          ) : new Container(),
          fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded  ? Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ) : new Container(),
        ],
      ),
      body: Stack(
          children: <Widget>[
            new Center(
                child: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded ?
                new Card(
                  elevation: 3,
                  color: cardColour,
                  child: new Container(
                    padding: EdgeInsets.all(10.0),
                    child:CalendarCarousel<Event> (
                      onDayPressed: (DateTime date, List<Event> events) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => new Journal(date: date.toString().split(' ')[0],)));
                      },
                      viewportFraction: 0.99999,
                      weekdayTextStyle: TextStyle(
                          color: themeColour
                      ),
                      headerTextStyle: TextStyle(
                          fontSize: 28.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size,
                          color: themeColour
                      ),
                      selectedDayButtonColor: themeColour,
                      weekendTextStyle: TextStyle(
                        color: themeColour,
                      ),
                      daysTextStyle: TextStyle(
                          color: fontData.color
                      ),
                      inactiveDaysTextStyle: TextStyle(
                          color: ThemeCheck.lightColorOfColor(fontData.color)
                      ),
                      iconColor: iconData.color,
                      thisMonthDayBorderColor: Colors.black,
                      weekFormat: false,
                      width: MediaQuery.of(context).size.width*0.90,
                      height: 525.0*ThemeCheck.orientatedScaleFactor(context),
                      daysHaveCircularBorder: true, /// null for not rendering any border, true for circular border, false for rectangular border
                    ) ,
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
              )
            ),
            //container for the recording card, show if recording, show blank container if not
            new Container(
                alignment: Alignment.center,
                child: recorder.recording ?
                new Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    new Container(
                        margin: MediaQuery.of(context).viewInsets,
                        child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData, backgroundColour)
                  ],
                ) : new Container()
            ),
          ]
      ),
    );
  }
}
