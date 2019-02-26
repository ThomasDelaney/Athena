import 'dart:ui';

class AthenaIconData
{
  Color _color;
  double _size;

  AthenaIconData(Color color, double size)
  {
    this._color = color;
    this._size = size;
  }

  Color get color {
    return this._color;
  }

  double get size {
    return this._size;
  }

  set color (Color color) {
    this._color = color;
  }

  set size (double size) {
    this._size = size;
  }

}