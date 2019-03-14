import 'package:Athena/athena_notification.dart';
import 'package:Athena/request_manager.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Athena/notification_plugin.dart';

void main() {
  runApp(new MyApp());
}

//this is the main class of the Application, it is what runs when the app is launched
class MyApp extends StatelessWidget {
  String name = "";

  // This widget is the root of the application.
  //build runs every time the page is rendered
  @override
  Widget build(BuildContext context) {

    //map of routes to different pages
    var routes = <String, WidgetBuilder> {
      RegisterPage.routeName: (BuildContext context) => new RegisterPage(pageTitle: "Register"),
      LoginPage.routeName: (BuildContext context) => new LoginPage(pageTitle: "Athena"),
      HomePage.routeName: (BuildContext context) => new HomePage(pageTitle: name),
    };

    return new MaterialApp(
      title: 'Athena',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      routes: routes,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid = new AndroidInitializationSettings('white_logo');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    NotificationPlugin notificationPlugin = NotificationPlugin.singleton;
    notificationPlugin.setNotificationPlugin(flutterLocalNotificationsPlugin);

    scheduleNotifications();

    //get user's name from shared preferences, and check if it is null, if so, then send user to log in page, else send user to homepage and pass in the user's name
    SharedPreferences.getInstance().then((SharedPreferences sp)
    {
      if(sp.getString("name") == null) {
        Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
      }
      else{
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage(pageTitle: sp.getString("name"))), (Route<dynamic> route) => false);
      }

      setState(() {});
    });
  }

  void scheduleNotifications() async{
    List<AthenaNotification> notifs = await RequestManager.singleton.getNotifications();

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '01189998819901197253',
        'Athena',
        'Student Life Manager'
    );

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    NotificationDetails platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    notifs.forEach((n) async {
      if(DateTime.parse(n.time).compareTo(DateTime.now()) != -1){
        await flutterLocalNotificationsPlugin.schedule(
            int.tryParse(n.id),
            'You have a notification',
            n.description,
            DateTime.parse(n.time),
            platformChannelSpecifics);
        }
      });
  }

  @override
  Widget build(BuildContext context)
  {
    return new Container();
  }
}
