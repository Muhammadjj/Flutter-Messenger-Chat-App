import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:messager/Controller/Routes/routes_method.dart';
import 'package:messager/Export/export_file.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // For settings the DeviceOrientation Portrait Vise and set the
  // DeviceOrientation run this innerCode .
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp])
      .then((value) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Create a notification channel .
    notificationChannelHandle();
    runApp(const MessengerApp());
  });
}

class MessengerApp extends StatelessWidget {
  const MessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messenger App',
      theme: MessengerTheme.messengerTheme(),
      initialRoute: RouteName.splashScreen,
      onGenerateRoute: RouteMethod.onGenerateRoute,
    );
  }
}

void notificationChannelHandle() async {
  // ! Create Notification Channels .
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Firebase Notification',
    id: 'Chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    allowBubbles: true,
    enableVibration: true,
    enableSound: true,
    showBadge: true,
  );
  log('\nNotification Channel Result: $result');
}
