import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/ViewModel/movie_provider.dart';

import 'package:movieapplication/View/widgets/movie_grid.dart';
import 'package:movieapplication/View/widgets/movie_section.dart';
import 'package:movieapplication/View/movie_detail_page.dart';
import 'package:movieapplication/View/see_all_page.dart';
import 'package:movieapplication/View/watchlist_page.dart';
import 'package:movieapplication/View/settings_page.dart';

// Updated Home Page using Provider
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
        return 'MyFlicks';
      case 1:
        return 'Search';
      case 2:
        return 'Watchlist';
      case 3:
        return 'Settings';
      default:
        return 'MyFlicks';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/icons8-home.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 0
                    ? theme.bottomNavigationBarTheme.selectedItemColor ??
                        Colors.blue
                    : theme.bottomNavigationBarTheme.unselectedItemColor ??
                        Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/icons8-search.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 1
                    ? theme.bottomNavigationBarTheme.selectedItemColor ??
                        Colors.blue
                    : theme.bottomNavigationBarTheme.unselectedItemColor ??
                        Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bookmark_outline,
              size: 22,
              color:
                  _selectedIndex == 2
                      ? theme.bottomNavigationBarTheme.selectedItemColor ??
                          Colors.blue
                      : theme.bottomNavigationBarTheme.unselectedItemColor ??
                          Colors.grey,
            ),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
              color:
                  _selectedIndex == 3
                      ? theme.bottomNavigationBarTheme.selectedItemColor ??
                          Colors.blue
                      : theme.bottomNavigationBarTheme.unselectedItemColor ??
                          Colors.grey,
            ),
            label: 'Settings',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(_getAppBarTitle()),
        titleTextStyle: TextStyle(
          color:
              theme.appBarTheme.titleTextStyle?.color ??
              theme.colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Helvetica',
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          _buildSearchPage(),
          _buildWatchlistPage(),
          _buildProfilePage(),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: () => context.read<MovieProvider>().loadInitialData(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Popular Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSection(
                  title: 'Popular Movies',
                  movies: provider.popularMovies,
                  isLoading: provider.isLoadingPopular,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const SeeAllPage(
                              category: MovieCategory.popular,
                              title: 'Popular Movies',
                            ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            // Top Rated Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSection(
                  title: 'Top Rated',
                  movies: provider.topRatedMovies,
                  isLoading: provider.isLoadingTopRated,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const SeeAllPage(
                              category: MovieCategory.topRated,
                              title: 'Top Rated Movies',
                            ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            // Action Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSection(
                  title: 'Action',
                  movies: provider.actionMovies,
                  isLoading: provider.isLoadingAction,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const SeeAllPage(
                              category: MovieCategory.action,
                              title: 'Action Movies',
                            ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            // Comedy Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSection(
                  title: 'Comedy',
                  movies: provider.comedyMovies,
                  isLoading: provider.isLoadingComedy,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const SeeAllPage(
                              category: MovieCategory.comedy,
                              title: 'Comedy Movies',
                            ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            // Horror Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSection(
                  title: 'Horror',
                  movies: provider.horrorMovies,
                  isLoading: provider.isLoadingHorror,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const SeeAllPage(
                              category: MovieCategory.horror,
                              title: 'Horror Movies',
                            ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            // In Theaters Now Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSection(
                  title: 'In Theaters Now',
                  movies: provider.nowPlayingMovies,
                  isLoading: provider.isLoadingNowPlaying,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const SeeAllPage(
                              category: MovieCategory.nowPlaying,
                              title: 'In Theaters Now',
                            ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            // Upcoming Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSection(
                  title: 'Upcoming',
                  movies: provider.upcomingMovies,
                  isLoading: provider.isLoadingUpcoming,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const SeeAllPage(
                              category: MovieCategory.upcoming,
                              title: 'Upcoming Movies',
                            ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPage() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: TextStyle(color: theme.colorScheme.onBackground),
            decoration: InputDecoration(
              hintText: 'Search movies...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (query) {
              context.read<MovieProvider>().searchMovies(query);
            },
          ),
        ),
        Expanded(
          child: Consumer<MovieProvider>(
            builder: (context, provider, child) {
              return MovieGrid(
                movies: provider.searchResults,
                isLoading: provider.isSearching,
                heroTagPrefix: 'search',
                onMovieTap: (movie) {
                  try {
                    print(
                      'Navigating to movie detail: ${movie.title} (ID: ${movie.id})',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MovieDetailPage(
                              movie: movie,
                              heroTag: 'search_movie_poster_${movie.id}',
                            ),
                      ),
                    );
                  } catch (e) {
                    print('Error navigating to movie detail: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWatchlistPage() {
    return const WatchlistPage();
  }

  Widget _buildProfilePage() {
    return const SettingsPage();
  }
}
