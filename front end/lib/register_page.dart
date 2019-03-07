import 'package:Athena/theme_check.dart';
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
  Widget build(BuildContext context) {

    //text input field for the user's first name
    final firstName = new Theme(
      data: ThemeData(
          highlightColor: Color.fromRGBO(94, 185, 255, 1)
      ),
      child: new TextFormField(
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
      )
    );

    //text input field for the user's second name
    final secondName = new Theme(
      data: ThemeData(
          highlightColor: Color.fromRGBO(94, 185, 255, 1)
      ),
      child: new TextFormField(
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
      )
    );

    //text input field for the user's email
    final email = new Theme(
      data: ThemeData(
          highlightColor: Color.fromRGBO(94, 185, 255, 1)
      ),
      child: new TextFormField(
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
      )
    );

    //text input field for the user's password name
    final password = new Theme(
      data: ThemeData(
          highlightColor: Color.fromRGBO(94, 185, 255, 1)
      ),
      child: new TextFormField(
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
      )
    );

    //text input field for the user to re-enter their password
    final reEnterPassword = new Theme(
      data: ThemeData(
          highlightColor: Color.fromRGBO(94, 185, 255, 1)
      ),
      child: new TextFormField(
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
      )
    );

    //button which when pressed, will submit the user's inputted data
    final registerButton = ButtonTheme(
        minWidth: MediaQuery.of(context).size.width * 0.95,
        height: 50.0*ThemeCheck.orientatedScaleFactor(context),
        child: new RaisedButton(
            child: new Text("Register", style: new TextStyle(color: Colors.white, fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context))),
            color: ThemeCheck.errorColorOfColor(Color.fromRGBO(94, 185, 255, 1)),
            onPressed: () => registerUser(firstNameController.text, secondNameController.text, emailController.text, passwordController.text, reEnteredPasswordController.text)
        )
    );

    //container which houses all the widgets previously instantiated
    final registerForm = new Container(
      padding: EdgeInsets.only(left: 25.0, right: 25.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
            new Container(
              child: Image.asset("assets/icon/icon3.png", width: 200*ThemeCheck.orientatedScaleFactor(context), height: 200*ThemeCheck.orientatedScaleFactor(context),),
            ),
            SizedBox(height: 75.0*ThemeCheck.orientatedScaleFactor(context)),
            firstName,
            SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
            secondName,
            SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
            email,
            SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
            password,
            SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
            reEnterPassword,
            SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
            registerButton
        ],
      ),
    );

    //a stack widget, which has the registerForm container as a child (this will allow for widgets to be put on-top of the stack(
    final pageStack = new Stack(
      children: <Widget>[
        registerForm,
        submitting ? new Container(
          height: MediaQuery.of(context).size.height,
          child: new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              new Container(
                  child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(ThemeCheck.errorColorOfColor(Color.fromRGBO(94, 185, 255, 1)))))
            ],
          ),
        )
        : new Container(),
      ],
    );

    //scaffold which includes the appbar, and the stack within a centered container
    final page = Scaffold(
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(94, 185, 255, 1),
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
