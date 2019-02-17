import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
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

  bool swiperLoaded = false;

  static const grades = ['H1/O1', 'H2/O2', 'H3/O3', 'H4/O4', 'H5/O5', 'H6/O6', 'H7/O7', 'H8/O8', 'NG'];
  static const thresholds = [[90.0, 100.0], [80.0, 89.9], [70.0, 79.9], [60.0, 69.9], [50.0, 59.9], [40.0, 49.9], [30.0, 39.9], [10.0, 29.9], [0.0, 9.9]];

  RequestManager requestManager = RequestManager.singleton;

  SwiperController controller = new SwiperController();

  int currentDesc = 0;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String font = "";

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

  void retrieveData() async {
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
    retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double scaleFactor = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;

    List<Widget> chartList = [
      Container(
        width: MediaQuery.of(context).size.width/scaleFactor,
        height: MediaQuery.of(context).orientation == Orientation.portrait ? (MediaQuery.of(context).size.height/1.75)/scaleFactor : MediaQuery.of(context).size.height/scaleFactor*1.25,
        child: charts.PieChart(
            currentDesc == 0 ? resultsForChart : homeworkForChart,
            animate: true,
            defaultRenderer: new charts.ArcRendererConfig(
                arcWidth: (90*scaleFactor).round(),
                arcRendererDecorators: [new charts.ArcLabelDecorator(
                  labelPosition: charts.ArcLabelPosition.inside,
                  insideLabelStyleSpec: new charts.TextStyleSpec(
                    fontSize: ((450/scaleFactor)/30).round(),
                    color: ThemeCheck.colorCheck(Color(int.tryParse(widget.subject.colour))) ? charts.Color.white : charts.Color.black,
                  ),
                )]
            )
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width/scaleFactor,
        height: MediaQuery.of(context).orientation == Orientation.portrait ? (MediaQuery.of(context).size.height/1.75)/scaleFactor : MediaQuery.of(context).size.height/scaleFactor*1.25,
        child: charts.BarChart(
            currentDesc == 0 ? resultsForChart : homeworkForChart,
            animate: true,
            domainAxis: new charts.OrdinalAxisSpec(
                renderSpec: new charts.SmallTickRendererSpec(
                    labelStyle: new charts.TextStyleSpec(
                      fontSize: ((450/scaleFactor)/40).round(),
                    )
                )
            ),
            primaryMeasureAxis: new charts.NumericAxisSpec(
              renderSpec: new charts.GridlineRendererSpec(
                labelStyle: new charts.TextStyleSpec(
                  fontSize: ((450/scaleFactor)/30).round(),
                ),
              )
            )
        )
      ),
      Container(
        width: MediaQuery.of(context).size.width/scaleFactor,
        height: MediaQuery.of(context).orientation == Orientation.portrait ? (MediaQuery.of(context).size.height/1.75)/scaleFactor : MediaQuery.of(context).size.height/scaleFactor*1.25,
        child: charts.LineChart(
            currentDesc == 0 ? resultsForLineChart : homeworkForLineChart,
            animate: true,
            defaultRenderer: new charts.LineRendererConfig(includePoints: true)
        ),
      )
    ];

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
                    color: Theme.of(context).accentColor,
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
            backgroundColor: Color(int.tryParse(widget.subject.colour)),
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
            fixedColor: Color(int.tryParse(widget.subject.colour)),
            onTap: (newIndex) {
              setState(() {
                currentDesc = newIndex;
              });
            },
            currentIndex: currentDesc, // this will be set when a new tab is tapped
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.school),
                title: new Text(statsDescription[0]),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.library_books),
                title: new Text(statsDescription[1]),
              ),
            ],
          ),

          body: Stack(
              children: <Widget>[
                new Center(
                  child: dataLoaded ? new Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: new Card(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          new Text(statsDescription[currentDesc], style: TextStyle(fontSize: 32.0),),
                          new SizedBox(height: 25.0/scaleFactor,),
                          new Container(
                            height: MediaQuery.of(context).orientation == Orientation.portrait ? (MediaQuery.of(context).size.height*0.70)/scaleFactor :
                            (MediaQuery.of(context).size.height*0.70)/(scaleFactor/2.5),
                            width: MediaQuery.of(context).size.width,
                            child: Swiper(
                              controller: controller,
                              viewportFraction: 0.99999,
                              scale: 0.9,
                              pagination: SwiperPagination(builder: new SwiperCustomPagination(builder: (BuildContext context, SwiperPluginConfig config) {
                                return new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    IconButton(
                                        icon: Icon(Icons.pie_chart, size: 28, color: config.activeIndex == 0 ? Color(int.tryParse(widget.subject.colour)) : Colors.grey,),
                                        onPressed: () => controller.move(0)
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.insert_chart, size: 28, color: config.activeIndex == 1 ? Color(int.tryParse(widget.subject.colour)) : Colors.grey,),
                                        onPressed: () => controller.move(1)
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.show_chart, size: 28, color: config.activeIndex == 2 ? Color(int.tryParse(widget.subject.colour)) : Colors.grey,),
                                        onPressed: () => controller.move(2)
                                    ),
                                  ],
                                );
                              }), alignment: Alignment.bottomCenter),
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (BuildContext context, int index){
                                return new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(child: chartList[index]),
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
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
