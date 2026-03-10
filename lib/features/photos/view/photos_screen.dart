import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/app/app_strings.dart';

class PhotosPage extends ConsumerWidget {
  const PhotosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Text(
          AppStrings.titlePhotos,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
