import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoManager extends StatefulWidget {

  VideoManager({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  _VideoManagerState createState() => _VideoManagerState();
}

class _VideoManagerState extends State<VideoManager> {

  VideoPlayerController _controller;
  double _aspectRatio = 3/2;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoManager oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _controller.pause();
      _controller.seekTo(Duration(seconds: 0));
    }
  }

  @override
  Widget build(BuildContext context) {

    if (!_controller.value.initialized) {
      _controller.initialize().then((_) {
        setState(() {_aspectRatio = _controller.value.size.width / (_controller.value.size.height / 1.15);});
      });
    }

    return new Chewie(
      _controller,
      aspectRatio: _aspectRatio,
      autoPlay: false,
      showControls: true,
      looping: true,
    );
  }
}
