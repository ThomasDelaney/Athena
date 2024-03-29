import 'package:Athena/utilities/theme_check.dart';
import 'package:flutter/material.dart';
import 'register_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:Athena/utilities/request_manager.dart';

//class to display and handle the log in page
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/LoginPage";
  final String pageTitle;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  RequestManager requestManager = RequestManager.singleton;

  //text editing controllers, used to retrieve the text entered by the user in a text form field
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();

  FocusNode emailFocusNode = new FocusNode();
  FocusNode passwordFocusNode = new FocusNode();
  
  String emailHint = "Email";
  String passHint = "Password";

  bool signingIn = false;
  
  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener((){setState(() {emailHint = "";});});
    passwordFocusNode.addListener((){setState(() {passHint = "";});});
  }
  
  //method to change the text in the email and password input boxes
  void updateText(String newEmail, String newPass)
  {
    setState(() {
      emailController.text = newEmail;
      passwordController.text = newPass;
    });
  }

  @override
  Widget build(BuildContext context){

    //text input field for the user's email
    final email = Theme(
        data: ThemeData(
            highlightColor: Color.fromRGBO(94, 185, 255, 1)
        ),
        child: new TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,

          focusNode: emailFocusNode,

          onFieldSubmitted: (String value) {
            FocusScope.of(context).requestFocus(passwordFocusNode);
          },

          onEditingComplete: () {
            setState(() {
              emailHint = "Email";
            });
          },

          controller: emailController,
          decoration: InputDecoration(
              hintText: emailHint,
              labelText: "Email",
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
              )
          ),
        )
    );

    //text input field for the user's password
    final password = new Theme(
        data: ThemeData(
          highlightColor: Color.fromRGBO(94, 185, 255, 1)
        ),
        child: new TextFormField(
          autofocus: false,
          focusNode: passwordFocusNode,
          controller: passwordController,
          obscureText: true,

          onFieldSubmitted: (String value) {
            FocusScope.of(context).requestFocus(new FocusNode());
          },

          onEditingComplete: () {
            setState(() {
              passHint = "Password";
            });
          },

          decoration: InputDecoration(
              labelText: "Password",
              hintText: passHint,
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero
              )
          ),
        )
    );

    //button to submit the log in details
    final loginButton = ButtonTheme(
        minWidth: MediaQuery.of(context).size.width * 0.95,
        height: 50.0*ThemeCheck.orientatedScaleFactor(context),
        child: new RaisedButton(
          child: new Text("Login", style: new TextStyle(color: Colors.white, fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context))),
          color: ThemeCheck.errorColorOfColor(Color.fromRGBO(94, 185, 255, 1)),
          onPressed: () => signInUser(emailController.text, passwordController.text)
        )
    );

    final newUser = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Text("New User?", style: TextStyle(color: Colors.grey, fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontWeight: FontWeight.bold)),
          Container(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
              child: GestureDetector(
                child: Text("Sign Up!", style: TextStyle(color: ThemeCheck.errorColorOfColor(Color.fromRGBO(94, 185, 255, 1)), fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontWeight: FontWeight.bold)),
                onTap: () => receiveUserData(),
              )
          ),
        ],
    );

    final forgot = Container(alignment: Alignment.centerRight, child: Text("Forgot Password?", style: TextStyle(color: Colors.grey, fontSize: 24.0*ThemeCheck.orientatedScaleFactor(context), fontWeight: FontWeight.bold),));

    //scaffold to encapsulate all the widgets
    return new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            backgroundColor: Color.fromRGBO(94, 185, 255, 1),
            title: new Text(widget.pageTitle),
          ),
          body: new Stack(
            children: <Widget>[
              new Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          child: Image.asset("assets/icon/icon3.png", width: 200*ThemeCheck.orientatedScaleFactor(context), height: 200*ThemeCheck.orientatedScaleFactor(context),),
                        ),
                        SizedBox(height: 75.0*ThemeCheck.orientatedScaleFactor(context)),
                        email,
                        SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
                        password,
                        SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
                        forgot,
                        SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
                        loginButton,
                        SizedBox(height: 30.0*ThemeCheck.orientatedScaleFactor(context)),
                        newUser,
                      ],
                    ),
                  ),
                ),
              ),
              signingIn ? new Container(
                height: MediaQuery.of(context).size.height,
                child: new Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    new Container(
                        child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0, valueColor: AlwaysStoppedAnimation<Color>(ThemeCheck.errorColorOfColor(Color.fromRGBO(94, 185, 255, 1)))))
                  ],
                ),
              )
              : new Container()
            ],
          )
        );
    }

  //route user to register screen and when the user returns, accept the user data from that page, and update the relevant text form fields
  Future<void> receiveUserData() async
  {
    var userInfo = await Navigator.pushNamed(context, RegisterPage.routeName);

    if (userInfo == null) {
      updateText("", "");
    }
    else {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Register Complete!')));
      Map<String, dynamic> userJson = json.decode(userInfo);
      updateText(userJson['username'], userJson['password']);
    }
  }

  //method to submit user's log in data
  void signInUser(String email, String password) async
  {
    setState(() {
      signingIn = true;
    });

    //put the email and password into a map
    Map map = {"email": email, "password": password};

    var response = await requestManager.signInRequest(map);

    //if null, then the request was a success, retrieve the information
    if (response['Success'] != null){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          "name", response['Success']['message']['firstName']
          +" "
          +response['Success']['message']['secondName']
      );

      await prefs.setString("refreshToken", response['Success']['refreshToken']);

      //pop all widgets currently on the stack, and route user to the homepage, and pass in their name
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
        new HomePage(
            pageTitle: response['Success']['message']['firstName']
                +" "+response['Success']['message']['secondName'])
      ), (Route<dynamic> route) => false);
    }
    //else the response ['response']  is not null, then print the error message
    else{

      setState(() {
        signingIn = false;
      });

      //display alertdialog with the returned message
      AlertDialog responseDialog = new AlertDialog(
        content: new Text(
          response['error']['response'],
          style: TextStyle(
            fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context),
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: new Text(
                "OK",
                style: TextStyle(
                    color: Color.fromRGBO(94, 185, 255, 1),
                    fontSize: 18.0*ThemeCheck.orientatedScaleFactor(context),
                    fontWeight: FontWeight.bold
                ),
              )
          )
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
    }
  }
}
