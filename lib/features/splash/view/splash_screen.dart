import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/app/app_strings.dart';
import 'package:shutter_nest/app/appcolors.dart';
import 'package:shutter_nest/app/constants/route_constants.dart';
import 'package:shutter_nest/core/providers/router_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  final String _fullText = AppStrings.splashBrandText;
  String _visibleText = "";
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) ref.read(goRouterProvider).go(RouterName.home.path);
    });
  }

  void _startTyping() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_index < _fullText.length) {
        setState(() {
          _visibleText += _fullText[_index];
          _index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [AppColors.brandGreenLight, AppColors.brandGreen],
          ),
        ),
        child: Center(
          child: Text(
            _visibleText,
            style: const TextStyle(
              fontFamily: AppStrings.splashFontFamily,
              fontSize: 45,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: AppColors.onGreen,
            ),
          ),
        ),
      ),
    );
  }
}
