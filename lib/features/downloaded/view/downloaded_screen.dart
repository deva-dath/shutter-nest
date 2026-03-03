import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter_nest/core/providers/downloaded_photos_provider.dart';

class DownloadedPage extends ConsumerWidget {
  const DownloadedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedIds = ref.watch(downloadedPhotosProvider);
    final count = downloadedIds.length;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Downloaded Photos',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              count == 0
                  ? 'No downloaded photos yet'
                  : '$count photo${count == 1 ? '' : 's'} downloaded',
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
