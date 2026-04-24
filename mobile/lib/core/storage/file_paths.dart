class FilePaths {
  static String getMediaStoragePath(String visitId, String mediaId) {
    return 'visits/$visitId/media/$mediaId';
  }
}
