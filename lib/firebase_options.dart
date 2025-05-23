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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB-iH22CYjNzXKJVbxUM2Utc47wJaVDT3I',
    appId: '1:528635104213:web:e9199ad3229ab0544f0b5c',
    messagingSenderId: '528635104213',
    projectId: 'sportgym2530',
    authDomain: 'sportgym2530.firebaseapp.com',
    databaseURL: 'https://sportgym2530-default-rtdb.firebaseio.com',
    storageBucket: 'sportgym2530.firebasestorage.app',
    measurementId: 'G-X14Q1RWZHK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxP3bo964Qm_TpFTyLgTMu--Sqvb_5MVU',
    appId: '1:528635104213:android:15bf258649d7bba04f0b5c',
    messagingSenderId: '528635104213',
    projectId: 'sportgym2530',
    databaseURL: 'https://sportgym2530-default-rtdb.firebaseio.com',
    storageBucket: 'sportgym2530.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB-iH22CYjNzXKJVbxUM2Utc47wJaVDT3I',
    appId: '1:528635104213:web:e9199ad3229ab0544f0b5c',
    messagingSenderId: '528635104213',
    projectId: 'sportgym2530',
    authDomain: 'sportgym2530.firebaseapp.com',
    databaseURL: 'https://sportgym2530-default-rtdb.firebaseio.com',
    storageBucket: 'sportgym2530.firebasestorage.app',
    measurementId: 'G-X14Q1RWZHK',
  );

}