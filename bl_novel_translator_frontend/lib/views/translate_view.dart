import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslateView extends StatefulWidget {
  @override
  _TranslateViewState createState() => _TranslateViewState();
}

class _TranslateViewState extends State<TranslateView> {
  final urlController = TextEditingController();
  final textController = TextEditingController();
  final filenameController = TextEditingController();

  bool isTranslated = false;
  bool isLoading = false;

  String baseUrl = "http://localhost:5000"; // ✅ Correct for web

  Future<void> fetchChapterFromUrl() async {
    final url = urlController.text.trim();
    if (url.isEmpty) return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
      isTranslated = false;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scrape'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"url": url}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        textController.text = data['chapter'] ?? 'No chapter found.';
        await translateText();
      } else {
        if (!mounted) return;
        showSnack("Failed to fetch chapter.");
      }
    } catch (e) {
      if (!mounted) return;
      showSnack("Error: $e");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> translateText() async {
    final inputText = textController.text.trim();
    if (inputText.isEmpty) return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": inputText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          textController.text = data["translated_text"];
          isTranslated = true;
        });
      } else {
        if (!mounted) return;
        showSnack("Translation failed.");
      }
    } catch (e) {
      if (!mounted) return;
      showSnack("Error: $e");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> saveToS3() async {
    final text = textController.text.trim();
    final filename = filenameController.text.trim();
    if (text.isEmpty || !isTranslated) return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "filename": filename.isNotEmpty ? filename : null,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        showSnack("Saved to S3!");
      } else {
        if (!mounted) return;
        showSnack("Failed to save.");
      }
    } catch (e) {
      if (!mounted) return;
      showSnack("Error: $e");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(20),
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Enter BL Novel Chapter Text", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: "Paste chapter URL here...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: isLoading ? null : fetchChapterFromUrl,
                      child: Text("Fetch from URL"),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: textController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: "Paste text here...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: filenameController,
                      decoration: InputDecoration(
                        hintText: "Optional Filename",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : translateText,
                          icon: Icon(Icons.translate),
                          label: Text("Translate"),
                        ),
                        ElevatedButton.icon(
                          onPressed: (!isTranslated || isLoading) ? null : saveToS3,
                          icon: Icon(Icons.cloud_upload),
                          label: Text("Save to S3"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
