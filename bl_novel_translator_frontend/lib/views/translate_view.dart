import 'package:flutter/material.dart';

class TranslateView extends StatefulWidget {
  const TranslateView({super.key});

  @override
  State<TranslateView> createState() => _TranslateViewState();
}

class _TranslateViewState extends State<TranslateView> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;

  void _simulateTranslation() async {
    setState(() {
      _isTranslating = true;
    });

    // Simulate delay (you’ll call GPT-4o here later)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _translatedText = "[Translated]: ${_inputController.text}";
      _isTranslating = false;
    });
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
        ElevatedButton.icon(
          onPressed: _isTranslating ? null : _simulateTranslation,
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('Translate'),
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
