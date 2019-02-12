import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class MaterialViewer extends StatefulWidget {
  
  final bool network;
  final String source;

  MaterialViewer({Key key, this.network, this.source}) : super(key: key);
  
  @override
  _MaterialViewerState createState() => _MaterialViewerState();
}

class _MaterialViewerState extends State<MaterialViewer> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
        //the tag allows both pages to know where to return to when the user presses the back button
        body: new Center(
          child: Hero(tag: "material"+widget.source,
            //swiper widget allows to swipe between a list
            child: new PhotoView(
              maxScale: PhotoViewComputedScale.contained * 2.0,
              minScale: (PhotoViewComputedScale.contained) * 0.5,
              //get the image based on if its local file or a network url
              imageProvider: widget.network ? new CachedNetworkImageProvider(widget.source) : FileImage(File(widget.source))
            )
          ),
        )
    );
  }
}
