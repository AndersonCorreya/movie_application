import 'package:flutter/material.dart';
import 'package:movieapplication/Model/movie_model.dart';
import 'package:movieapplication/View/widgets/movie_list.dart';
import 'package:movieapplication/View/movie_detail_page.dart';

// Example usage in your home page
class MovieSection extends StatelessWidget {
  final List<Movie> movies;
  final String title;
  final bool isLoading;
  final VoidCallback? onSeeAll;

  const MovieSection({
    Key? key,
    required this.movies,
    required this.title,
    this.isLoading = false,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.blue, fontFamily: 'Mulish'),
                  ),
                ),
            ],
          ),
        ),

        MovieList(
          movies: movies,
          title: '',
          isLoading: isLoading,
          showRating: false,
          heroTagPrefix: title.toLowerCase().replaceAll(' ', '_'),
          onMovieTap: (movie) {
            // Navigate to movie details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MovieDetailPage(
                      movie: movie,
                      heroTag:
                          '${title.toLowerCase().replaceAll(' ', '_')}_movie_poster_${movie.id}',
                    ),
              ),
            );
          },
        ),
      ],
    );
  }
}
