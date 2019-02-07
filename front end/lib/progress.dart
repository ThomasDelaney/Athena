import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/add_result.dart';
import 'package:my_school_life_prototype/font_settings.dart';
import 'package:my_school_life_prototype/login_page.dart';
import 'package:my_school_life_prototype/recording_manager.dart';
import 'package:my_school_life_prototype/request_manager.dart';
import 'package:my_school_life_prototype/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_result.dart';
import 'homework.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'theme_check.dart';

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

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String font = "";

  int chartOption = 0;

  List<TestResult> resultsList = new List<TestResult>();
  bool resultsLoaded = false;

  List<Map> gradeResultFrequencyList = new List<Map>();
  List<Map> gradeResultsList = new List<Map>();
  List<charts.Series<Map, String>> resultsForChart = new List<charts.Series<Map, String>>();

  List<charts.Series<Map, num>> resultsForLineChart = new List<charts.Series<Map, num>>();

  void retrieveData() async {
    resultsList.clear();
    resultsLoaded = false;
    await getTestResults();
  }

  @override
  void initState() {
    retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double scaleFactor = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;

    Widget chart;

    switch (chartOption){
      case 0:
        chart = new charts.PieChart(
            resultsForChart,
            animate: true,
            defaultRenderer: new charts.ArcRendererConfig(
                arcWidth: 60,
                arcRendererDecorators: [new charts.ArcLabelDecorator(
                  insideLabelStyleSpec: new charts.TextStyleSpec(
                      fontSize: 16,
                      color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour))) ? charts.Color.white : charts.Color.black
                  ),
                  outsideLabelStyleSpec: new charts.TextStyleSpec(
                    fontSize: 16,
                  ),
                )]
            )
        );
        break;
      case 1:
        chart = new charts.BarChart(
          resultsForChart,
          animate: true,
        );
        break;
      case 2:
        chart = new charts.LineChart(
            resultsForLineChart,
            animate: true,
            defaultRenderer: new charts.LineRendererConfig(includePoints: true)
        );
        break;
    }

    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
          endDrawer: new Drawer(
            child: ListView(
              //Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                //drawer header
                DrawerHeader(
                  child: Text('Settings', style: TextStyle(fontSize: 25.0, fontFamily: font)),
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                ),
                //fonts option
                ListTile(
                  leading: Icon(Icons.font_download),
                  title: Text('Fonts', style: TextStyle(fontSize: 20.0, fontFamily: font)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings()));
                  },
                ),
                //sign out option
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Sign Out', style: TextStyle(fontSize: 20.0, fontFamily: font)),
                  onTap: () {
                    signOut();
                  },
                ),
              ],
            ),
          ),
          appBar: new AppBar(
            title: Text("Progress", style: TextStyle(fontFamily: font)),
            //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
            actions: recorder.recording ? <Widget>[
              // action button
              IconButton(
                icon: Icon(Icons.close),
                iconSize: 30.0,
                onPressed: () {if(this.mounted){setState(() {recorder.cancelRecording();});}},
              ),
            ] : <Widget>[
              IconButton(
                icon: Icon(Icons.add_circle),
                iconSize: 30.0,
                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => AddResult(subject: widget.subject,))).whenComplete(retrieveData);},
              ),
              // else display the mic button and settings button
              IconButton(
                icon: Icon(Icons.mic),
                iconSize: 30.0,
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
          bottomNavigationBar: BottomNavigationBar(
            onTap: (newIndex) {
              setState(() {
                chartOption = newIndex;
              });
            },
            currentIndex: chartOption, // this will be set when a new tab is tapped
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.pie_chart),
                title: new Text('Pie Chart'),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.insert_chart),
                title: new Text('Bar Chart'),
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  title: Text('Line Graph')
              )
            ],
          ),
          body: Stack(
              children: <Widget>[
                new Center(
                  child: resultsLoaded ? new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Text("Test Results", style: TextStyle(fontSize: 32.0),),
                      new SizedBox(
                        width: 450*scaleFactor,
                        height: 450*scaleFactor,
                        child: chart,
                      )
                    ],
                  ) : new SizedBox(width: 50.0,height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,)),
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

  //method to display sign out dialog that notifies user that they will be signed out, when OK is pressed, handle the sign out
  void signOut()
  {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text("You are about to be Signed Out", style: TextStyle(fontFamily: font)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK", style: TextStyle(fontFamily: font)))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => signOutDialog);
  }

  //clear relevant shared preference data
  void handleSignOut() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("id");
    await prefs.remove("refreshToken");

    //clear the widget stack and route user to the login page
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
  }

  List<charts.Series<Map, String>> getTestResultListAsSeriesData() {
    return [
      new charts.Series<Map, String>(
        id: 'Score',
        domainFn: (Map result, _) => result['grade'],
        measureFn: (Map result, _) => result['frequency'],
        colorFn: (Map result, _) => result['colour'],
        data: gradeResultFrequencyList,
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
        data: gradeResultsList,
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
        freqList.add({"grade": grades[i], "frequency": frequency, "colour": colorFromResult(thresholds[i][1], Color(int.tryParse(widget.subject.colour)))});
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

        HSLColor newHSLColour = new HSLColor.fromAHSL(hslColor.alpha, hslColor.hue, hslColor.saturation, hslColor.lightness * ((i/(grades.length*2.75))+1));
        Color newColour = newHSLColour.toColor();

        return new charts.Color(r: newColour.red, g: newColour.green, b: newColour.blue, a: newColour.alpha);
      }
    }
  }

  void getTestResults() async {
    List<TestResult> reqResults = await requestManager.getTestResults(widget.subject.id);
    this.setState(() {
      resultsList = reqResults;
      gradeResultFrequencyList = getGradeFrequencies();
      gradeResultsList = getGradesForLineGraph();
      resultsForChart = getTestResultListAsSeriesData();
      resultsForLineChart = getTestResultListAsSeriesDataForLineChart();
      resultsLoaded = true;
    });
  }
}
