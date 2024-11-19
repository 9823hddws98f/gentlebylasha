// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALrpeKIpQfSmRDOQfY51Z2tdXb2EDG-FE',
    appId: '1:65622286155:android:f2f757e8ce2c08061e12ce',
    messagingSenderId: '65622286155',
    projectId: 'sleeptales-4bac2',
    storageBucket: 'sleeptales-4bac2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCkLF64zSDE7M1t0f2FHC7vEMmivJNi9UI',
    appId: '1:65622286155:ios:bf201cbfa0c976401e12ce',
    messagingSenderId: '65622286155',
    projectId: 'sleeptales-4bac2',
    storageBucket: 'sleeptales-4bac2.appspot.com',
    androidClientId: '65622286155-6gugiak1h8139igjdi0u8nv55uhvk8ak.apps.googleusercontent.com',
    iosClientId: '65622286155-a01hf6n0hg09n5ovgjglv0vfomeu4qe4.apps.googleusercontent.com',
    iosBundleId: 'io.sleeptales.sleeptales',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCkLF64zSDE7M1t0f2FHC7vEMmivJNi9UI',
    appId: '1:65622286155:ios:bf201cbfa0c976401e12ce',
    messagingSenderId: '65622286155',
    projectId: 'sleeptales-4bac2',
    storageBucket: 'sleeptales-4bac2.appspot.com',
    androidClientId: '65622286155-6gugiak1h8139igjdi0u8nv55uhvk8ak.apps.googleusercontent.com',
    iosClientId: '65622286155-a01hf6n0hg09n5ovgjglv0vfomeu4qe4.apps.googleusercontent.com',
    iosBundleId: 'io.sleeptales.sleeptales',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyArdwqJWklzqJzHKNgcrIcRx9Herhs8Es8',
    appId: '1:65622286155:web:cf2c7cb81edc71f31e12ce',
    messagingSenderId: '65622286155',
    projectId: 'sleeptales-4bac2',
    authDomain: 'sleeptales-4bac2.firebaseapp.com',
    storageBucket: 'sleeptales-4bac2.appspot.com',
    measurementId: 'G-D03JX3LZEJ',
  );

}