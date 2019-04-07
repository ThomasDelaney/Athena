import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//Singleton class to handle notifications
class NotificationPlugin
{
  static final NotificationPlugin singleton = new NotificationPlugin._internal();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  factory NotificationPlugin() {
    return singleton;
  }

  void setNotificationPlugin(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin){
    this._flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;
  }

  get localNotificationPlugin {
    return this._flutterLocalNotificationsPlugin;
  }

  NotificationPlugin._internal();
}