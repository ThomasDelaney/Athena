import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'video_manager.dart';
import 'audio_manager.dart';
import 'package:audioplayers/audioplayers.dart';

//Widget that displays an interactive file list
class FileViewer extends StatefulWidget
{
  FileViewer({Key key, this.list, this.i}) : super(key: key);

  //list of file URLS
  final List<String> list;

  //current selected index (passed in from page in which it was invoked)
  final int i;

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer>
{
  @override
  Widget build(BuildContext context) {
    return Container(
      //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
      //the tag allows both pages to know where to return to when the user presses the back button
      child: Hero(tag: "imageView"+widget.i.toString(),
          //swiper widget allows to swipe between a list
          child: new Swiper(
            itemBuilder: (BuildContext context, int index){
              //photo view allows for zooming in and out of images
              return getFileTypeFromURL(widget.list[index]) == "image" ? new PhotoView(
                  maxScale: PhotoViewComputedScale.contained * 2.0,
                  minScale: (PhotoViewComputedScale.contained) * 0.5,
                  //get a cached network image from the current URL in the list, this will ensure the image URL does not need to be loaded every time
                  imageProvider: new CachedNetworkImageProvider(widget.list[index]))

                  : getFileTypeFromURL(widget.list[index]) == "video" ? new VideoManager(controller: new VideoPlayerController.network(widget.list[index]))
                  : getFileTypeFromURL(widget.list[index]) == "audio" ? new AudioManager(url: widget.list[index], audioPlayer: new AudioPlayer(),) : new Container();
            },
            itemCount: widget.list.length,
            pagination: new SwiperPagination(),
            control: new SwiperControl(color: Colors.white70),
            //start the wiper on the index of the image selected
            index: widget.i,
          ),
      ),
    );
  }

  String getFileTypeFromURL(String url)
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
