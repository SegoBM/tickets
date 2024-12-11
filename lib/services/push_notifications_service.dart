import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
class PushNotificationService{
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<String> _messageStream = new StreamController.broadcast();
  static Stream<String> get messageStream => _messageStream.stream;

  static Future _backgroundHandler(RemoteMessage message) async{
    print(message.data.toString());
    print('onBackground Handler ${message.messageId}');
    _messageStream.add(message.notification?.title ?? 'No title');
  }
  static Future _onMessageHandler(RemoteMessage message) async{
    print(message.data.toString());
    print('onMessage Handler ${message.messageId}');
    _messageStream.add(message.notification?.title ?? 'No title');
  }
  static Future _onMessageOpenApp(RemoteMessage message) async{
    print(message.data.toString());
    print('onMessageOpenApp Handler ${message.messageId}');
    _messageStream.add(message.notification?.title ?? 'No title');
  }
  static Future initializeApp() async{
    await Firebase.initializeApp();
    token = await FirebaseMessaging.instance.getToken();
    print('Token: $token');

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  }
  static closeStreams(){
    _messageStream.close();
  }
}