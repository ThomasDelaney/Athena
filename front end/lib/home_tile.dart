import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/home_page.dart';
import 'package:my_school_life_prototype/recording_manager.dart';

class HomeTile extends StatelessWidget {

  HomeTile({Key key, this.title, this.icon, this.route, this.fontData}) : super(key: key);

  final String title;
  final IconData icon;
  final Widget route;
  final FontData fontData;

  final tileSize = 170.0;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  @override
  Widget build(BuildContext context) {

    double scaleFactorLandscape = (MediaQuery.of(context).size.height/MediaQuery.of(context).size.width)*1.85;
    double scaleFactorPortrait = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;
    double scaleFactor = (MediaQuery.of(context).orientation == Orientation.portrait ? scaleFactorPortrait : scaleFactorLandscape);

    return new GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route)),
      child: SizedBox(
          width: tileSize * scaleFactor,
          height: tileSize * scaleFactor,
          child: new Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(title, style: TextStyle(fontSize: 24*scaleFactor, color: fontData.color, fontWeight: FontWeight.bold, fontFamily: fontData.font), textAlign: TextAlign.center,),
                SizedBox(height: 10.0),
                Icon(icon, size: 55.7*scaleFactor, color: Colors.black,)
              ],
            ),)
      ),
    );
  }
}
