import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:my_school_life_prototype/athena_icon_data.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'subject_file.dart';
import 'package:marquee/marquee.dart';

class AudioManager extends StatefulWidget {
  AudioManager({Key key, this.subjectFile, this.audioPlayer, this.fontData, this.iconData}) : super(key: key);

  final SubjectFile subjectFile;
  final AudioPlayer audioPlayer;
  final FontData fontData;
  final AthenaIconData iconData;

  @override
  _AudioManagerState createState() => _AudioManagerState();
}

class _AudioManagerState extends State<AudioManager> {

  AudioPlayer _audioPlayer;
  int currentProgress = 0;
  int maxSize;

  bool playing = false;

  bool init = false;

  IconButton playButton;
  IconButton stopButton;

  void playAudio() async {
    await _audioPlayer.resume();

    setState(() {
      playing = true;
    });
  }

  void stopAudio() async {

    await _audioPlayer.pause();

    setState(() {
      playing = false;
    });
  }

  void onComplete() async {
    if (playing) {
      await _audioPlayer.play(widget.subjectFile.url);
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(AudioManager oldWidget) {
    if (widget.audioPlayer != oldWidget.audioPlayer) {
      if (playing && !init) {
        stopAudio();

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
  void initState() {
    super.initState();

    _audioPlayer = widget.audioPlayer;

    _audioPlayer.completionHandler = () {
      onComplete();
    };

    _audioPlayer.durationHandler = (Duration duration) {

      if (!playing){
        _audioPlayer.pause();
      }

      setState(() {
        maxSize = duration.inMilliseconds;
      });
    };

    _audioPlayer.positionHandler = (Duration  duration) {
      setState(() {
        currentProgress = duration.inMilliseconds;
      });
    };

    _audioPlayer.play(widget.subjectFile.url);

    init = true;
  }

  String visualTimerFromTime(int timeInMilliseconds)
  {
    String timeStr = "";
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);

    time.minute < 10 ? timeStr += ("0"+time.minute.toString()+":") : timeStr += (time.minute.toString()+":");
    time.second < 10 ? timeStr += ("0"+time.second.toString()) : timeStr += time.second.toString();

    return timeStr;
  }

  @override
  Widget build(BuildContext context) {

    playButton = IconButton(
      padding: EdgeInsets.zero,
      iconSize: 100.0*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size,
      color: widget.iconData.color,
      icon: Icon(Icons.play_arrow),
      //if the stop button is pressed then start the audio
      onPressed: () => playAudio(),
    );

    stopButton = IconButton(
      padding: EdgeInsets.zero,
      iconSize: 100.0*ThemeCheck.orientatedScaleFactor(context)*widget.iconData.size,
      color: widget.iconData.color,
      icon: Icon(Icons.stop),
      //if the stop button is pressed then stop the audio
      onPressed: () => stopAudio(),
    );

    double nameHeight = widget.fontData.size < 1.5 ? 135 : 75;

    return Container(
        child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width ,
              height: MediaQuery.of(context).size.height,
              child: Card (
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      height: (nameHeight*(ThemeCheck.orientatedScaleFactor(context)*(widget.fontData.size/2))) ,
                      padding: EdgeInsets.fromLTRB(10.0*ThemeCheck.orientatedScaleFactor(context), 0.0, 10.0*ThemeCheck.orientatedScaleFactor(context), 0.0),
                      child: new Marquee(
                        text: widget.subjectFile.fileName,
                        style: TextStyle(
                            color: widget.fontData.color,
                            fontFamily: widget.fontData.font,
                            fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size
                        ),
                        scrollAxis: Axis.horizontal,
                        velocity: 50.0,
                        pauseAfterRound: Duration(seconds: 2),
                        blankSpace: 20.0,
                        startPadding: 10.0*ThemeCheck.orientatedScaleFactor(context),
                      )
                    ),
                    MediaQuery.of(context).orientation == Orientation.portrait ?
                    new Column(
                      children: <Widget>[
                        playing ? stopButton : playButton,
                        new Container(
                            padding: EdgeInsets.fromLTRB(
                                10.0*ThemeCheck.orientatedScaleFactor(context),
                                25.0*ThemeCheck.orientatedScaleFactor(context),
                                10.0*ThemeCheck.orientatedScaleFactor(context),
                                0.0
                            ),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new SizedBox(
                                    child: new Text(
                                        visualTimerFromTime(currentProgress),
                                        style: TextStyle(
                                            fontSize: 18*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                            color: widget.fontData.color,
                                            fontFamily: widget.fontData.font
                                        ),
                                        textAlign: TextAlign.center
                                    )
                                ),
                                new Flexible(
                                    child: Slider(
                                        activeColor: Colors.red,
                                        value:  maxSize != null ? ((currentProgress/maxSize) * 100.0) / 100.0 : 0.0,
                                        onChanged: (double value) {
                                          setState(() {
                                            currentProgress = (maxSize*value).toInt();
                                            _audioPlayer.seek(Duration(milliseconds: (maxSize*value).toInt()));
                                          });
                                        }
                                    )
                                ),
                                maxSize != null ? new SizedBox(
                                    child: new Text(
                                      visualTimerFromTime(maxSize),
                                      style: TextStyle(
                                          fontSize: 18*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                          color: widget.fontData.color,
                                          fontFamily: widget.fontData.font
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                ):
                                new Container(child: new SizedBox(width: 15.0*ThemeCheck.orientatedScaleFactor(context), height: 15.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(),),)
                              ],
                            )
                        )
                      ],
                    ):
                    new Row(
                      children: <Widget>[
                        playing ? stopButton : playButton,
                        new Flexible(
                            child: new Container(
                                padding: EdgeInsets.fromLTRB(
                                    10.0*ThemeCheck.orientatedScaleFactor(context),
                                    0.0*ThemeCheck.orientatedScaleFactor(context),
                                    10.0*ThemeCheck.orientatedScaleFactor(context),
                                    0.0
                                ),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new SizedBox(
                                        child: new Text(
                                            visualTimerFromTime(currentProgress),
                                            style: TextStyle(
                                                fontSize: 18*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                                color: widget.fontData.color,
                                                fontFamily: widget.fontData.font
                                            ),
                                            textAlign: TextAlign.center
                                        )
                                    ),
                                    new Flexible(
                                        child: Slider(
                                            activeColor: Colors.red,
                                            value:  maxSize != null ? ((currentProgress/maxSize) * 100.0) / 100.0 : 0.0,
                                            onChanged: (double value) {
                                              setState(() {
                                                currentProgress = (maxSize*value).toInt();
                                                _audioPlayer.seek(Duration(milliseconds: (maxSize*value).toInt()));
                                              });
                                            }
                                        )
                                    ),
                                    maxSize != null ? new SizedBox(
                                        child: new Text(
                                          visualTimerFromTime(maxSize),
                                          style: TextStyle(
                                              fontSize: 18*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                              color: widget.fontData.color,
                                              fontFamily: widget.fontData.font
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                    ):
                                    new Container(child: new SizedBox(width: 15.0*ThemeCheck.orientatedScaleFactor(context), height: 15.0*ThemeCheck.orientatedScaleFactor(context), child: new CircularProgressIndicator(),),)
                                  ],
                                )
                            )
                        )
                      ],
                    )
                  ],
                ),
              ),
          ),
        )
    );
  }
}
