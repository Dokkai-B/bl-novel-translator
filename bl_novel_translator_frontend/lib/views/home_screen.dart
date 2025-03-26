import 'package:flutter/material.dart';
import 'translate_view.dart';
import 'library_view.dart';
import 'settings_view.dart';

enum AppView {
  translator,
  library,
  settings,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppView currentView = AppView.translator;

  void switchView(AppView view) {
    setState(() {
      currentView = view;
    });
  }

 Widget _buildView() {
  switch (currentView) {
    case AppView.translator:
      return const TranslateView();
    case AppView.library:
      return const LibraryView();
    case AppView.settings:
      return const SettingsView();
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 400,
          height: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: _buildView(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: AppView.values.indexOf(currentView),
        onDestinationSelected: (index) =>
            switchView(AppView.values[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.translate),
            label: 'Translate',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
