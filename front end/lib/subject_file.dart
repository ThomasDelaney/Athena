class SubjectFile
{
  String _url;
  String _fileName;
  String _tag;
  String _id;

  SubjectFile(String id, String url, String fileName, String tag)
  {
    this._url = url;
    this._fileName = fileName;
    this._tag = tag;
    this._id = id;
  }

  String get url {
    return this._url;
  }

  String get fileName {
    return this._fileName;
  }

  String get id {
    return this._id;
  }

  String get tag {
    return this._tag;
  }

  void set tag (String newTag) {
    this._tag = newTag;
  }
}