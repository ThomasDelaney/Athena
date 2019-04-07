//Class to encapsulate test result data
class TestResult
{
  String _id;
  String _title;
  double _score;

  TestResult(String id, String title, double score) {
    this._id = id;
    this._title = title;
    this._score = score;
  }

  String get id {
    return this._id;
  }

  String get title {
    return this._title;
  }

  double get score {
    return this._score;
  }
}