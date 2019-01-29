import 'package:flutter/material.dart';

class ThemeCheck
{
  static bool colorCheck(Color color) {
    return 1.05 / (color.computeLuminance() + 0.05) > 2.5;
  }
}