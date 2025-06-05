import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform tidak dikonfigurasi. Gunakan Android/iOS.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Platform tidak didukung: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIGuXXC3ozaimp00kTQY9RKuxtJ7DVKpU',
    appId: '1:719797557400:android:b60a260e52edc9ffce18ed',
    messagingSenderId: '719797557400',
    projectId: 'reusemart-5c1fc',
    storageBucket: 'reusemart-5c1fc.firebasestorage.app',
  );
}
