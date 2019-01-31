class Note
{
  String _id;
  String _fileName;
  String _delta;
  String _tag;

  Note(String id, String fileName, String delta, String tag)
  {
    this._id = id;
    this._fileName = fileName;
    this._delta = delta;
    this._tag = tag;
  }

  String get id {
    return this._id;
  }

  String get fileName {
    return this._fileName;
  }

  String get delta {
    return this._delta;
  }

  String get tag {
    return this._tag;
  }
}