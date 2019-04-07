import 'dart:ui';

//Class to encapsulate font data
class FontData
{
  String _font;
  Color _color;
  double _size;

  FontData(String font, Color color, double size)
  {
    this._font = font;
    this._color = color;
    this._size = size;
  }

  String get font {
    return this._font;
  }

  Color get color {
    return this._color;
  }

  double get size {
    return this._size;
  }

  set font (String font) {
    this._font = font;
  }

  set color (Color color) {
    this._color = color;
  }

  set size (double size) {
    this._size = size;
  }

}