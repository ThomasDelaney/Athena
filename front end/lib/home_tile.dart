import 'package:flutter/material.dart';
import 'package:Athena/athena_icon_data.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/recording_manager.dart';
import 'package:Athena/theme_check.dart';

class HomeTile extends StatelessWidget {

  HomeTile({Key key, this.title, this.icon, this.route, this.fontData, this.iconData, this.themeColour}) : super(key: key);

  final String title;
  final IconData icon;
  final Widget route;
  final FontData fontData;
  final AthenaIconData iconData;
  final Color themeColour;

  final tileSize = 185.0;

  //Recording Manager Object
  RecordingManger recorder = RecordingManger.singleton;

  @override
  Widget build(BuildContext context) {

    return new GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => route)),
      child: new Container(
        width: fontData.size < 1.0 ? tileSize*ThemeCheck.orientatedScaleFactor(context) : tileSize*ThemeCheck.orientatedScaleFactor(context)*(fontData.size*1.05),
        height: fontData.size < 1.0 ? tileSize*ThemeCheck.orientatedScaleFactor(context) : tileSize*ThemeCheck.orientatedScaleFactor(context)*(fontData.size*1.05),
        padding: EdgeInsets.all(10.0*ThemeCheck.orientatedScaleFactor(context)),
        color: ThemeCheck.lightColorOfColor(themeColour),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: TextStyle(fontSize: (24*ThemeCheck.orientatedScaleFactor(context))*fontData.size, color: fontData.color, fontWeight: FontWeight.bold, fontFamily: fontData.font), textAlign: TextAlign.center,),
            SizedBox(height: 25.0*ThemeCheck.orientatedScaleFactor(context)*(fontData.size/iconData.size)),
            Icon(icon, size: 48*ThemeCheck.orientatedScaleFactor(context)*iconData.size, color: iconData.color,),
          ],
        ),
      )
    );
  }
}
