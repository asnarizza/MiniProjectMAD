import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAR8Xn80y0GUkAflRDsgGzZ5Ju73z-Luy4',
    appId: '1:549540846597:web:181ff033a9668ba502d06c',
    messagingSenderId: '549540846597',
    projectId: 'ws-auth-3c45a',
    authDomain: 'ws-auth-3c45a.firebaseapp.com',
    storageBucket: 'ws-auth-3c45a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMWob4UKda6dTRR4YXliN7O90Y9VFzDdU',
    appId: '1:549540846597:android:ca744dc5d0f869a802d06c',
    messagingSenderId: '549540846597',
    projectId: 'ws-auth-3c45a',
    storageBucket: 'ws-auth-3c45a.appspot.com',
  );
}
