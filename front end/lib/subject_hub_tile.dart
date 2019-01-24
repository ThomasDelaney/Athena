import 'package:flutter/material.dart';
import 'subject.dart';
import 'virtual_hardback.dart';

class SubjectHubTile extends StatelessWidget {

  SubjectHubTile({Key key, this.subject}) : super(key: key);

  final Subject subject;

  final tileSize = 185.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: tileSize,
        child: new Card(
        margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        elevation: 3.0,
        color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Container(
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(subject.name, style: TextStyle(fontSize: tileSize/6.25, color: Color(int.tryParse(subject.colour)), fontWeight: FontWeight.bold), ),
                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Card(
                                elevation: 3.0,
                                color: Theme.of(context).cardColor,
                                child: SizedBox(
                                  width: tileSize/1.80,
                                  height: tileSize/4.25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.business_center, size: tileSize/9.0, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0),
                                      Text("Materials", style: TextStyle(fontSize: tileSize/13.75, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                    ],
                                  ),
                                )
                            ),
                            SizedBox(height: 5.0),
                            Card(
                                elevation: 3.0,
                                color: Theme.of(context).cardColor,
                                child: SizedBox(
                                  width: tileSize/1.80,
                                  height: tileSize/4.25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.insert_chart, size: tileSize/9.0, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0),
                                      Text("Progress", style: TextStyle(fontSize: tileSize/13.75, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
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
                                  width: tileSize/1.60,
                                  height: tileSize/4.25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.school, size: tileSize/9.0, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0),
                                      Text("Test Results", style: TextStyle(fontSize: tileSize/13.75, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
                                    ],
                                  ),
                                )
                            ),
                            SizedBox(height: 5.0),
                            Card(
                                elevation: 3.0,
                                color: Theme.of(context).cardColor,
                                child: SizedBox(
                                  width: tileSize/1.60,
                                  height: tileSize/4.25,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.library_books, size: tileSize/9.0, color: Color.fromRGBO(70, 68, 71, 1)),
                                      SizedBox(width: 10.0),
                                      Text("Homework", style: TextStyle(fontSize: tileSize/13.75, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
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
                                width: tileSize/1.7,
                                height: tileSize/1.85,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.folder_open, size: tileSize/9.0, color: Color.fromRGBO(70, 68, 71, 1)),
                                    SizedBox(width: 10.0),
                                    Text("Hardback", style: TextStyle(fontSize: tileSize/13.75, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 68, 71, 1)))
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
