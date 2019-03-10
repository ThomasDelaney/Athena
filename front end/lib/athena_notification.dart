class AthenaNotification
{
  String _id;
  String _description;
  String _time;

  AthenaNotification(String id, String description, String time) {
    this._id = id;
    this._description = description;
    this._time = time;
  }

  String get id {
    return this._id;
  }

  String get description {
    return this._description;
  }

  String get time {
    return this._time;
  }
}