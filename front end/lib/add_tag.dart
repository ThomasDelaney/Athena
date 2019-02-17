import 'package:flutter/material.dart';
import 'package:my_school_life_prototype/theme_check.dart';
import 'tag.dart';
import 'request_manager.dart';

class AddTag extends StatefulWidget {

  AddTag({Key key, this.tag}) : super(key: key);

  final Tag tag;

  @override
  _AddTagState createState() => _AddTagState();
}

class _AddTagState extends State<AddTag> {

  RequestManager requestManager = RequestManager.singleton;

  final tagController = new TextEditingController();
  FocusNode tagFocusNode;

  bool submitting = false;
  String font = "";
  String oldTag = "";

  @override
  void initState() {
    if (widget.tag != null){
      oldTag = widget.tag.tag;
    }

    tagFocusNode = new FocusNode();
    super.initState();
  }

  @override
  void didChangeDependencies() {

    if (widget.tag == null) {
      tagController.text = "";
    }
    else {

      tagController.text = widget.tag.tag;
    }

    FocusScope.of(context).requestFocus(tagFocusNode);
    super.didChangeDependencies();
  }

  bool isFileEdited() {
    if (widget.tag == null) {
      if (tagController.text == "") {
        return false;
      }
      else {
        return true;
      }
    }
    else {
      if (tagController.text != widget.tag.tag) {
        return true;
      }
      else {
        return false;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: exitCheck,
        child: Stack(
          children: <Widget>[
            Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(
                title: widget.tag == null ? new Text("Add a New Tag") : new Text(widget.tag.tag),
              ),
              body: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  new Card(
                      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      elevation: 3.0,
                      child: new Column(
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            child: TextFormField(
                              focusNode: tagFocusNode,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              controller: tagController,
                              style: TextStyle(fontSize: 24.0),
                              decoration: InputDecoration(
                                  hintText: "Tag",
                                  labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).accentColor),
                                  border: UnderlineInputBorder()
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                        ],
                      )
                  ),
                  SizedBox(height: 10.0),
                  new Container(
                      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: ButtonTheme(
                        height: 50.0,
                        child: RaisedButton(
                          elevation: 3.0,
                          onPressed: showAreYouSureDialog,
                          child: Align(alignment: Alignment.centerLeft, child: Text('Submit', style: TextStyle(fontSize: 24.0))),
                          color: Theme.of(context).errorColor,

                          textColor: ThemeCheck.colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
                        ),
                      )
                  )
                ],
              ),
            ),
            submitting ? new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                new Container(
                    margin: MediaQuery.of(context).padding,
                    child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
              ],
            ): new Container()
          ],
        )
    );
  }

  void showAreYouSureDialog() {

    AlertDialog areYouSure = new AlertDialog(
      content: new Text("Do you want to ADD this Tag to your Tags?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {

          submit(true);
          Navigator.pop(context);
          List<Tag> currentTags = await requestManager.getTags();
          submit(false);

          List<String> tagsAsStrings = currentTags.map((tag) => tag.tag.toLowerCase()).toList();

          if (tagController.text == "") {
            showYouMustHaveTagDialog();
          }
          else if (tagsAsStrings.contains(tagController.text.toLowerCase())){
            showDuplicateTagDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            String result = await addTag();
            submit(false);
            if (result != "error") {
              Navigator.pop(context);
            }
          }
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        content: new Text("Do you want to SAVE this Tag?", /*style: TextStyle(fontFamily: font),*/),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
          new FlatButton(onPressed: () async {

            submit(true);
            Navigator.pop(context);
            List<Tag> currentTags = await requestManager.getTags();
            submit(false);

            List<String> tagsAsStrings = currentTags.map((tag) => tag.tag.toLowerCase()).toList();

            if (tagController.text == "") {
              showYouMustHaveTagDialog();
            }
            else if (tagsAsStrings.contains(tagController.text.toLowerCase())){
              showDuplicateTagDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await addTag();
              submit(false);
              Navigator.pop(context, true);
            }
          }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        ],
      );

      return showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
    }
    else {
      return true;
    }
  }

  void showYouMustHaveTagDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("You must have a Tag", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void showDuplicateTagDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("You Already Have a Tag with this Name", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }


  Future<String> addTag() async {
    //create map of tag data
    Map map = {"id": widget.tag == null ? null : widget.tag.id, "tag": tagController.text, "oldTag": oldTag};

    var response = await requestManager.putTag(map);

    //if null, then the request was a success, retrieve the information
    if (response !=  "success"){
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("An error has occurred. Please try again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);

      return "error";
    }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
