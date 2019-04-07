//Class to encapsulate tag data
class Tag
{
  String _id;
  String _tag;

  Tag(String id, String tag)
  {
    this._id = id;
    this._tag = tag;
  }

  String get id {
    return this._id;
  }

  String get tag {
    return this._tag;
  }
}