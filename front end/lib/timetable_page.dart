import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/add_timeslot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timetable_slot.dart';
import 'request_manager.dart';
import 'recording_manager.dart';

//Widget that displays the users timetable information, as of current prototype implementation, it can only be accessed via voice commands
class TimetablePage extends StatefulWidget 
{
  TimetablePage({Key key, this.initialDay}) : super(key: key);

  //initial day, will be the current day if not accessed via voice command, where day could be specified
  final String initialDay;
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {

  RequestManager requestManager = RequestManager.singleton;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  //list of weekdays
  List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  String font = "";

  bool slotsLoaded = false;

  //map is "weekday", list of timeslot objects for that weekday
  Map<String, List<TimetableSlot>> timeslots = new Map<String, List<TimetableSlot>>();


  //get the currently selected font in shared preferences, if there is one
  void getFont() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.setState((){font = prefs.getString("font");});
  }

  void getTimeslots() async {
    Map<String, List<TimetableSlot>> reqTimeslots = await requestManager.getTimeslots();

    this.setState(() {
      timeslots = reqTimeslots;
      slotsLoaded = true;
    });
  }

  void retrieveData() async {
    slotsLoaded = false;
    timeslots.clear();
    getTimeslots();
    getFont();
  }

  @override
  void initState() {
    retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return Container(
      //tab controller widget allows you to tab between the different days
      child: DefaultTabController(
        //start the user on the initial day
        initialIndex: weekdays.indexOf(widget.initialDay),
        length: weekdays.length,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Timetables', style: TextStyle(fontFamily: font)),
            //tab bar implements the drawing and navigation between tabs
            bottom: TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.fromLTRB(12.5, 0.0, 12.5, 0.0),
              tabs: weekdays.map((String day) {
                return Tab(
                  text: day,
                );
              }).toList(),
            ),
          ),
          //body of the tab
          body: TabBarView(
            children: weekdays.map((String day) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: slotsLoaded ? TimeslotCard(font: font, subjectList: timeslots[day], day: day, pageState: this) :
                new Center(
                  child: SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,)),
                )
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

//widget for a timeslot card, for this prototype implementation however, it is just all the dummy timeslots
class TimeslotCard extends StatelessWidget {
  const TimeslotCard({Key key, this.font, this.subjectList, this.day, this.pageState}) : super(key: key);

  final font;

  final List<TimetableSlot> subjectList;

  final _TimetablePageState pageState;

  final String day;

  @override
  Widget build(BuildContext context) {

    if (subjectList == null) {
      return new Column(
        children: <Widget>[
          new SizedBox(height: 10.0),
          IconButton(
            icon: Icon(Icons.add_circle, color: Theme.of(context).accentColor),
            iconSize: 42.0,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTimeslot(day: day,))).whenComplete(() => pageState.retrieveData()),
          )
        ],
      );
    }
    else {
      return Center(
      //build list of timeslot data
        child: ListView.builder(
          itemCount: subjectList.length,
          itemBuilder: (context, position) {
            return new Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTimeslot(
                    day: day, currentTimeslot: subjectList[position],
                    lastTime: subjectList.length == 1 ? null : subjectList[position-1].time,)
                  )).whenComplete(() => pageState.retrieveData()),
                  child: Card(
                      margin: new EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 3.0,
                      //display a slot in a list tile
                      child: new Container(
                        padding: new EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                        child: new Row(
                          children: <Widget>[
                            Text(
                              //subject time
                              subjectList[position].time + periodOfDay(
                                  TimeOfDay(hour: int.tryParse(subjectList[position].time.split(':')[0]), minute: int.tryParse(subjectList[position].time.split(':')[1]))
                              ),
                              style: TextStyle(fontSize: 22.5, fontFamily: font, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            new SizedBox(width: MediaQuery.of(context).size.width/9),
                            new Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    subjectList[position].subjectTitle,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        fontFamily: font,
                                        color: Color(int.tryParse(subjectList[position].colour))
                                    )
                                  ),
                                  new SizedBox(height: 10.0),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.location_on, color: Colors.grey, size: 20.0,),
                                      SizedBox(width: 5.0,),
                                      Expanded(
                                        child: Text(
                                          subjectList[position].room,
                                          style: TextStyle(fontSize: 18.0, fontFamily: font),
                                        )
                                      ),
                                    ],
                                  ),
                                  new SizedBox(height: 10.0),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.face, color: Colors.grey, size: 20.0,),
                                      SizedBox(width: 5.0,),
                                      Expanded(
                                        //fit: FlexFit.loose,
                                        child: Text(
                                          subjectList[position].teacher,
                                          style: TextStyle(fontSize: 18.0, fontFamily: font),
                                          //softWrap: false,
                                          //overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            ),
                            new SizedBox(width: 15.0),
                            IconButton(
                                icon: Icon(Icons.business_center, color: Colors.grey),
                                iconSize: 32.5,
                                onPressed: () {},
                            ),
                          ]
                        ),
                      )
                    ),
                  ),
                  position == subjectList.length-1 ?
                  new Column(
                    children: <Widget>[
                      new SizedBox(height: 10.0),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Theme.of(context).accentColor),
                        iconSize: 42.0,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            AddTimeslot(day: day, lastTime: subjectList[subjectList.length-1].time,))).whenComplete(() => pageState.retrieveData()),
                      )
                    ],
                  ) : new Container()
                ],
              );
            },
          )
      );
    }
  }

  String periodOfDay(TimeOfDay timeOfDay) {
    if (timeOfDay.period == DayPeriod.am) {
      return "am";
    }
    else {
      return "pm";
    }
  }
}
