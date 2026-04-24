import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Centralised image cache manager.
/// §3 – 50 MB in-memory cap, disk cache managed by CachedNetworkImage.
/// §6 – Limit to 50 MB to avoid OOM on 2 GB RAM Android devices.
class ImageCacheManager {
  static const int _maxMemoryCacheMb = 50;

  /// Call once during DEFERRED bootstrap phase.
  static void configure() {
    // Cap Flutter's in-memory image cache at 50 MB (§6)
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        _maxMemoryCacheMb * 1024 * 1024;
    // Also cap item count to avoid holding too many decoded bitmaps
    PaintingBinding.instance.imageCache.maximumSize = 100;
  }

  /// Builds a CachedNetworkImageProvider that uses Supabase Storage
  /// image transformations to load the thumbnail variant (max 300 px).
  /// §3 – Load thumbnails on list, full image on detail.
  static CachedNetworkImageProvider thumbnail(
    String storageUrl, {
    int maxWidth = 300,
  }) {
    final thumbUrl = _addTransformParams(storageUrl, maxWidth);
    return CachedNetworkImageProvider(thumbUrl);
  }

  /// Full-resolution provider (for detail views).
  static CachedNetworkImageProvider full(String storageUrl) {
    return CachedNetworkImageProvider(storageUrl);
  }

  static String _addTransformParams(String url, int width) {
    try {
      final uri = Uri.parse(url);
      // Supabase Storage image transformation URL pattern
      // /storage/v1/object/public/... → /storage/v1/render/image/public/...
      if (uri.path.contains('/storage/v1/object/public/')) {
        final renderPath =
            uri.path.replaceFirst('/storage/v1/object/public/', '/storage/v1/render/image/public/');
        return uri
            .replace(
              path: renderPath,
              queryParameters: {
                ...uri.queryParameters,
                'width': '$width',
                'format': 'webp',
                'quality': '80',
              },
            )
            .toString();
      }
    } catch (e) {
      debugPrint('ImageCacheManager._addTransformParams error: $e');
    }
    return url;
  }

  /// Evict all cached network images (call on memory pressure).
  static void evictAll() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
