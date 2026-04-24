import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../database/daos/visit_media_dao.dart';

class MediaUploader {
  final VisitMediaDao visitMediaDao;
  final SupabaseClient supabase;

  MediaUploader({
    required this.visitMediaDao,
    required this.supabase,
  });

  Future<void> run() async {
    final pending = await visitMediaDao.getPendingMedia();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    for (final media in pending) {
      try {
        if (media.storagePath == null) {
          await visitMediaDao.markFailed(media.id);
          continue;
        }

        final file = File(media.storagePath!);
        if (!await file.exists()) {
          await visitMediaDao.markFailed(media.id);
          continue;
        }

        final ext = media.contentType.split('/').last;
        final remotePath = '$userId/${media.visitId}/${media.sha256}.$ext';

        await supabase.storage.from('visit-media').upload(
              remotePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );

        await visitMediaDao.markUploaded(media.id, remotePath);
      } catch (e) {
        // Log error but continue with next media
        // Might need a retry policy similar to outbox for temporary network failures
        // For now, if we hit network error, it will retry on next sync run since it remains 'pending'
      }
    }
  }
}
