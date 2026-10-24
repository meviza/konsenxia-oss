// Configure your own isolated Firebase development project before use.
// No production Firebase configuration is distributed with this source export.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Run flutterfire configure against your own development project to generate firebase_options.dart.',
  );
}
