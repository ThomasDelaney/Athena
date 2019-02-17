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

  bool playing = true;

  bool init = false;

  int currentProgress = 0;

  ChewieController _chewieController;
  VideoPlayerController _controller;
  double _aspectRatio = 3/2;

  void playVideo() async {
    await _chewieController.play();

    setState(() {
      playing = true;
    });
  }

  void stopVideo() async {

    await _controller.pause();
    await _chewieController.pause();

    setState(() {
      playing = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = widget.controller;

    init = true;
  }

  @override
  void dispose() {
    _chewieController.exitFullScreen();
    _chewieController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoManager oldWidget) {
    if (widget.controller != oldWidget.controller) {
      if (playing && !init) {
        stopVideo();

        setState(() {
          playing = false;
        });
      }
      else {
        setState(() {
          init = false;
        });
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

     double scaleFactorLandscape = (MediaQuery.of(context).size.height/MediaQuery.of(context).size.width)*1.85;
     double scaleFactorPortrait = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;
     double scaleFactor = (MediaQuery.of(context).orientation == Orientation.portrait ? scaleFactorLandscape : scaleFactorPortrait);

    _chewieController = new ChewieController(
      videoPlayerController: _controller,
      aspectRatio: _aspectRatio,
      autoPlay: false,
      showControls: true,
      looping: true,
    );

    if (!_controller.value.initialized) {
      _controller.initialize().then((_) {
        setState(() {
          _aspectRatio = (_controller.value.size.height / _controller.value.size.width) / scaleFactor * 1.5;
        });
      });

      return new Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Container(
                child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
          ],
        ),
      );
    }
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Flexible(
              child: new Chewie(
                controller: _chewieController,
              )
          )
        ]
      );
    }
  }
}
