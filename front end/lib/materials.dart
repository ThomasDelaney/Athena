import 'package:Athena/background_settings.dart';
import 'package:Athena/card_settings.dart';
import 'package:Athena/dyslexia_friendly_settings.dart';
import 'package:Athena/sign_out.dart';
import 'package:Athena/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:Athena/add_material.dart';
import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/font_settings.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/icon_settings.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/request_manager.dart';
import 'package:Athena/subject.dart';
import 'package:Athena/tag_manager.dart';
import 'package:Athena/theme_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'class_material.dart';

class Materials extends StatefulWidget {

  final Subject subject;

  Materials({Key key, this.subject}) : super(key: key);

  @override
  _MaterialsState createState() => _MaterialsState();
}

class _MaterialsState extends State<Materials> {

  bool submitting = false;

  RequestManager requestManager = RequestManager.singleton;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<ClassMaterial> materialList = new List<ClassMaterial>();
  bool materialsLoaded = false;

  AthenaIconData iconData;
  bool iconLoaded = false;

  bool fontLoaded = false;
  FontData fontData;

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

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
    iconLoaded = false;
    fontLoaded = false;
    cardColourLoaded = false;
    backgroundColourLoaded = false;
    themeColourLoaded = false;
    materialList.clear();
    materialsLoaded = false;
    await getIconData();
    await getFontData();
    await getMaterials();
    await getBackgroundColour();
    await getThemeColour();
    await getCardColour();
  }

  @override
  void initState() {
    retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ListView mList;

    if (materialList.length == 0 && materialsLoaded) {
      mList = new ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          new Container(
              margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: GestureDetector(
                  onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddMaterial(
                      subject: widget.subject,
                      fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                      iconData: iconLoaded ? iconData : new AthenaIconData(Colors.grey, 35.0),
                      cardColour: cardColourLoaded ? cardColour : Colors.white,
                      themeColour: themeColourLoaded ? themeColour : Color.fromRGBO(113, 180, 227, 1),
                      backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
                  ))).whenComplete(retrieveData);},
                  child: new Card(
                    color: cardColour,
                    child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text("Add Materials By Using the", textAlign: TextAlign.center, style: TextStyle(
                              fontFamily: fontData.font,
                              fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size,
                              color: fontData.color
                            ),
                          ),
                          new SizedBox(height: 10.0,),
                          new Icon(Icons.add_circle, size: 40.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color,),
                        ]
                    ),
                  ),
                ),
              )
          ),
        ],
      );
    }
    else {
      mList = ListView.builder(
        itemCount: materialList.length,
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddMaterial(
                  currentMaterial: materialList[position],
                  subject: widget.subject,
                  fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                  iconData: iconLoaded ? iconData : new AthenaIconData(Colors.grey, 35.0),
                  cardColour: cardColourLoaded ? cardColour : Colors.white,
                  themeColour: themeColourLoaded ? themeColour : Color.fromRGBO(113, 180, 227, 1),
                  backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
            ))).whenComplete(retrieveData),
            child: new Column(
              children: <Widget>[
                SizedBox(height: 10.0),
                Card(
                  color: cardColour,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  elevation: 3.0,
                  child: new Container(
                      padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
                      child: new Row(
                        children: <Widget>[
                          Expanded(
                            child: new ConstrainedBox(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                              child: new Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runAlignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  new Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.business_center, color: Color(int.tryParse(widget.subject.colour)), size: 32.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,),
                                      new SizedBox(width: 15.0*ThemeCheck.orientatedScaleFactor(context),),
                                      Text(
                                        materialList[position].name,
                                        style: TextStyle(
                                            color: fontData.color,
                                            fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size,
                                            fontFamily: fontData.font
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    child: materialList[position].photoUrl != "" ? Icon(Icons.image, size: 32.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: Color(int.parse(widget.subject.colour)),) : new Container(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                              iconSize: 32.0*ThemeCheck.orientatedScaleFactor(context)*iconData.size,
                              icon: Icon(Icons.delete, color: ThemeCheck.errorColorOfColor(iconData.color)),
                              onPressed: () => deleteMaterialDialog(materialList[position])
                          ),
                        ],
                      )
                  )
                )
              ],
            )
          );
        },
      );
    }

    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
          //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
          endDrawer: new Drawer(
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings())).whenComplete(retrieveData);
                    },
                  ),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IconSettings())).whenComplete(retrieveData);
                    },
                  ),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettings(fontData: fontData, backgroundColour: backgroundColour, cardColour: cardColour,))).whenComplete(retrieveData);
                    },
                  ),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BackgroundSettings(fontData: fontData, themeColour: themeColour, cardColour: cardColour,))).whenComplete(retrieveData);
                    },
                  ),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CardSettings(fontData: fontData, themeColour: themeColourLoaded ? themeColour : Colors.white, backgroundColour: backgroundColour,))).whenComplete(retrieveData);
                    },
                  ),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DyslexiaFriendlySettings())).whenComplete(retrieveData);
                    },
                  ),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TagManager()));
                    },
                  ),
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
          appBar: new AppBar(
            iconTheme: IconThemeData(
                color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour)))
            ),
            backgroundColor: Color(int.tryParse(widget.subject.colour)),
            title: Text("Materials", style: TextStyle(fontFamily: fontLoaded ? fontData.font : "", color: themeColourLoaded ? ThemeCheck.colorCheck(themeColour) : Colors.white)),
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
              IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddMaterial(
                  subject: widget.subject,
                  fontData: fontLoaded ? fontData : new FontData("", Colors.black, 24.0),
                  iconData: iconLoaded ? iconData : new AthenaIconData(Colors.grey, 35.0),
                  cardColour: cardColourLoaded ? cardColour : Colors.white,
                  themeColour: themeColourLoaded ? themeColour : Color.fromRGBO(113, 180, 227, 1),
                  backgroundColour: backgroundColourLoaded ? backgroundColour : Colors.white,
                ))).whenComplete(retrieveData);},
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
          body: Stack(
              children: <Widget>[
                new Center(
                  child: materialsLoaded ? mList : new Stack(
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
                            margin: MediaQuery.of(context).padding,
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context)],) : new Container()
                ),
              ]
          ),
        ),
        //container for the circular progress indicator when submitting an image, show if submitting, show blank container if not
        submitting ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                margin: MediaQuery.of(context).padding,
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
          ],
        ): new Container()
      ],
    );
  }

  void getMaterials() async {
    List<ClassMaterial> reqMaterials = await requestManager.getMaterials(widget.subject.id);
    this.setState(() {
      materialList = reqMaterials;
      materialsLoaded = true;
    });
  }

  void deleteMaterial(ClassMaterial material) async {
    var response = await requestManager.deleteMaterial(material.id, widget.subject.id, material.fileName == "" ? null : material.fileName);

    //if null, then the request was a success, retrieve the information
    if (response == "success") {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Material Deleted!', style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font))));
      retrieveData();
    }
    //else the response ['response']  is not null, then print the error message
    else {
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        backgroundColor: cardColour,
        content: new Text("An error has occured please try again", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: fontData.color)),
        actions: <Widget>[
          new FlatButton(onPressed: () {
            Navigator.pop(context);
          }, child: new Text("OK", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: fontData.color)))
        ],
      );

      showDialog(context: context,
          barrierDismissible: true,
          builder: (_) => responseDialog);
    }
  }

  void deleteMaterialDialog(ClassMaterial material) {
    AlertDialog areYouSure = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("Do you want to DELETE this Material?", style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: fontData.color)),
      actions: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.pop(context);
        }, child: new Text("NO", style: TextStyle(
            fontSize: 18*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, color: themeColour),)),
        new FlatButton(onPressed: () async {
          Navigator.pop(context);
          submit(true);
          await deleteMaterial(material);
          submit(false);
        },
        child: new Text("YES",
          style: TextStyle(fontSize: 18.0*fontData.size*ThemeCheck.orientatedScaleFactor(context), fontFamily: fontData.font, fontWeight: FontWeight.bold, color: themeColour),)),
      ],
    );

    showDialog(context: context,
        barrierDismissible: false,
        builder: (_) => areYouSure);
  }

  void submit(bool state)
  {
    if (this.mounted) {
      setState(() {
        submitting = state;
      });
    }
  }
}
