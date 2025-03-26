import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  List<String> _files = [];
  String? _selectedContent;
  bool _isLoading = false;

  final String _baseUrl = 'http://127.0.0.1:5000';

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/files'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _files = data.map((e) => e.toString().replaceFirst('library/', '')).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching files: $e');
    }
  }

  Future<void> _loadFileContent(String filename) async {
    setState(() {
      _isLoading = true;
      _selectedContent = null;
    });

    try {
      final res = await http.get(Uri.parse('$_baseUrl/files/$filename'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _selectedContent = data['content'];
        });
      }
    } catch (e) {
      debugPrint('Error loading file: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('📚 Translated Files',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final filename = _files[index];
              return ListTile(
                title: Text(filename),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _loadFileContent(filename),
              );
            },
          ),
        ),
        const Divider(),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_selectedContent != null)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Text(_selectedContent!),
            ),
          ),
      ],
    );
  }
}
