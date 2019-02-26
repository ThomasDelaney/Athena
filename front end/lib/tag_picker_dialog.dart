import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/font_data.dart';
import 'package:my_school_life_prototype/text_file_editor.dart';
import 'package:my_school_life_prototype/theme_check.dart';

class TagPickerDialog extends StatefulWidget {

  final FontData fontData;
  final String previousTag;
  final String currentTag;
  final List<String> tagValues;
  final TextFileEditorState parent;

  TagPickerDialog({Key key, this.fontData, this.previousTag, this.parent, this.tagValues, this.currentTag}) : super(key: key);

  @override
  _TagPickerDialogState createState() => _TagPickerDialogState();
}

class _TagPickerDialogState extends State<TagPickerDialog> {

  String currentTag = "";

  @override
  void initState() {
    currentTag = widget.currentTag;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      content: new Column(
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
                        fontSize: 20.0*widget.fontData.size,
                        fontFamily: widget.fontData.font,
                        fontWeight: FontWeight.bold,
                        color: widget.fontData.color
                    )
                ),
              )
            ],
          ),
          new SizedBox(height: 20.0,),
          MediaQuery.of(context).orientation == Orientation.portrait ?
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
              color: Theme.of(context).errorColor,

              textColor: ThemeCheck.colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
            ),
          ):
          new Expanded(
              child: new ButtonTheme(
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
                  color: Theme.of(context).errorColor,

                  textColor: ThemeCheck.colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
                ),
              )
          )
        ],
      ),
      actions: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Wrap(
            alignment: WrapAlignment.end,
            children: <Widget>[
              new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("Close", style: TextStyle(fontSize: 18.0*widget.fontData.size, fontFamily: widget.fontData.font),)),
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
                      )
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }
}
