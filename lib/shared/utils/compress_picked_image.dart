import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Shrinks a picker-sourced photo before it's uploaded. Falls back to the
/// original path on any failure (unsupported format, a device codec quirk)
/// — compression may only make an upload smaller, never block it.
Future<String> compressPickedImage(String sourcePath) async {
  try {
    final compressed = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      '$sourcePath-compressed.jpg',
      quality: 80,
      minWidth: 1600,
      minHeight: 1600,
    );
    return compressed?.path ?? sourcePath;
  } catch (_) {
    return sourcePath;
  }
}
