class SubjectFile
{
  String _url;
  String _fileName;

  SubjectFile(String url, String fileName)
  {
    this._url = url;
    this._fileName = fileName;
  }

  String get url {
    return this._url;
  }

  String get fileName {
    return this._fileName;
  }
}