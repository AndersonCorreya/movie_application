import 'package:flutter/material.dart';
import 'package:movieapplication/Model/movie_model.dart';
import 'package:movieapplication/View/widgets/movie_list.dart';

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
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MovieList(
          movies: movies,
          title: '',
          isLoading: isLoading,
          showRating: true,
          onMovieTap: (movie) {
            // Navigate to movie details page
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (context) => MovieDetailPage(movie: movie),
            // ));
          },
        ),
      ],
    );
  }
}
