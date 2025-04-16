class FileCacheService {
  static final FileCacheService _instance = FileCacheService._internal();

  factory FileCacheService() => _instance;

  FileCacheService._internal();

  List<String> _cachedFiles = [];
  Map<String, String> _cachedContent = {}; // Add this

  List<String> get cachedFiles => _cachedFiles;
  set cachedFiles(List<String> files) => _cachedFiles = files;

  Map<String, String> get cachedContent => _cachedContent;

  void cacheContent(String filename, String content) {
    _cachedContent[filename] = content;
  }

  void clear() {
    _cachedFiles.clear();
    _cachedContent.clear();
  }

  bool get isCached => _cachedFiles.isNotEmpty;
}