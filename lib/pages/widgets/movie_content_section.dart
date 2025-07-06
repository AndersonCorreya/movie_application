import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieapplication/Model/movie_model.dart';
import 'package:movieapplication/Model/cast_model.dart';
import 'package:movieapplication/pages/widgets/youtube_trailer_widget.dart';
import 'package:movieapplication/pages/widgets/movie_poster_card.dart';

class MovieContentSection extends StatelessWidget {
  final Movie movie;
  final List<CastMember> castMembers;
  final bool isLoadingCast;
  final String? trailerVideoId;
  final bool isLoadingTrailer;
  final List<Movie> recommendedMovies;
  final bool isLoadingRecommended;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const MovieContentSection({
    Key? key,
    required this.movie,
    required this.castMembers,
    required this.isLoadingCast,
    this.trailerVideoId,
    required this.isLoadingTrailer,
    required this.recommendedMovies,
    required this.isLoadingRecommended,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CastSection(
                    castMembers: castMembers,
                    isLoading: isLoadingCast,
                  ),
                  const SizedBox(height: 24),
                  MovieInfoSection(movie: movie),
                  const SizedBox(height: 24),
                  OverviewSection(movie: movie),
                  const SizedBox(height: 24),
                  TrailerSection(
                    trailerVideoId: trailerVideoId,
                    isLoading: isLoadingTrailer,
                    movieTitle: movie.title,
                  ),
                  const SizedBox(height: 24),
                  RecommendedMoviesSection(
                    movies: recommendedMovies,
                    isLoading: isLoadingRecommended,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class CastSection extends StatelessWidget {
  final List<CastMember> castMembers;
  final bool isLoading;

  const CastSection({
    Key? key,
    required this.castMembers,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          LoadingWidget(height: 110, theme: theme)
        else if (castMembers.isEmpty)
          EmptyStateWidget(
            height: 110,
            message: 'No cast information available',
            theme: theme,
          )
        else
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: castMembers.length,
              itemBuilder:
                  (context, index) => CastMemberCard(
                    castMember: castMembers[index],
                    theme: theme,
                  ),
            ),
          ),
      ],
    );
  }
}

class CastMemberCard extends StatelessWidget {
  final CastMember castMember;
  final ThemeData theme;

  const CastMemberCard({
    Key? key,
    required this.castMember,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child:
                  castMember.profileUrl.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: castMember.profileUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => PersonPlaceholder(theme: theme),
                        errorWidget:
                            (context, url, error) =>
                                PersonPlaceholder(theme: theme),
                      )
                      : PersonPlaceholder(theme: theme),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            child: Text(
              castMember.name,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PersonPlaceholder extends StatelessWidget {
  final ThemeData theme;

  const PersonPlaceholder({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.cardTheme.color,
      child: Icon(
        Icons.person,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
        size: 30,
      ),
    );
  }
}

class MovieInfoSection extends StatelessWidget {
  final Movie movie;

  const MovieInfoSection({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movie.releaseDate != null) ...[
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Release Date: ${movie.releaseDate}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class OverviewSection extends StatelessWidget {
  final Movie movie;

  const OverviewSection({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          (movie.overview?.isNotEmpty == true)
              ? (movie.overview ?? 'No overview available.')
              : 'No overview available.',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class TrailerSection extends StatelessWidget {
  final String? trailerVideoId;
  final bool isLoading;
  final String movieTitle;

  const TrailerSection({
    Key? key,
    this.trailerVideoId,
    required this.isLoading,
    required this.movieTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trailer',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          LoadingContainer(height: 200, theme: theme)
        else if (trailerVideoId != null)
          YouTubeTrailerWidget(videoId: trailerVideoId!, movieTitle: movieTitle)
        else
          EmptyStateContainer(
            height: 200,
            icon: Icons.video_library,
            message: 'No trailer available',
            theme: theme,
          ),
      ],
    );
  }
}

class RecommendedMoviesSection extends StatelessWidget {
  final List<Movie> movies;
  final bool isLoading;

  const RecommendedMoviesSection({
    Key? key,
    required this.movies,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Movies',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          LoadingWidget(height: 240, theme: theme)
        else if (movies.isEmpty)
          EmptyStateContainer(
            height: 240,
            icon: Icons.movie_outlined,
            message: 'No recommendations available',
            theme: theme,
          )
        else
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              itemBuilder:
                  (context, index) => MoviePosterCard(
                    movie: movies[index],
                    width: 120,
                    height: 160,
                    showRating: false,
                    showTitle: true,
                    heroTag: 'recommended_${movies[index].id}',
                  ),
            ),
          ),
      ],
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final double height;
  final ThemeData theme;

  const LoadingWidget({Key? key, required this.height, required this.theme})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class LoadingContainer extends StatelessWidget {
  final double height;
  final ThemeData theme;

  const LoadingContainer({Key? key, required this.height, required this.theme})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final double height;
  final String message;
  final ThemeData theme;

  const EmptyStateWidget({
    Key? key,
    required this.height,
    required this.message,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class EmptyStateContainer extends StatelessWidget {
  final double height;
  final IconData icon;
  final String message;
  final ThemeData theme;

  const EmptyStateContainer({
    Key? key,
    required this.height,
    required this.icon,
    required this.message,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
