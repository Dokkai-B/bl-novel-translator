class FileCacheService {
  static final FileCacheService _instance = FileCacheService._internal();

  List<String>? _cachedFiles;

  FileCacheService._internal();

  factory FileCacheService() => _instance;

  bool get isCached => _cachedFiles != null;

  List<String> get cachedFiles => _cachedFiles ?? [];

  set cachedFiles(List<String> files) {
    _cachedFiles = files;
  }

  void clear() {
    _cachedFiles = null;
  }
}
