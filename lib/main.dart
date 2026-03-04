import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shutter_nest/config/theme/app_theme.dart';
import 'package:shutter_nest/core/providers/router_provider.dart';
import 'package:shutter_nest/core/providers/theme_mode_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use FFI only on desktop. On iOS/Android use native sqflite so the DB path
  // is correct in the app sandbox (FFI fails to open the file on iOS).
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      child: ShutterNestApp(),
    ),
  );
}

class ShutterNestApp extends ConsumerWidget {
  const ShutterNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ShutterNest',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => GlassTheme(
        data: AppTheme.defaultGlass,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
