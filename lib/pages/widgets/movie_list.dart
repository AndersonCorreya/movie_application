import 'package:flutter/material.dart';
import 'package:myflicks/Model/movie_model.dart';
import 'package:myflicks/pages/widgets/movie_poster_card.dart';

// Movie list component for horizontal scrolling
class MovieList extends StatelessWidget {
  final List<Movie> movies;
  final String title;
  final bool showRating;
  final Function(Movie)? onMovieTap;
  final bool isLoading;
  final String? heroTagPrefix;

  const MovieList({
    Key? key,
    required this.movies,
    required this.title,
    this.showRating = false,
    this.onMovieTap,
    this.isLoading = false,
    this.heroTagPrefix,
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
          height: showRating ? 240 : 220,
          child:
              movies.isEmpty
                  ? Center(
                    child: Text(
                      'Refresh to load movies',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontFamily: 'WorkSans',
                      ),
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
                        heroTag:
                            heroTagPrefix != null
                                ? '${heroTagPrefix}_movie_poster_${movie.id}'
                                : null,
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
