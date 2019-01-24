import 'package:flutter/material.dart';
import 'subject.dart';
import 'add_subject.dart';
import 'virtual_hardback.dart';
import 'subject_hub.dart';

class SubjectHubTile extends StatelessWidget {

  SubjectHubTile({Key key, this.subject, this.state}) : super(key: key);

  final SubjectHubState state;

  final Subject subject;

  final tileSize = 190.0;

  @override
  Widget build(BuildContext context) {

    double scaleFactor = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;

    return SizedBox(
        height: tileSize*scaleFactor,
        child: new Card(
        margin: EdgeInsets.fromLTRB(20.0*scaleFactor, 10.0*scaleFactor, 20.0*scaleFactor, 10.0*scaleFactor),
        elevation: 3.0,
        color: Theme.of(context).backgroundColor,
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
                        Text(subject.name, style: TextStyle(fontSize: 29.6*scaleFactor, color: Color(int.tryParse(subject.colour)), fontWeight: FontWeight.bold), ),
                        Row (
                          children: <Widget>[
                            GestureDetector(
                              child: Icon(Icons.edit, size: 28.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddSubject(subject: subject,))).whenComplete(state.retrieveData),
                            ),
                            SizedBox(width: 10.0*scaleFactor,),
                            GestureDetector(
                              child: Icon(Icons.delete, size: 28.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                              onTap: () { },
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Card(
                                elevation: 3.0,
                                color: Theme.of(context).cardColor,
                                child: SizedBox(
                                  width: 104.5*scaleFactor,
                                  height: 43.5*scaleFactor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.business_center, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0*scaleFactor),
                                      Text("Materials", style: TextStyle(fontSize: 13.45*scaleFactor, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                    ],
                                  ),
                                )
                            ),
                            SizedBox(height: 5.0*scaleFactor),
                            Card(
                                elevation: 3.0,
                                color: Theme.of(context).cardColor,
                                child: SizedBox(
                                  width: 104.5*scaleFactor,
                                  height: 43.5*scaleFactor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.insert_chart, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0*scaleFactor),
                                      Text("Progress", style: TextStyle(fontSize: 13.45*scaleFactor, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                    ],
                                  ),
                                )
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Card(
                                elevation: 3.0,
                                color: Theme.of(context).cardColor,
                                child: SizedBox(
                                  width: 120.5*scaleFactor,
                                  height: 43.5*scaleFactor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.school, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0*scaleFactor),
                                      Text("Test Results", style: TextStyle(fontSize: 13.45*scaleFactor, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                    ],
                                  ),
                                )
                            ),
                            SizedBox(height: 5.0*scaleFactor),
                            Card(
                                elevation: 3.0,
                                color: Theme.of(context).cardColor,
                                child: SizedBox(
                                  width: 120.5*scaleFactor,
                                  height: 43.5*scaleFactor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.library_books, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0*scaleFactor),
                                      Text("Homework", style: TextStyle(fontSize: 13.45*scaleFactor, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                    ],
                                  ),
                                )
                            ),
                          ],
                        ),
                        new GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VirtualHardback(subject: subject,))),
                          child: Card(
                              elevation: 3.0,
                              color: Theme.of(context).cardColor,
                              child: SizedBox(
                                width: 108.5*scaleFactor,
                                height: 100.0*scaleFactor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.folder_open, size: 20.5*scaleFactor, color: Color.fromRGBO(70, 68, 71, 1)),
                                    SizedBox(width: 10.0*scaleFactor),
                                    Text("Hardback", style: TextStyle(fontSize: 13.45*scaleFactor, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                  ],
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
          ),)
    );
  }
}
