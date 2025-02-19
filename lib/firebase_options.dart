// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBvllICsvdECQUE0gep9oikBQl8kepIcg',
    appId: '1:878025025807:web:272b54ceafcb3ae54bf67a',
    messagingSenderId: '878025025807',
    projectId: 'fullerp-d5679',
    authDomain: 'fullerp-d5679.firebaseapp.com',
    storageBucket: 'fullerp-d5679.appspot.com',
    measurementId: 'G-VH2QP19S8G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjDsvjE534UHVAjKnFCucnfvt50os1TtE',
    appId: '1:878025025807:android:b7f529d10d26ecb04bf67a',
    messagingSenderId: '878025025807',
    projectId: 'fullerp-d5679',
    storageBucket: 'fullerp-d5679.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWc4Tulka5LuGdx758hRLqx9meoYYxZkU',
    appId: '1:878025025807:ios:1f59641fe2a447b84bf67a',
    messagingSenderId: '878025025807',
    projectId: 'fullerp-d5679',
    storageBucket: 'fullerp-d5679.appspot.com',
    iosBundleId: 'com.example.fullerp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWc4Tulka5LuGdx758hRLqx9meoYYxZkU',
    appId: '1:878025025807:ios:1f59641fe2a447b84bf67a',
    messagingSenderId: '878025025807',
    projectId: 'fullerp-d5679',
    storageBucket: 'fullerp-d5679.appspot.com',
    iosBundleId: 'com.example.fullerp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCBvllICsvdECQUE0gep9oikBQl8kepIcg',
    appId: '1:878025025807:web:9041c05ed06fb5364bf67a',
    messagingSenderId: '878025025807',
    projectId: 'fullerp-d5679',
    authDomain: 'fullerp-d5679.firebaseapp.com',
    storageBucket: 'fullerp-d5679.appspot.com',
    measurementId: 'G-W4FJF6J6QG',
  );
}
