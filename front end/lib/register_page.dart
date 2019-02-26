import 'package:flutter/material.dart';
import 'dart:convert';
import 'request_manager.dart';

//class to display and handle the register page
class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/RegisterPage";
  final String pageTitle;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RequestManager requestManager = RequestManager.singleton;

  //boolean to check if the user is submitting
  bool submitting = false;

  //text editing controllers, used to retrieve the text entered by the user in a text form field
  final firstNameController = new TextEditingController();
  final secondNameController = new TextEditingController();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final reEnteredPasswordController = new TextEditingController();

  FocusNode firstNameFocusNode = new FocusNode();
  FocusNode secondNameFocusNode = new FocusNode();
  FocusNode emailFocusNode = new FocusNode();
  FocusNode passwordFocusNode = new FocusNode();
  FocusNode reEnteredPasswordFocusNode = new FocusNode();

  @override
  void didChangeDependencies() {
    FocusScope.of(context).requestFocus(firstNameFocusNode);
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {

    //text input field for the user's first name
    final firstName = new TextFormField(
      focusNode: firstNameFocusNode,
      keyboardType: TextInputType.text,
      autofocus: false,
      controller: firstNameController,

      onFieldSubmitted: (String value) {
        FocusScope.of(context).requestFocus(secondNameFocusNode);
      },

      decoration: InputDecoration(
          hintText: "First Name",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    //text input field for the user's second name
    final secondName = new TextFormField(
      keyboardType: TextInputType.text,
      focusNode: secondNameFocusNode,
      autofocus: false,
      controller: secondNameController,

      onFieldSubmitted: (String value) {
        FocusScope.of(context).requestFocus(emailFocusNode);
      },

      decoration: InputDecoration(
          hintText: "Second Name",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    //text input field for the user's email
    final email = new TextFormField(
      focusNode: emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: emailController,

      onFieldSubmitted: (String value) {
        FocusScope.of(context).requestFocus(passwordFocusNode);
      },

      decoration: InputDecoration(
          hintText: "Email",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    //text input field for the user's password name
    final password = new TextFormField(
      autofocus: false,
      focusNode: passwordFocusNode,
      obscureText: true,
      controller: passwordController,

      onFieldSubmitted: (String value) {
        FocusScope.of(context).requestFocus(reEnteredPasswordFocusNode);
      },

      decoration: InputDecoration(
          hintText: "Password",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    //text input field for the user to re-enter their password
    final reEnterPassword = new TextFormField(
      focusNode: reEnteredPasswordFocusNode,
      autofocus: false,
      controller: reEnteredPasswordController,
      obscureText: true,

      onFieldSubmitted: (String value) {
        FocusScope.of(context).requestFocus(new FocusNode());
      },

      decoration: InputDecoration(
          hintText: "Re-Enter Password",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    //button which when pressed, will submit the user's inputted data
    final registerButton = ButtonTheme(
        minWidth: MediaQuery.of(context).size.width * 0.95,
        height: 46.0,
        child: new RaisedButton(
            child: new Text("Register", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
            color: Colors.red,
            onPressed: () => registerUser(firstNameController.text, secondNameController.text, emailController.text, passwordController.text, reEnteredPasswordController.text)
        )
    );

    //a circular progress indicator widget. which is centered on the screen
    final centeredIndicator = new Center(
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new SizedBox(
              height: 60.0,
              width: 60.0,
              child: new CircularProgressIndicator(
                strokeWidth: 7.0,
              ),
            )
        ]
      )
    );

    //container which houses all the widgets previously instantiated
    final registerForm = new Container(
      padding: EdgeInsets.only(left: 25.0, right: 25.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
            firstName,
            SizedBox(height: 30.0),
            secondName,
            SizedBox(height: 30.0),
            email,
            SizedBox(height: 30.0),
            password,
            SizedBox(height: 30.0),
            reEnterPassword,
            SizedBox(height: 30.0),
            registerButton
        ],
      ),
    );

    //a stack widget, which has the registerForm container as a child (this will allow for widgets to be put on-top of the stack(
    final pageStack = new Stack(
      children: <Widget>[
        submitting ? centeredIndicator : new Container(),
        registerForm
      ],
    );

    //scaffold which includes the appbar, and the stack within a centered container
    final page = Scaffold(
        appBar: new AppBar(
          title: new Text(widget.pageTitle),
        ),
        body: new Center(
          child: new SingleChildScrollView(
              child: pageStack
            ),
        )
    );

    return page;
  }

  //method to change submission state
  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }

  //method to submit user's register data
  void registerUser(String fname, String sname, String email, String pwd, String rPwd) async
  {
    submit(true);

    //check if passwords match, if not then throw alertdialog error
    if (rPwd != pwd){
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("Passwords do not Match!"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context); submit(false);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
      return;
    }

    //create map of register data
    Map map = {"firstName": fname, "secondName": sname, "email": email, "password": pwd};

    var response = await requestManager.register(map);

    //if null, then the request was a success, retrieve the information
    if (response['Success'] != null){
      Map userMap = {"username": email, "password": pwd};

      String userData = json.encode(userMap);
      Navigator.pop(context, userData);

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
}
