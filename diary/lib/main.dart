import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:phone_state/phone_state.dart';

var kDebugMode = true;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }

  String? token = await messaging.getToken();
  if (kDebugMode) {
    print('Registration Token=$token');
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Handling a foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
    }

    _showNotification(message: message);
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  _listenForIncomingCalls();
  runApp(const MyApp());
}

void _listenForIncomingCalls() {
  PhoneState.stream.listen((event) {
    if (event.status == PhoneStateStatus.CALL_INCOMING) {
      _showNotification(phoneNUmber: event.number);
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) {
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }

  print('Message data: ${message.data}');

  _showNotification(message: message);
}

void _showNotification({RemoteMessage? message, String? phoneNUmber}) {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidInitializationSettings androidSettings =
      const AndroidInitializationSettings('com.example.diary');
  InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  AndroidNotificationDetails androidNotificationDetails =
      const AndroidNotificationDetails('channelId', 'channelName',
          importance: Importance.max, priority: Priority.high);
  NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  if (message != null) {
    flutterLocalNotificationsPlugin.show(
        message.notification?.title.hashCode ?? 0,
        message.notification?.title,
        message.notification?.body,
        notificationDetails);
  } else if (phoneNUmber != null) {
    flutterLocalNotificationsPlugin.show(phoneNUmber.hashCode,
        "calling... $phoneNUmber", "name... $phoneNUmber", notificationDetails);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _lastMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Last message from Firebase Messaging:',
                style: Theme.of(context).textTheme.titleLarge),
            Text(_lastMessage, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
