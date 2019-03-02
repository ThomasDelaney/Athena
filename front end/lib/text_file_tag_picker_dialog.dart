import 'package:flutter/material.dart';
import 'package:Athena/font_data.dart';
import 'package:Athena/text_file_editor.dart';
import 'package:Athena/theme_check.dart';

class TextFileTagPickerDialog extends StatefulWidget {

  final FontData fontData;
  final String previousTag;
  final String currentTag;
  final List<String> tagValues;
  final TextFileEditorState parent;

  final Color cardColour;
  final Color backgroundColour;
  final Color themeColour;

  TextFileTagPickerDialog({Key key, this.fontData, this.backgroundColour, this.themeColour, this.cardColour, this.previousTag, this.parent, this.tagValues, this.currentTag}) : super(key: key);

  @override
  _TextFileTagPickerDialogState createState() => _TextFileTagPickerDialogState();
}

class _TextFileTagPickerDialogState extends State<TextFileTagPickerDialog> {

  String currentTag = "";

  @override
  void initState() {
    currentTag = widget.currentTag;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Card(
        color: widget.cardColour,
        child: new Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0*ThemeCheck.orientatedScaleFactor(context), vertical: 10*ThemeCheck.orientatedScaleFactor(context)),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              MediaQuery.of(context).orientation == Orientation.portrait ?
              new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Wrap(
                    children: <Widget>[
                      new Text("Current Tag is: ", style: TextStyle(
                          fontSize: 20.0*widget.fontData.size,
                          fontFamily: widget.fontData.font,
                          color: widget.fontData.color
                      )
                      ),
                      new SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                            widget.previousTag,
                            maxLines: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 1,
                            style: TextStyle(
                                fontSize: 20.0*widget.fontData.size,
                                fontFamily: widget.fontData.font,
                                fontWeight: FontWeight.bold,
                                color: widget.fontData.color
                            )
                        ),
                      )
                    ],
                  ),
                  new SizedBox(height: 20.0*ThemeCheck.orientatedScaleFactor(context),),
                  new ButtonTheme(
                    child: RaisedButton(
                      elevation: 3.0,
                      onPressed: () => widget.parent.showTagList(widget.tagValues),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                                currentTag == "" ? 'Choose a Tag' : currentTag,
                                style: TextStyle(
                                  fontSize: 20.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                  fontFamily: widget.fontData.font,
                                )
                            ),
                          )
                      ),
                      color: widget.themeColour,
                      textColor: ThemeCheck.colorCheck(widget.themeColour),
                    ),
                  )
                ],
              ):
              new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Wrap(
                    children: <Widget>[
                      new Text("Current Tag is: ", style: TextStyle(
                          fontSize: 18.0*widget.fontData.size,
                          fontFamily: widget.fontData.font,
                          color: widget.fontData.color
                      )
                      ),
                      new SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                            widget.previousTag,
                            maxLines: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 1,
                            style: TextStyle(
                                fontSize: 18.0*widget.fontData.size,
                                fontFamily: widget.fontData.font,
                                fontWeight: FontWeight.bold,
                                color: widget.fontData.color
                            )
                        ),
                      )
                    ],
                  ),
                  new SizedBox(height: 20.0*ThemeCheck.orientatedScaleFactor(context),),
                  new ButtonTheme(
                    child: RaisedButton(
                      elevation: 3.0,
                      onPressed: () => widget.parent.showTagList(widget.tagValues),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                                currentTag == "" ? 'Choose a Tag' : currentTag,
                                style: TextStyle(
                                  fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context)*widget.fontData.size,
                                  fontFamily: widget.fontData.font,
                                )
                            ),
                          )
                      ),
                      color: widget.themeColour,
                      textColor: ThemeCheck.colorCheck(widget.themeColour),
                    ),
                  )
                ],
              ),
              Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  new FlatButton(
                      onPressed: () {Navigator.pop(context);},
                      child: new Text(
                        "Close",
                        style: TextStyle(
                            fontSize: 18.0*widget.fontData.size,
                            fontFamily: widget.fontData.font,
                            color: widget.themeColour
                        ),
                      )
                  ),
                  new FlatButton(
                      onPressed: () async {
                        widget.parent.submit(true);
                        Navigator.pop(context);
                        await widget.parent.addTagToNote();
                        widget.parent.submit(false);
                      },
                      child: Text(
                          "Add Tag",
                          style: TextStyle(
                              fontSize: 18.0*widget.fontData.size,
                              fontFamily: widget.fontData.font,
                              fontWeight: FontWeight.bold,
                              color: ThemeCheck.errorColorOfColor(widget.themeColour)
                          )
                      )
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
