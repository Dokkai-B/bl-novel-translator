import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/file_cache_service.dart';


class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  List<String> _files = [];
  bool _isLoading = true;
  bool _hasFetched = false;
  bool _isDialogOpen = false;
  bool _isPreviewing = false;


  @override
  void initState() {
    super.initState();
    final cache = FileCacheService();

    if (cache.isCached && cache.cachedFiles.isNotEmpty) {
      print('[LibraryView] Loaded from cache immediately');
      _files = cache.cachedFiles;
      _isLoading = false;
      _hasFetched = true;
    } else {
      _fetchFiles();
    }
  }

  Future<void> _fetchFiles() async {
    final cache = FileCacheService();
    print('Checking file cache...');

    if (_hasFetched && cache.isCached) {
      print('Loaded files from cache (${cache.cachedFiles.length})');
      setState(() {
        _files = cache.cachedFiles;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    print('Fetching files from backend...');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/files'));
      stopwatch.stop();
      print('API response received in ${stopwatch.elapsedMilliseconds} ms');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final cleaned = data
            .map((file) => file.toString().replaceFirst('library/', ''))
            .toList();

        print('Parsed ${cleaned.length} filenames from server');
        cache.cachedFiles = cleaned;

        // Set state early so UI updates before caching starts
        setState(() {
          _files = cleaned;
          _hasFetched = true;
        });

        // Preload small/medium files (< 10,000 characters)
        print('Starting pre-cache for small/medium files...');
        int cachedCount = 0;
        for (final filename in cleaned) {
          if (cache.cachedContent.containsKey(filename)) continue;

          final url = Uri.parse('http://127.0.0.1:5000/files/$filename');
          try {
            final response = await http.get(url);
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              final content = data['content'] ?? '';
              if (content.length < 10000) {
                cache.cachedContent[filename] = content;
                cachedCount++;
                print('Pre-cached: $filename (${content.length} chars)');
              }
            }
          } catch (e) {
            print('Failed to pre-cache $filename: $e');
          }

          if (cachedCount >= 10) {
            print('Reached pre-cache limit (10 files).');
            break;
          }
        }
      } else {
        throw Exception('Failed to load files: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch error: $e');
      setState(() {
        _files = ['Error: $e'];
      });
    } finally {
      print('Fetch finished');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _previewFile(String filename) async {
    if (_isDialogOpen) return;

    final cache = FileCacheService();
    if (cache.cachedContent.containsKey(filename)) {
      print('Showing cached content for "$filename"');
      return _showDialog(filename, cache.cachedContent[filename]!);
    }

    final url = Uri.parse('http://127.0.0.1:5000/files/$filename');

    try {
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'];

        if (content == null || content.trim().isEmpty) {
          _showSnackBar("No content available for this file.");
          return;
        }

        cache.cacheContent(filename, content); // cache it if not already
        _showDialog(filename, content);
      } else {
        _showSnackBar("Failed to load file: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error loading file: $e");
    }
  }


  Future<void> _showDialog(String title, String content) async {
    _isDialogOpen = true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    _isDialogOpen = false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('[LibraryView] Tab rebuilt');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Translated Files',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                print('Manual refresh triggered');
                FileCacheService().clear();
                _hasFetched = false; // allow refetch
                _fetchFiles();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          Expanded(
            child: Column(
              children: [
                if (_isPreviewing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: CircularProgressIndicator(),
                  ),
                Expanded(
                  child: _files.isEmpty
                      ? const Text('No files found.')
                      : ListView.builder(
                          itemCount: _files.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.description),
                              title: Text(_files[index]),
                              trailing: const Icon(Icons.visibility),
                              onTap: () => _previewFile(_files[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
