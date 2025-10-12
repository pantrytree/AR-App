// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      case TargetPlatform.fuchsia:
        throw UnimplementedError();
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7tMkwZS2Cl7RdJqSNUsXbKpGv_6E-eG0',
    appId: '1:755916720907:web:36018a57bc0271ec07f00e',
    messagingSenderId: '755916720907',
    projectId: 'roomantics-8eafd',
    authDomain: 'roomantics-8eafd.firebaseapp.com',
    databaseURL: 'https://roomantics-8eafd-default-rtdb.firebaseio.com',
    storageBucket:  'roomantics-8eafd.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwp6vOxoKuLczllyxJD8Oizqv3P7XoBxI',
    appId: '1:755916720907:android:1cb22d99639ee53d07f00e',
    messagingSenderId: '755916720907',
    projectId: 'roomantics-8eafd',
    storageBucket: 'roomantics-8eafd.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCwp6vOxoKuLczllyxJD8Oizqv3P7XoBxI',
    appId: '1:755916720907:ios:740ebb7bb3ae08bd07f00e',
    messagingSenderId: '755916720907',
    projectId: 'roomantics-8eafd',
    storageBucket: 'roomantics-8eafd.firebasestorage.app',
    iosBundleId: 'com.example.roomantics',
  );
}
