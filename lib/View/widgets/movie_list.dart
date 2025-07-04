import 'package:flutter/material.dart';
import 'package:movieapplication/Model/movie_model.dart';
import 'package:movieapplication/View/widgets/movie_poster_card.dart';

// Movie list component for horizontal scrolling
class MovieList extends StatelessWidget {
  final List<Movie> movies;
  final String title;
  final bool showRating;
  final Function(Movie)? onMovieTap;
  final bool isLoading;

  const MovieList({
    Key? key,
    required this.movies,
    required this.title,
    this.showRating = false,
    this.onMovieTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: showRating ? 220 : 200,
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : movies.isEmpty
                  ? const Center(
                    child: Text(
                      'No movies available',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 8),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MoviePosterCard(
                        movie: movie,
                        showRating: showRating,
                        onTap:
                            onMovieTap != null
                                ? () => onMovieTap!(movie)
                                : null,
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
