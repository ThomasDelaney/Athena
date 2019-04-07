//Class to encapsulate class material data
class ClassMaterial
{
  String _id;
  String _name;
  String _photoUrl;
  String _fileName;

  ClassMaterial(String id, String name, String photoUrl, String fileName) {
    this._id = id;
    this._name = name;
    this._photoUrl = photoUrl;
    this._fileName = fileName;
  }

  String get id {
    return this._id;
  }

  String get name {
    return this._name;
  }

  String get photoUrl {
    return this._photoUrl;
  }

  String get fileName {
    return this._fileName;
  }
}