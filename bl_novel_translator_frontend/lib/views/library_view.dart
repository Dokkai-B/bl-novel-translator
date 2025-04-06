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
  bool _isLoading = true;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    if (!_hasFetched) {
      _fetchFiles();
    }
  }

  Future<void> _fetchFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/files'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _files = data.map((file) => file.toString().replaceFirst('library/', '')).toList();
          _hasFetched = true;
        });
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      setState(() {
        _files = ['Error: $e'];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _previewFile(String filename) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/files/$filename'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(data['filename']),
          content: SingleChildScrollView(
            child: Text(data['content']),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load file content')),
      );
    }
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
              onPressed: _fetchFiles,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const CircularProgressIndicator()
        else
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
    );
  }
}
