import 'package:flutter/material.dart';

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

  //scale factor based on orientation
  static double orientatedScaleFactor(BuildContext _context){

    double ratioPortrait = (MediaQuery.of(_context).size.width / MediaQuery.of(_context).size.height) < 0.60 ? 800 : 500;
    double ratioLandscape = (MediaQuery.of(_context).size.height / MediaQuery.of(_context).size.width) < 0.60 ? 800 : 500;

    double portraitDifference = (MediaQuery.of(_context).size.height - MediaQuery.of(_context).size.width)/ratioPortrait;
    double landScapeDifference = (MediaQuery.of(_context).size.width - MediaQuery.of(_context).size.height)/ratioLandscape;

    double scaleFactorLandscape = landScapeDifference*MediaQuery.of(_context).size.width / MediaQuery.of(_context).size.height;
    double scaleFactorPortrait = portraitDifference*MediaQuery.of(_context).size.height / MediaQuery.of(_context).size.width;

    return (MediaQuery.of(_context).orientation == Orientation.portrait ? scaleFactorPortrait : scaleFactorLandscape);
  }
}