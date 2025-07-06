import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/providers/movie_provider.dart';
import 'package:movieapplication/pages/widgets/custom_bottom_navigation.dart';
import 'package:movieapplication/pages/widgets/custom_app_bar.dart';
import 'package:movieapplication/pages/widgets/home_content.dart';
import 'package:movieapplication/pages/widgets/search_page.dart';
import 'package:movieapplication/pages/watchlist_page.dart';
import 'package:movieapplication/pages/settings_page.dart';

// Refactored Home Page using segregated widgets
class MovieHomePage extends StatefulWidget {
  const MovieHomePage({Key? key}) : super(key: key);

  @override
  State<MovieHomePage> createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data when the page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadInitialData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'MYFLICKS';
      case 1:
        return 'Search';
      case 2:
        return 'MYFLICKS';
      case 3:
        return 'Settings';
      default:
        return 'MYFLICKS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      appBar: CustomAppBar(title: _getAppBarTitle()),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeContent(),
          const SearchPage(),
          const WatchlistPage(),
          const SettingsPage(),
        ],
      ),
    );
  }
}
