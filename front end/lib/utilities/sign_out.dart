import 'package:Athena/design/font_data.dart';
import 'package:Athena/login_page.dart';
import 'package:Athena/utilities/theme_check.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignOut {
  static void signOut(BuildContext context, FontData fontData, Color cardColour, Color themeColour){
    AlertDialog signOutDialog = new AlertDialog(
      backgroundColor: cardColour,
      content: new Text("You are about to be Signed Out", style: TextStyle(fontFamily: fontData.font, fontSize: 18*ThemeCheck.orientatedScaleFactor(context)*fontData.size, color: fontData.color)),
      actions: <Widget>[
        new FlatButton(onPressed: () => Navigator.pop(context), child: new Text("NO", style: TextStyle(fontFamily: fontData.font, fontSize: 18*ThemeCheck.orientatedScaleFactor(context)*fontData.size, color: themeColour))),
        new FlatButton(onPressed: () => handleSignOut(context), child: new Text("OK", style: TextStyle(fontFamily: fontData.font, fontWeight: FontWeight.bold, fontSize: 18*ThemeCheck.orientatedScaleFactor(context)*fontData.size, color: themeColour,))),
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => signOutDialog);
  }

  //clear relevant shared preference data
  static void handleSignOut(BuildContext context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("id");
    await prefs.remove("refreshToken");

    //clear the widget stack and route user to the login page
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
  }
}
