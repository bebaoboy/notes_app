import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/timezone.dart';

void onDidReceiveMainNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
    debugPrint(
        'notification callback: ${NotificationService.notificationCallBackFunction}');
    NotificationService.notificationCallBackFunction!(payload);
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin mainPlugin =
      FlutterLocalNotificationsPlugin();
  static Function? notificationCallBackFunction;

  Future init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {
        title ??= "";
        body ??= "";
        //     showDialog(
        // context: this.context,
        // builder: (BuildContext context) => CupertinoAlertDialog(
        //   title: Text(title!),
        //   content: Text(body!),
        //   actions: [
        //     CupertinoDialogAction(
        //       isDefaultAction: true,
        //       child: Text('Ok'),
        //       onPressed: () async {
        //         Navigator.of(context, rootNavigator: true).pop();
        //         await Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => DetailView(item: Note()),
        //           ),
        //         );
        //       },
        //     )
        //   ],
        // ),
        // );
      },
    );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open your reminder!');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    if (mainPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>() !=
        null) {
      mainPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }
    mainPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveMainNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveMainNotificationResponse,
    );
  }

  Future showNotification(
    callback, {
    required String title,
    required String body,
    required String payload,
  }) async {
    NotificationService.notificationCallBackFunction = callback;
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('1', 'Reminder Details',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            channelAction: AndroidNotificationChannelAction.createIfNotExists);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await mainPlugin.show(int.parse(payload), title, body, notificationDetails,
        payload: payload);
  }

  Future showPersistentNotification(
    callback, {
    required String title,
    required String body,
    required String payload,
  }) async {
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 5000;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    NotificationService.notificationCallBackFunction = callback;
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('1', 'Reminder Details',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            vibrationPattern: vibrationPattern,
            // when: ,
            channelAction: AndroidNotificationChannelAction.createIfNotExists);
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await mainPlugin.show(
        4000, title, body, notificationDetails,
        payload: payload);
  }

  Future showScheduleNotification(
    callback, {
    required String title,
    required String body,
    required String payload,
    TZDateTime? duration,
  }) async {
        NotificationService.notificationCallBackFunction = callback;

    duration ??= tz.TZDateTime.now(tz.local);
    mainPlugin.zonedSchedule(
        int.parse(payload) + 2000,
        title,
        body,
        duration
        // .add(const Duration(seconds: 5))
        ,
        const NotificationDetails(
          android: AndroidNotificationDetails('2', 'Scheduled',
              channelDescription: 'channel description',
              importance: Importance.high,
              priority: Priority.high),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload);
  }
}
