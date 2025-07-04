import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movieapplication/core/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/ViewModel/movie_provider.dart';

import 'package:movieapplication/View/widgets/movie_grid.dart';
import 'package:movieapplication/View/widgets/movie_section.dart';
import 'package:movieapplication/View/movie_detail_page.dart';
import 'package:movieapplication/View/see_all_page.dart';
import 'package:movieapplication/View/watchlist_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
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
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
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
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
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
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
            ),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('MyFlicks'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'WorkSans',
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search movies...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
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
    return const Center(
      child: Text(
        'Profile Page',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
