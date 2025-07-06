import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/providers/movie_provider.dart';
import 'package:movieapplication/pages/widgets/movie_grid.dart';
import 'package:movieapplication/pages/movie_detail_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              // Show blank area when no search has been performed
              if (provider.searchResults.isEmpty && !provider.isSearching) {
                return Container(
                  // This creates a blank area that takes up the remaining space
                  color: Colors.transparent,
                );
              }

              // Show loading indicator when searching
              if (provider.isSearching) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                );
              }

              // Show search results or "No movies found" only when there are search results
              return MovieGrid(
                movies: provider.searchResults,
                isLoading: false, // We already handled loading state above
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
}
