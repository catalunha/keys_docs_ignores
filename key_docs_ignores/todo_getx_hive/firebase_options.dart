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
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4gGvCrbD3OwA54j_GaiDcxYYHm_B3LxI',
    appId: '1:598064906974:web:bc3634507b584d0617384f',
    messagingSenderId: '598064906974',
    projectId: 'todo-getx-hive',
    authDomain: 'todo-getx-hive.firebaseapp.com',
    storageBucket: 'todo-getx-hive.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJ6D-BsMLE3f-hx4FgwhZL7xDy8oyYHRw',
    appId: '1:598064906974:web:bc3634507b584d0617384f',
    messagingSenderId: '598064906974',
    projectId: 'todo-getx-hive',
    storageBucket: 'todo-getx-hive.appspot.com',
  );
}
