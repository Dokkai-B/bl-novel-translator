import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslateView extends StatefulWidget {
  const TranslateView({super.key});

  @override
  State<TranslateView> createState() => _TranslateViewState();
}

class _TranslateViewState extends State<TranslateView> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _filenameController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;

  Future<void> _translateWithGPT4o() async {
    setState(() {
      _isTranslating = true;
      _translatedText = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': _inputController.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _translatedText = "[Translated]: ${data['translation']}";
        });
      } else {
        setState(() {
          _translatedText = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _translatedText = 'Error: $e';
      });
    }

    setState(() {
      _isTranslating = false;
    });
  }

  Future<void> _saveToS3() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'content': _translatedText,
        'filename': _filenameController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final filename = result['filename'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to S3 as $filename')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save to S3')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Enter BL Novel Chapter Text',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: _inputController,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste text here...',
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _filenameController,
          decoration: InputDecoration(
            labelText: 'Optional Filename',
            hintText: 'e.g., chapter_1_intro.txt',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isTranslating ? null : _translateWithGPT4o,
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('Translate'),
        ),
        ElevatedButton.icon(
          onPressed: _translatedText.isEmpty ? null : _saveToS3,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Save to S3'),
        ),
        const SizedBox(height: 12),
        if (_isTranslating)
          const CircularProgressIndicator()
        else if (_translatedText.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_translatedText),
          ),
      ],
    );
  }
}
