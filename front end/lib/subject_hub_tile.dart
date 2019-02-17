import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/homework_page.dart';
import 'package:my_school_life_prototype/materials.dart';
import 'package:my_school_life_prototype/progress.dart';
import 'package:my_school_life_prototype/test_results.dart';
import 'subject.dart';
import 'add_subject.dart';
import 'virtual_hardback.dart';
import 'subject_hub.dart';
import 'request_manager.dart';

class SubjectHubTile extends StatelessWidget {

  SubjectHubTile({Key key, this.subject, this.state}) : super(key: key);

  final SubjectHubState state;

  final Subject subject;

  final RequestManager requestManager = RequestManager.singleton;

  final tileSize = 200.0;

  final smallTileSize = 60.0;
  final hardbackTileSize = 125.0;

  @override
  Widget build(BuildContext context) {

    double scaleFactorLandscape = (MediaQuery.of(context).size.height/MediaQuery.of(context).size.width)*1.85;
    double scaleFactorPortrait = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;

    double scaleFactor = (MediaQuery.of(context).orientation == Orientation.portrait ? scaleFactorPortrait : scaleFactorLandscape);

    return SizedBox(
      //height: tileSize*scaleFactor,
      child: new Card(
      margin: EdgeInsets.fromLTRB(20.0*scaleFactor, 10.0*scaleFactor, 20.0*scaleFactor, 10.0*scaleFactor),
      elevation: 3.0,
      color: Color(int.tryParse(subject.colour)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              margin: EdgeInsets.fromLTRB(10.0*scaleFactor, 10.0*scaleFactor, 10.0*scaleFactor, 10.0*scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(child: Text(subject.name, textScaleFactor: scaleFactor, style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.bold))),
                      Row (
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.edit),
                              iconSize: 30.0*scaleFactor,
                              color: Colors.white,
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddSubject(subject: subject,))).whenComplete(state.retrieveData)
                          ),
                          IconButton(
                              icon: Icon(Icons.delete),
                              iconSize: 30.0*scaleFactor,
                              color: Colors.white,
                              onPressed: () => state.deleteSubjectDialog(subject.id, subject.name)
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: smallTileSize*scaleFactor,
                              child: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Materials(subject: subject,))),
                                child: Card(
                                    elevation: 3.0,
                                    color: Theme.of(context).cardColor,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.business_center, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                        SizedBox(width: 10.0*scaleFactor),
                                        Text("Materials", textScaleFactor: scaleFactor, style: TextStyle(fontSize: 13.45, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                      ],
                                    )
                                ),
                              )
                            ),
                            SizedBox(height: 5.0*scaleFactor),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Progress(subject: subject,))),
                              child: Container(
                                height: smallTileSize*scaleFactor,
                                child: Card(
                                    elevation: 3.0,
                                    color: Theme.of(context).cardColor,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.insert_chart, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                        SizedBox(width: 10.0*scaleFactor),
                                        Text("Progress", textScaleFactor: scaleFactor, style: TextStyle(fontSize: 13.45, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                      ],
                                    )
                                ),
                              )
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TestResults(subject: subject,))),
                              child: Container(
                                height: smallTileSize*scaleFactor,
                                child: Card(
                                    elevation: 3.0,
                                    color: Theme.of(context).cardColor,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.school, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                        SizedBox(width: 10.0*scaleFactor),
                                        Text("Test Results", textScaleFactor: scaleFactor, style: TextStyle(fontSize: 13.45, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                      ],
                                    )
                                ),
                              ),
                            ),
                            SizedBox(height: 5.0*scaleFactor),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeworkPage(subject: subject,))),
                              child: Container(
                                height: smallTileSize*scaleFactor,
                                child: Card(
                                  elevation: 3.0,
                                  color: Theme.of(context).cardColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.library_books, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0*scaleFactor),
                                      Text("Homework", textScaleFactor: scaleFactor, style: TextStyle(fontSize: 13.45, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: new GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VirtualHardback(subject: subject,))),
                          child: Container(
                            height: hardbackTileSize*scaleFactor,
                            child: Card(
                              elevation: 3.0,
                              color: Theme.of(context).cardColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.folder_open, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                  SizedBox(width: 10.0*scaleFactor),
                                  Text("Hardback", textScaleFactor: scaleFactor, style: TextStyle(fontSize: 13.45, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                ],
                              ),
                            ),
                          )
                        ),
                      )
                    ],
                  )
                ],
              )
            ),
            //Icon(icon, size: tileSize/2.69, color: Color.fromRGBO(70, 68, 71, 1),)
          ],
        ),
      )
    );
  }
}
