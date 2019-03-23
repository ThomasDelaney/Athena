import 'package:Athena/request_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class ThemeCheck
{
  static Color colorCheck(Color color) {
    return 1.05 / (color.computeLuminance() + 0.05) > 1.5 ? Colors.white : Colors.black;
  }

  static List<Color> colorBlindFriendlyColours() {
    return [
      Color.fromRGBO(0, 110, 130, 1),
      Color.fromRGBO(130, 20, 160, 1),
      Color.fromRGBO(0, 90, 200, 1),
      Color.fromRGBO(0, 160, 250, 1),
      Color.fromRGBO(250, 120, 250, 1),
      Color.fromRGBO(20, 210, 220, 1),
      Color.fromRGBO(170, 10, 60, 1),
      Color.fromRGBO(250, 120, 80, 1),
      Color.fromRGBO(10, 180, 90, 1),
      Color.fromRGBO(240, 240, 50, 1),
      Color.fromRGBO(160, 250, 130, 1),
      Color.fromRGBO(250, 230, 190, 1),
    ];
  }

  static List<Color> dyslexiaFriendlyColours() {
    return [
      Color.fromRGBO(246, 219, 219, 1),
      Color.fromRGBO(242, 227, 198, 1),
      Color.fromRGBO(211, 236, 225, 1),
      Color.fromRGBO(194, 238, 199, 1),
      Color.fromRGBO(238, 210, 232, 1),
    ];
  }

  static void activateDyslexiaFriendlyMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("fontColour", Colors.black.value);
    await prefs.setInt("iconColour", Colors.black.value);
    await prefs.setInt("themeColour", Color.fromRGBO(113, 180, 227, 1).value);
    await prefs.setInt("cardColour", Color.fromRGBO(242, 227, 198, 1).value);
    await prefs.setInt("backgroundColour", errorColorOfColor(Color.fromRGBO(242, 227, 198, 1)).value);
  }

  static void disableDyslexiaFriendlyMode() async {
    RequestManager requestManger = RequestManager.singleton;

    await requestManger.getFontData();
    await requestManger.getIconData();
    await requestManger.getCardColour();
    await requestManger.getBackgroundColour();
    await requestManger.getThemeColour();
  }

  static Color errorColorOfColor(Color color){
    HSLColor hslColor = HSLColor.fromColor(color);
    HSLColor newHSLColour = new HSLColor.fromAHSL(hslColor.alpha, hslColor.hue, hslColor.saturation, hslColor.lightness / 1.20);
    return newHSLColour.toColor();
  }

  static Color lightColorOfColor(Color color){
    HSLColor hslColor = HSLColor.fromColor(color);

    double multiplier = hslColor.lightness > 0.8 ? 1.05 : hslColor.lightness > 0.6 ? 1.35 : 1.75;

    HSLColor newHSLColour = new HSLColor.fromAHSL(hslColor.alpha, hslColor.hue, hslColor.saturation, hslColor.lightness * multiplier);
    return newHSLColour.toColor();
  }

  static void getThumbnailFromVideoURL(String url){
    dynamic cap = VideoPlayerController.network('http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4').initialize().asStream().first;
    print(cap);
  }

  //scale factor based on orientation
  static double orientatedScaleFactor(BuildContext _context){

    double scaleFactorLandscape = (MediaQuery.of(_context).size.width + MediaQuery.of(_context).size.height)/1400;
    double scaleFactorPortrait = (MediaQuery.of(_context).size.height + MediaQuery.of(_context).size.width)/1400;

    return (MediaQuery.of(_context).orientation == Orientation.portrait ? scaleFactorPortrait : scaleFactorLandscape);
  }
}