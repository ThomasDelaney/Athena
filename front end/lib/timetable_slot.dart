class TimetableSlot
{
  String _id;
  String _subjectTitle;
  String _colour;
  String _time;
  String _teacher;
  String _room;

  TimetableSlot(String id, String subjectTitle, String colour, String time, String teacher, String room) {
    this._id = id;
    this._subjectTitle = subjectTitle;
    this._colour = colour;
    this._time = time;
    this._teacher = teacher;
    this._room = room;
  }

  String get id {
    return this._id;
  }

  String get subjectTitle {
    return this._subjectTitle;
  }

  String get colour {
    return this._colour;
  }

  String get time {
    return this._time;
  }

  String get teacher {
    return this._teacher;
  }

  String get room {
    return this._room;
  }
}
