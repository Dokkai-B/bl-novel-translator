import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.settings, size: 48),
        SizedBox(height: 16),
        Text('Settings Panel (Coming Soon)'),
      ],
    );
  }
}
