class Subject {
  String _id;
  String _name;
  String _colour;

  Subject(String id, String name, String colour)
  {
    this._id = id;
    this._name = name;
    this._colour = colour;
  }

  String get id {
    return this._id;
  }

  String get name {
    return this._name;
  }

  String get colour {
    return this._colour;
  }
}