import 'package:flutter/material.dart';
import 'package:myflicks/Model/movie_model.dart';
import 'package:myflicks/pages/widgets/movie_poster_card.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final Function(Movie)? onMovieTap;
  final Function(Movie)? onMovieLongPress;
  final bool isLoading;
  final bool showRating;
  final String? heroTagPrefix;
  final ScrollController? scrollController;

  const MovieGrid({
    Key? key,
    required this.movies,
    this.onMovieTap,
    this.onMovieLongPress,
    this.isLoading = false,
    this.showRating = true,
    this.heroTagPrefix,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          'No movies found',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MoviePosterCard(
          movie: movie,
          width: double.infinity,
          height: 200,
          showRating: showRating,
          onTap: onMovieTap != null ? () => onMovieTap!(movie) : null,
          onLongPress:
              onMovieLongPress != null ? () => onMovieLongPress!(movie) : null,
          heroTag:
              heroTagPrefix != null
                  ? '${heroTagPrefix}_movie_poster_${movie.id}'
                  : null,
        );
      },
    );
  }
}
