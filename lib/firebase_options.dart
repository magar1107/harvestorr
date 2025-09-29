// Generated manually from provided Firebase config
// For production, prefer using FlutterFire CLI to generate per-platform options.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyCpGHhE-ir8S-DxNPWeQc5KU_vfGIVwigQ',
        appId: '1:436902316402:web:b02d1eff201c76298475eb',
        messagingSenderId: '436902316402',
        projectId: 'harvestorr',
        databaseURL: 'https://harvestorr-default-rtdb.firebaseio.com',
        storageBucket: 'harvestorr.firebasestorage.app',
        measurementId: 'G-Y9JCKTFLR0',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return const FirebaseOptions(
          apiKey: 'AIzaSyCpGHhE-ir8S-DxNPWeQc5KU_vfGIVwigQ',
          appId: '1:436902316402:web:b02d1eff201c76298475eb',
          messagingSenderId: '436902316402',
          projectId: 'harvestorr',
          databaseURL: 'https://harvestorr-default-rtdb.firebaseio.com',
          storageBucket: 'harvestorr.firebasestorage.app',
        );
      default:
        return const FirebaseOptions(
          apiKey: 'AIzaSyCpGHhE-ir8S-DxNPWeQc5KU_vfGIVwigQ',
          appId: '1:436902316402:web:b02d1eff201c76298475eb',
          messagingSenderId: '436902316402',
          projectId: 'harvestorr',
          databaseURL: 'https://harvestorr-default-rtdb.firebaseio.com',
          storageBucket: 'harvestorr.firebasestorage.app',
        );
    }
  }
}
