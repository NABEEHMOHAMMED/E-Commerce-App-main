import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase services.
/// This is set up with placeholders to ensure the app compiles immediately.
/// Running `flutterfire configure` will automatically overwrite this file with your actual project keys.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can re-run the flutterfire configure command to configure for other platforms',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can re-run the flutterfire configure command to configure for other platforms',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can re-run the flutterfire configure command to configure for other platforms',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAllQJe5OL6mwXfuRX8PHHVa0AD8GQpWn4',
    appId: '1:574634640749:web:7b154c246036a76a3a4664',
    messagingSenderId: '574634640749',
    projectId: 'e-commerce-app-d84a1',
    authDomain: 'e-commerce-app-d84a1.firebaseapp.com',
    storageBucket: 'e-commerce-app-d84a1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTJ6-IZVhaFvWouapdEKu83ILqg_DCtQU',
    appId: '1:574634640749:android:2eebabfb35918e823a4664',
    messagingSenderId: '574634640749',
    projectId: 'e-commerce-app-d84a1',
    storageBucket: 'e-commerce-app-d84a1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyApiKeyIosPlaceholder12345',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'shopwave-ecommerce-app',
    storageBucket: 'shopwave-ecommerce-app.appspot.com',
    iosBundleId: 'com.example.ecommerceAppWithProvider',
  );
}
