class Note
{
  String _id;
  String _fileName;
  String _delta;

  Note(String id, String fileName, String delta)
  {
    this._id = id;
    this._fileName = fileName;
    this._delta = delta;
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
}