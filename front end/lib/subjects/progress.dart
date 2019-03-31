import 'package:Athena/design/background_settings.dart';
import 'package:Athena/design/card_settings.dart';
import 'package:Athena/design/dyslexia_friendly_settings.dart';
import 'package:Athena/utilities/sign_out.dart';
import 'package:Athena/design/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:Athena/design/athena_icon_data.dart';
import 'package:Athena/design/font_data.dart';
import 'package:Athena/design/font_settings.dart';
import 'package:Athena/home_page.dart';
import 'package:Athena/design/icon_settings.dart';
import 'package:Athena/utilities/recording_manager.dart';
import 'package:Athena/utilities/request_manager.dart';
import 'package:Athena/subjects/subject.dart';
import 'package:Athena/tags/tag_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Athena/subjects/test_result.dart';
import 'package:Athena/subjects/homework.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:Athena/utilities/theme_check.dart';

class Progress extends StatefulWidget {

  final Subject subject;

  Progress({Key key, this.subject}) : super(key: key);

  @override
  _ProgressState createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {

  bool submitting = false;

  static const grades = ['H1/O1', 'H2/O2', 'H3/O3', 'H4/O4', 'H5/O5', 'H6/O6', 'H7/O7', 'H8/O8', 'NG'];
  static const thresholds = [[90.0, 100.0], [80.0, 89.9], [70.0, 79.9], [60.0, 69.9], [50.0, 59.9], [40.0, 49.9], [30.0, 39.9], [10.0, 29.9], [0.0, 9.9]];

  RequestManager requestManager = RequestManager.singleton;

  SwiperController controller = new SwiperController();

  int currentDesc = 0;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String> statsDescription = ["Test Results", "Homework"];

  //Test Result variables
  List<TestResult> resultsList = new List<TestResult>();
  bool dataLoaded = false;

  List<charts.Series<Map, String>> resultsForChart = new List<charts.Series<Map, String>>();
  List<charts.Series<Map, num>> resultsForLineChart = new List<charts.Series<Map, num>>();

  //Homework variables
  List<Homework> homeworkList = new List<Homework>();

  List<charts.Series<Map, String>> homeworkForChart = new List<charts.Series<Map, String>>();
  List<charts.Series<Map, num>> homeworkForLineChart = new List<charts.Series<Map, num>>();

  bool fontLoaded = false;
  FontData fontData;

  bool iconLoaded = false;
  AthenaIconData iconData;

  bool cardColourLoaded = false;
  bool backgroundColourLoaded = false;
  bool themeColourLoaded = false;

  Color themeColour;
  Color backgroundColour;
  Color cardColour;

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

    await getBackgroundColour();
    await getThemeColour();
    await getCardColour();

    await getFontData();
    await getIconData();

    resultsForChart.clear();
    resultsForLineChart.clear();
    resultsList.clear();

    homeworkList.clear();
    homeworkForChart.clear();
    homeworkForLineChart.clear();

    dataLoaded = false;

    await getStatsData();
  }

  @override
  void initState() {
    recorder.assignParent(this);
    retrieveData();
    super.initState();
  }

  @override
  void didUpdateWidget(Progress oldWidget) {
    recorder.assignParent(this);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

    //double scaleFactor = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;

    List<Widget> chartList = fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && dataLoaded ? [
      Container(
        width: MediaQuery.of(context).size.width/ThemeCheck.orientatedScaleFactor(context),
        height: MediaQuery.of(context).orientation == Orientation.portrait ? (MediaQuery.of(context).size.height/1.75)/ThemeCheck.orientatedScaleFactor(context) : MediaQuery.of(context).size.height/ThemeCheck.orientatedScaleFactor(context)*1.25,
        child: charts.PieChart(
            currentDesc == 0 ? resultsForChart : homeworkForChart,
            animate: true,
            defaultRenderer: new charts.ArcRendererConfig(
                arcWidth: (90*ThemeCheck.orientatedScaleFactor(context)).round(),
                arcRendererDecorators: [new charts.ArcLabelDecorator(
                  labelPosition: charts.ArcLabelPosition.inside,
                  insideLabelStyleSpec: new charts.TextStyleSpec(
                    fontSize: ((450/ThemeCheck.orientatedScaleFactor(context))/30).round(),
                    color: charts.Color(r: fontData.color.red, g: fontData.color.green, b: fontData.color.blue, a: fontData.color.alpha),
                  ),
                )]
            )
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width/ThemeCheck.orientatedScaleFactor(context),
        height: MediaQuery.of(context).orientation == Orientation.portrait ? (MediaQuery.of(context).size.height/1.75)/ThemeCheck.orientatedScaleFactor(context) : MediaQuery.of(context).size.height/ThemeCheck.orientatedScaleFactor(context)*1.25,
        child: charts.BarChart(
            currentDesc == 0 ? resultsForChart : homeworkForChart,
            animate: true,
            domainAxis: new charts.OrdinalAxisSpec(
                renderSpec: new charts.SmallTickRendererSpec(
                    labelStyle: new charts.TextStyleSpec(
                      fontSize: ((450/ThemeCheck.orientatedScaleFactor(context))/40).round(),
                      color: charts.Color(r: fontData.color.red, g: fontData.color.green, b: fontData.color.blue, a: fontData.color.alpha),
                    )
                )
            ),
            primaryMeasureAxis: new charts.NumericAxisSpec(
              renderSpec: new charts.GridlineRendererSpec(
                labelStyle: new charts.TextStyleSpec(
                  color: charts.Color(r: fontData.color.red, g: fontData.color.green, b: fontData.color.blue, a: fontData.color.alpha),
                  fontSize: ((450/ThemeCheck.orientatedScaleFactor(context))/30).round(),
                ),
              )
            )
        )
      ),
      Container(
        width: MediaQuery.of(context).size.width/ThemeCheck.orientatedScaleFactor(context),
        height: MediaQuery.of(context).orientation == Orientation.portrait ? (MediaQuery.of(context).size.height/1.75)/ThemeCheck.orientatedScaleFactor(context) : MediaQuery.of(context).size.height/ThemeCheck.orientatedScaleFactor(context)*1.25,
        child: charts.LineChart(
            currentDesc == 0 ? resultsForLineChart : homeworkForLineChart,
            animate: true,
            defaultRenderer: new charts.LineRendererConfig(includePoints: true)
        ),
      )
    ] : [new Container()];

    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: backgroundColourLoaded ? backgroundColour : Colors.white,
          //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
          endDrawer: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && dataLoaded ?
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
            backgroundColor: Color(int.tryParse(widget.subject.colour)),
            title: Text("Progress", style: TextStyle(fontFamily: fontLoaded ? fontData.font : "", color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour))))),
            //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
            actions: recorder.recording ? <Widget>[
              // action button
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
              ),
            ] : <Widget>[
              fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && dataLoaded ? IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage()), (Route<dynamic> route) => false)
              ) : new Container(),
              // else display the mic button and settings button
              fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && dataLoaded ? IconButton(
                icon: Icon(Icons.mic),
                onPressed: () {if(this.mounted){setState(() {recorder.recordAudio();});}},
              ) : new Container(),
              fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && dataLoaded ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ) : new Container(),
            ],
          ),
          bottomNavigationBar: new Theme(
            data: ThemeData(
              canvasColor: cardColourLoaded ? cardColour : Colors.white
            ),
            child: BottomNavigationBar(
              fixedColor: Color(int.tryParse(widget.subject.colour)),
              onTap: (newIndex) {
                setState(() {
                  currentDesc = newIndex;
                });
              },
              currentIndex: currentDesc, // this will be set when a new tab is tapped
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(Icons.school, size: iconLoaded ? 26*iconData.size*ThemeCheck.orientatedScaleFactor(context) : 26*ThemeCheck.orientatedScaleFactor(context),),
                  title: new Text(statsDescription[0], style: TextStyle(
                      fontSize: fontLoaded ? 16*fontData.size*ThemeCheck.orientatedScaleFactor(context) : 16*ThemeCheck.orientatedScaleFactor(context),
                      fontFamily: fontLoaded ? fontData.font : "",
                      color: fontLoaded ? fontData.color : Colors.black
                  ),),
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.library_books, size: fontLoaded ? 26*iconData.size*ThemeCheck.orientatedScaleFactor(context) : 26*ThemeCheck.orientatedScaleFactor(context),),
                  title: new Text(statsDescription[1], style: TextStyle(
                      fontSize: fontLoaded ? 16*fontData.size*ThemeCheck.orientatedScaleFactor(context) : 16*ThemeCheck.orientatedScaleFactor(context),
                      fontFamily: fontLoaded ? fontData.font : "",
                      color: fontLoaded ? fontData.color : Colors.black
                  )),
                ),
              ],
            ),
          ),
          body: Stack(
              children: <Widget>[
                new Center(
                  child: fontLoaded && iconLoaded && cardColourLoaded && backgroundColourLoaded && themeColourLoaded && dataLoaded ?
                  new SingleChildScrollView(
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * ((0.65 + (iconData.size/fontData.size/10) / iconData.size/fontData.size)),
                      child: new Card(
                        color: cardColour,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new SizedBox(height: 25.0/ThemeCheck.orientatedScaleFactor(context),),
                            new Text(statsDescription[currentDesc],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 32.0*ThemeCheck.orientatedScaleFactor(context)*fontData.size,
                                  fontFamily: fontData.font,
                                  color: fontData.color
                              ),
                            ),
                            new Expanded(
                                child: Container(
                                  child: Swiper(
                                    outer: true,
                                    controller: controller,
                                    viewportFraction: 0.99999,
                                    scale: 0.9,
                                    pagination: SwiperPagination(builder: new SwiperCustomPagination(builder: (BuildContext context, SwiperPluginConfig config) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          IconButton(
                                              icon: Icon(Icons.pie_chart, color: config.activeIndex == 0 ? Color(int.tryParse(widget.subject.colour)) : Colors.grey,),
                                              iconSize: 28*iconData.size*ThemeCheck.orientatedScaleFactor(context),
                                              onPressed: () => controller.move(0)
                                          ),
                                          IconButton(
                                              icon: Icon(Icons.insert_chart, color: config.activeIndex == 1 ? Color(int.tryParse(widget.subject.colour)) : Colors.grey,),
                                              iconSize: 28*iconData.size*ThemeCheck.orientatedScaleFactor(context),
                                              onPressed: () => controller.move(1)
                                          ),
                                          IconButton(
                                              icon: Icon(Icons.show_chart, color: config.activeIndex == 2 ? Color(int.tryParse(widget.subject.colour)) : Colors.grey,),
                                              iconSize: 28*iconData.size*ThemeCheck.orientatedScaleFactor(context),
                                              onPressed: () => controller.move(2)
                                          ),
                                        ],
                                      );
                                    }),
                                        alignment: Alignment.bottomCenter
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 3,
                                    itemBuilder: (BuildContext context, int index){
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(
                                              child: chartList[index]
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
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
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recorder.drawRecordingCard(context, fontData, cardColour, themeColour, iconData, backgroundColour)],) : new Container()
                ),
              ]
          ),
        ),
        //container for the circular progress indicator when submitting an image, show if submitting, show blank container if not
        submitting ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                margin: MediaQuery.of(context).viewInsets,
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
          ],
        ): new Container()
      ],
    );
  }

  List<charts.Series<Map, String>> getTestResultListAsSeriesData() {
    return [
      new charts.Series<Map, String>(
        id: 'Score',
        domainFn: (Map result, _) => result['grade'],
        measureFn: (Map result, _) => result['frequency'],
        colorFn: (Map result, _) => result['colour'],
        data: getGradeFrequencies(),
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (Map row, _) => '${row['grade']}',
      )
    ];
  }

  List<charts.Series<Map, num>> getTestResultListAsSeriesDataForLineChart() {
    return [
      new charts.Series<Map, num>(
        id: 'Score',
        domainFn: (Map result, _) => result['position'],
        measureFn: (Map result, _) => result['result'],
        colorFn: (Map result, _) => result['colour'],
        strokeWidthPxFn: (Map result, _) => 4,
        data: getGradesForLineGraph(),
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (Map row, _) => '${row['grade']}',
      )
    ];
  }

  String gradeFromResult(double result){

    for (int i = 0; i < thresholds.length; i++) {
      if (result >= thresholds[i][0] && result <= thresholds[i][1]) {
        return grades[i];
      }
    }
  }

  List<Map> getGradeFrequencies(){

    List<Map> freqList = new List<Map>();

    for (int i = 0; i < grades.length; i++){

      int frequency = 0;

      for (int j = 0; j < resultsList.length; j++){
        if (grades[i] == gradeFromResult(resultsList[j].score)) {
          frequency++;
        }
      }

      if (frequency != 0) {
        freqList.add({
          "grade": grades[i],
          "frequency": frequency,
          "colour": colorFromResult(thresholds[i][1], Color(int.tryParse(widget.subject.colour))
          )}
        );
      }
    }

    return freqList;
  }

  List<Map> getGradesForLineGraph(){

    List<Map> gradeList = new List<Map>();

    Color c = new Color(int.tryParse(widget.subject.colour));

    charts.Color color = new charts.Color(r: c.red, g: c.green, b: c.blue, a: c.alpha);

    for (int i = 0; i < resultsList.length; i++){
      gradeList.add({"position": i, "result": resultsList[i].score, "colour": color});
    }

    return gradeList;
  }

  charts.Color colorFromResult(double result, Color colour){
    HSLColor hslColor = HSLColor.fromColor(colour);

    for (int i = 0; i < thresholds.length; i++) {
      if (result >= thresholds[i][0] && result <= thresholds[i][1]) {

        HSLColor newHSLColour = new HSLColor.fromAHSL(
            hslColor.alpha,
            hslColor.hue,
            hslColor.saturation,
            hslColor.lightness * ((i/(grades.length*2.75))+1)
        );

        Color newColour = newHSLColour.toColor();

        return new charts.Color(
            r: newColour.red,
            g: newColour.green,
            b: newColour.blue,
            a: newColour.alpha
        );
      }
    }
  }

  List<Map> getHomeworkFrequencies(){

    List<Map> freqList = new List<Map>();
    List<bool> completed = [true, false];
    List<double> split = [100.0, 50.0];

    for (int i = 0; i < completed.length; i++){

      int frequency = 0;

      for (int j = 0; j < homeworkList.length; j++){
        if (completed[i] == homeworkList[j].isCompleted) {
          frequency++;
        }
      }

      if (frequency != 0) {
        freqList.add({"completed": completed[i], "frequency": frequency, "colour": colorFromResult(split[i], Color(int.tryParse(widget.subject.colour)))});
      }
    }

    return freqList;
  }

  List<Map> getHomeworkForLineGraph(){

    List<Map> hList = new List<Map>();

    Color c = new Color(int.tryParse(widget.subject.colour));

    charts.Color color = new charts.Color(r: c.red, g: c.green, b: c.blue, a: c.alpha);

    for (int i = 0; i < homeworkList.length; i++){
      hList.add({"position": i, "completed": homeworkList[i].isCompleted == true ? 100.0 : 0.0, "colour": color});
    }

    return hList;
  }


  List<charts.Series<Map, String>> getHomeworkListAsSeriesData() {
    return [
      new charts.Series<Map, String>(
        id: 'Homework',
        domainFn: (Map result, _) => result['completed'] == true ? "Done" : "Not Done",
        measureFn: (Map result, _) => result['frequency'],
        colorFn: (Map result, _) => result['colour'],
        data: getHomeworkFrequencies(),
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (Map row, _) => '${ row['completed'] == true ? "Done" : "Not Done" }',
      )
    ];
  }

  List<charts.Series<Map, num>> getHomeworkListAsSeriesDataForLineChart() {
    return [
      new charts.Series<Map, num>(
        id: 'Homework',
        domainFn: (Map result, _) => result['position'],
        measureFn: (Map result, _) => result['completed'],
        colorFn: (Map result, _) => result['colour'],
        strokeWidthPxFn: (Map result, _) => 4,
        data: getHomeworkForLineGraph(),
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (Map row, _) => '${ row['completed'] == 100.0 ? "Done" : "Not Done" }',
      )
    ];
  }

  void getStatsData() async {
    List<TestResult> reqResults = await requestManager.getTestResults(widget.subject.id);
    List<Homework> reqHomework = await requestManager.getHomework(widget.subject.id);

    this.setState(() {
      resultsList = reqResults;
      resultsForChart = getTestResultListAsSeriesData();
      resultsForLineChart = getTestResultListAsSeriesDataForLineChart();

      homeworkList = reqHomework;
      homeworkForChart = getHomeworkListAsSeriesData();
      homeworkForLineChart = getHomeworkListAsSeriesDataForLineChart();

      dataLoaded = true;
    });
  }
}
