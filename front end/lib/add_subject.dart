import 'request_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'subject.dart';

class AddSubject extends StatefulWidget {

  AddSubject({Key key, this.subject}) : super(key: key);

  final Subject subject;

  @override
  _AddSubjectState createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {

  RequestManager requestManager = RequestManager.singleton;

  final subjectController = new TextEditingController();
  FocusNode subjectFocusNode;
  Color currentColor;

  bool currentlySaved = false;

  bool submitting = false;

  @override
  void initState() {
    subjectFocusNode = new FocusNode();
    super.initState();
  }

  @override
  void didChangeDependencies() {

    if (widget.subject == null) {
      currentColor = Theme.of(context).accentColor;
    }
    else {
      currentColor = Color(int.tryParse(widget.subject.colour));
      subjectController.text = widget.subject.name;
    }

    FocusScope.of(context).requestFocus(subjectFocusNode);
    super.didChangeDependencies();
  }

  ValueChanged<Color> onColorChanged;

  changeColorAndPopout(Color color) => setState(() {
    currentColor = color;
    Navigator.of(context).pop();
  });

  bool colorCheck(Color color) {
    return 1.05 / (color.computeLuminance() + 0.05) > 2.5;
  }

  bool isFileEdited() {
    if (currentlySaved == true) {
      return false;
    }
    else {
      if (widget.subject == null) {
        if (subjectController.text == "") {
          return false;
        }
        else {
          return true;
        }
      }
      else {
        if (subjectController.text != widget.subject.name || currentColor != Color(int.tryParse(widget.subject.colour))) {
          return true;
        }
        else {
          return false;
        }
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
              appBar: new AppBar(
                title: widget.subject == null ? new Text("Add a New Subject") : new Text(widget.subject.name),
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
                              focusNode: subjectFocusNode,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              controller: subjectController,
                              style: TextStyle(fontSize: 24.0),
                              decoration: InputDecoration(
                                  hintText: "Subject Name",
                                  labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).accentColor),
                                  border: UnderlineInputBorder()
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          new Container(
                              margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              child: ButtonTheme(
                                height: 50.0,
                                child: RaisedButton(
                                  elevation: 3.0,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Select a Colour for the Subject'),
                                          content: SingleChildScrollView(
                                            child: BlockPicker(
                                              pickerColor: currentColor,
                                              onColorChanged: changeColorAndPopout,
                                            ),
                                          ),
                                        );},
                                    );},
                                  child: Align(alignment: Alignment.centerLeft, child: Text('Select Subject Colour', style: TextStyle(fontSize: 24.0))),
                                  color: currentColor,

                                  textColor: colorCheck(currentColor) ? Colors.white : Colors.black,
                                ),
                              )
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

                          textColor: colorCheck(Theme.of(context).errorColor) ? Colors.white : Colors.black,
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
      content: new Text("Do you want to ADD this Subject to your Subject Hub?", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
        new FlatButton(onPressed: () async {
          if (subjectController.text == "") {
            Navigator.pop(context);
            showYouMustHaveFileNameDialog();
          }
          else {
            submit(true);
            Navigator.pop(context);
            await addSubject();
            submit(false);
            Navigator.pop(context);
          }
        }, child: new Text("YES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  Future<bool> exitCheck() async{
    if (isFileEdited()) {
      AlertDialog areYouSure = new AlertDialog(
        content: new Text("Do you want to SAVE this Subject?", /*style: TextStyle(fontFamily: font),*/),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context, true), child: new Text("NO", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
          new FlatButton(onPressed: () async {
            if (subjectController.text == "") {
              Navigator.pop(context, false);
              showYouMustHaveFileNameDialog();
            }
            else {
              submit(true);
              Navigator.pop(context);
              await addSubject();
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

  void showYouMustHaveFileNameDialog() {
    AlertDialog areYouSure = new AlertDialog(
      content: new Text("You must have a Subject Name", /*style: TextStyle(fontFamily: font),*/),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),)),
      ],
    );

    showDialog(context: context, barrierDismissible: true, builder: (_) => areYouSure);
  }

  void addSubject() async {
    //create map of subject data
    Map map = {"id": widget.subject == null ? null : widget.subject.id, "name": subjectController.text, "colour": currentColor.value.toString()};

    var response = await requestManager.putSubject(map);

    //if null, then the request was a success, retrieve the information
    if (response ==  "success"){
      currentlySaved = true;
    }
    //else the response ['response']  is not null, then print the error message
    else{
      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text(response['error']['response']),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}