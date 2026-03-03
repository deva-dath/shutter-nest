import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current theme mode (light / dark / system). Watch in [MaterialApp].
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
