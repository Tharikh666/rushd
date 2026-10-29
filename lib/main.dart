import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supportsMobileAds = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // Keep platform setup ahead of the first frame, but never block app startup
  // on AdMob/WebView/network initialization.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: RushdApp(),
    ),
  );

  // Initialize ads after the Flutter UI has started. The ad widget also waits
  // for SDK initialization locally before requesting a banner.
  if (supportsMobileAds) {
    unawaited(_initializeMobileAds());
  }
}

Future<void> _initializeMobileAds() async {
  try {
    await MobileAds.instance.initialize();
    debugPrint('RUSHD: Google Mobile Ads initialized.');
  } catch (error, stackTrace) {
    // Ads should never prevent users from opening or using RUSHD.
    debugPrint('RUSHD: Google Mobile Ads initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
