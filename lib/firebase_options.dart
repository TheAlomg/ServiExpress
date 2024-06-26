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
    apiKey: 'AIzaSyCXRSRk-VNOUvp5_Nlhda_2dpPj2AONjyw',
    appId: '1:547009348647:web:4349489c360c99ca27fa02',
    messagingSenderId: '547009348647',
    projectId: 'servi-express-271aa',
    authDomain: 'servi-express-271aa.firebaseapp.com',
    storageBucket: 'servi-express-271aa.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCiTy0oSguWIkMdPOEkvpsiXqNY3jYTq4U',
    appId: '1:547009348647:android:7fff04d90fb0171427fa02',
    messagingSenderId: '547009348647',
    projectId: 'servi-express-271aa',
    storageBucket: 'servi-express-271aa.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB91oqCC-wdzDGKFRxrkagPp16zQH2x9ys',
    appId: '1:547009348647:ios:aaeeee18a02f15ec27fa02',
    messagingSenderId: '547009348647',
    projectId: 'servi-express-271aa',
    storageBucket: 'servi-express-271aa.appspot.com',
    iosBundleId: 'com.example.serviExpress',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB91oqCC-wdzDGKFRxrkagPp16zQH2x9ys',
    appId: '1:547009348647:ios:aaeeee18a02f15ec27fa02',
    messagingSenderId: '547009348647',
    projectId: 'servi-express-271aa',
    storageBucket: 'servi-express-271aa.appspot.com',
    iosBundleId: 'com.example.serviExpress',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCXRSRk-VNOUvp5_Nlhda_2dpPj2AONjyw',
    appId: '1:547009348647:web:0fb5e92de4d0474527fa02',
    messagingSenderId: '547009348647',
    projectId: 'servi-express-271aa',
    authDomain: 'servi-express-271aa.firebaseapp.com',
    storageBucket: 'servi-express-271aa.appspot.com',
  );
}
