import 'package:Athena/home_page.dart';
import 'package:flutter/material.dart';
import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/theme_check.dart';

class HomeTile extends StatelessWidget {

  HomeTile({Key key, this.title, this.icon, this.route, this.fontData, this.iconData, this.themeColour, this.state}) : super(key: key);

  final HomePageState state;
  final String title;
  final IconData icon;
  final Widget route;
  final FontData fontData;
  final AthenaIconData iconData;
  final Color themeColour;

  final tileSize = 200.0;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  @override
  Widget build(BuildContext context) {

    return new GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route)).whenComplete(() {
        state.retrieveData();
        state.recorder.assignParent(state);
      }),
      child: new Container(
        width: fontData.size <= 1.0 ? tileSize*ThemeCheck.orientatedScaleFactor(context)*((iconData.size+fontData.size)/1.85) : tileSize*ThemeCheck.orientatedScaleFactor(context)*((iconData.size+(fontData.size*1.5))/1.85),
        height: fontData.size <= 1.0 ? tileSize*ThemeCheck.orientatedScaleFactor(context)*((iconData.size+fontData.size)/1.85) : tileSize*ThemeCheck.orientatedScaleFactor(context)*((iconData.size+(fontData.size*1.5))/1.85),
        padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
        color: ThemeCheck.lightColorOfColor(themeColour),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: TextStyle(fontSize: (28*ThemeCheck.orientatedScaleFactor(context))*fontData.size, color: fontData.color, fontWeight: FontWeight.bold, fontFamily: fontData.font), textAlign: TextAlign.center,),
            SizedBox(height: 20.0),
            Icon(icon, size: 54*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color,),
          ],
        ),
      )
    );
  }
}
