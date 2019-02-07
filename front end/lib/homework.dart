class Homework
{
  String _id;
  String _description;
  bool _isCompleted;

  Homework(String id, String description, bool isCompleted)
  {
    this._id = id;
    this._description = description;
    this._isCompleted = isCompleted;
  }

  String get id {
    return this._id;
  }

  String get description {
    return this._description;
  }

  bool get isCompleted {
    return this._isCompleted;
  }

  void set isCompleted (bool completed) {
    this._isCompleted = completed;
  }
}