import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // NOTE: Replace these values with your actual Firebase project settings
  // or run `flutterfire configure` to overwrite with live credentials.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-dXXoovY78F0kcSE9En4aywlW3M7Ag4c',
    appId: '1:942937562811:web:91813d67cc53fe4e04539e',
    messagingSenderId: '942937562811',
    projectId: 'monarch-protocol-b1625',
    authDomain: 'monarch-protocol-b1625.firebaseapp.com',
    storageBucket: 'monarch-protocol-b1625.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-dXXoovY78F0kcSE9En4aywlW3M7Ag4c',
    appId: '1:942937562811:android:91813d67cc53fe4e04539e',
    messagingSenderId: '942937562811',
    projectId: 'monarch-protocol-b1625',
    storageBucket: 'monarch-protocol-b1625.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoMonarchProtocolKeyIOS',
    appId: '1:100000000000:ios:a1b2c3d4e5f6',
    messagingSenderId: '100000000000',
    projectId: 'monarch-protocol',
    storageBucket: 'monarch-protocol.appspot.com',
    iosBundleId: 'com.prem4156.monarchprotocol',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoMonarchProtocolKeyIOS',
    appId: '1:100000000000:ios:a1b2c3d4e5f6',
    messagingSenderId: '100000000000',
    projectId: 'monarch-protocol',
    storageBucket: 'monarch-protocol.appspot.com',
    iosBundleId: 'com.prem4156.monarchprotocol',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoMonarchProtocolKeyWeb',
    appId: '1:100000000000:web:a1b2c3d4e5f6',
    messagingSenderId: '100000000000',
    projectId: 'monarch-protocol',
    authDomain: 'monarch-protocol.firebaseapp.com',
    storageBucket: 'monarch-protocol.appspot.com',
  );
}
