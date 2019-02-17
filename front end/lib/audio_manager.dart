import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'subject_file.dart';

class AudioManager extends StatefulWidget {
  AudioManager({Key key, this.subjectFile, this.audioPlayer}) : super(key: key);

  final SubjectFile subjectFile;
  final AudioPlayer audioPlayer;

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

    playButton = IconButton(
      iconSize: 100.0,
      color: Colors.red,
      icon: Icon(Icons.play_arrow),
      //if the stop button is pressed then start the audio
      onPressed: () => playAudio(),
    );

    stopButton = IconButton(
      iconSize: 100.0,
      color: Colors.red,
      icon: Icon(Icons.stop),
      //if the stop button is pressed then stop the audio
      onPressed: () => stopAudio(),
    );
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

    double scaleFactor = (MediaQuery.of(context).size.width/MediaQuery.of(context).size.height)*1.85;

    return Container(
        child: Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width ,
                height: MediaQuery.of(context).size.height * (0.70*scaleFactor),
                child: Card (
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(widget.subjectFile.fileName, textAlign: TextAlign.left, style: TextStyle(fontSize: 24.0), ),
                      new SizedBox(height: 50.0,),
                      playing ? stopButton : playButton,
                      new Container(
                        padding: EdgeInsets.fromLTRB(0.0, MediaQuery.of(context).size.width * 0.11, 0.0, 0.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new SizedBox(width: MediaQuery.of(context).size.width * 0.11, child: new Text(visualTimerFromTime(currentProgress), textAlign: TextAlign.center, textScaleFactor: 1.25,)),
                            new SizedBox(
                                width: MediaQuery.of(context).size.width * 0.70,
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
                            maxSize != null ? new SizedBox(width: MediaQuery.of(context).size.width * 0.11, child:
                              new Text(visualTimerFromTime(maxSize), textAlign: TextAlign.center, textScaleFactor: 1.25)) :
                                new Container(child: new SizedBox(width: 15.0, height: 15.0, child: new CircularProgressIndicator(),),)
                          ],
                        )
                      ),
                    ],
                  ),
                ),
            ),
        )
    );
  }
}
