import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

/// Saves a photo from [imageUrl] to the device gallery without compression.
/// Returns null on success, or an error message on failure.
Future<String?> downloadPhotoToGallery(String imageUrl) async {
  try {
    final uri = Uri.parse(imageUrl);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return 'Download failed (${response.statusCode})';
    }
    final bytes = response.bodyBytes;
    if (bytes.isEmpty) {
      return 'Download failed (empty image)';
    }
    await Gal.putImageBytes(bytes);
    return null;
  } on MissingPluginException catch (_) {
    return 'Gallery plugin not linked. Stop the app, run: flutter clean && flutter pub get, then run the app again (full run, not hot reload).';
  } on GalException catch (e) {
    return e.type.message;
  } catch (e) {
    return e.toString();
  }
}
