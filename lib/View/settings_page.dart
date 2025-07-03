import 'package:flutter/material.dart';
import 'package:movieapplication/core/theme/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Settings'),
      ),
    );
  }
}
