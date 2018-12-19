class FileTypeManger
{
  static String getFileTypeFromURL(String url)
  {
    List<String> imageTypes = const <String>["jpeg", "jfif", "jpg", "tiff", "gif", "bmp", "png", "ppm", "pgm", "pbm", "pnm"];
    List<String> videoTypes = const <String>["mp4", "m4a", "m4v", "f4v", "f4a", "m4b", "m4r", "f4b", "mov", "3gp", "3gp2", "3g2", "3gpp", "3gpp2", "wmv", "wma", "webm", "flv"];
    List<String> audioTypes = const <String>["wav", "mp3", "aif", "mid", "flp", "m4a", "flac", "ogg"];

    if (imageTypes.contains(url.substring(0, url.indexOf("?alt=media")).split('.')[5].toLowerCase())) {
      return "image";
    }
    else if (videoTypes.contains(url.substring(0, url.indexOf("?alt=media")).split('.')[5].toLowerCase())) {
      return "video";
    }
    else if (audioTypes.contains(url.substring(0, url.indexOf("?alt=media")).split('.')[5].toLowerCase())) {
      return "audio";
    }
    else {
      return "unknown";
    }
  }
}