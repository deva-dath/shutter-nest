import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/core/providers/liked_photos_provider.dart';

class LikedPage extends ConsumerWidget {
  const LikedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(likedPhotosProvider);
    final count = likedIds.length;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Liked Photos',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              count == 0
                  ? 'No liked photos yet'
                  : '$count photo${count == 1 ? '' : 's'} liked',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
