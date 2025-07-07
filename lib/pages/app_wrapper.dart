import 'package:flutter/material.dart';
import 'package:myflicks/pages/onboarding_page.dart';
import 'package:myflicks/pages/home_page.dart';
import 'package:myflicks/services/onboarding_service.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();

    if (mounted) {
      setState(() {
        _hasSeenOnboarding = hasSeenOnboarding;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _hasSeenOnboarding ? const MovieHomePage() : const OnboardingPage();
  }
}
