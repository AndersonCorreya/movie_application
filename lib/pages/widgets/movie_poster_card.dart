// Updated MoviePosterCard with Hero animation and navigation

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myflicks/Model/movie_model.dart';
import 'package:myflicks/pages/movie_detail_page.dart';

class MoviePosterCard extends StatelessWidget {
  final Movie movie;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showRating;
  final bool showTitle;
  final String? heroTag;

  const MoviePosterCard({
    Key? key,
    required this.movie,
    this.width = 120,
    this.height = 160,
    this.onTap,
    this.onLongPress,
    this.showRating = false,
    this.showTitle = true,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _navigateToDetail(context),
      onLongPress: onLongPress,
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster image with Hero animation
            Hero(
              tag: heroTag ?? 'movie_poster_${movie.id}',
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      movie.posterUrl.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder:
                                (context, url) => Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.transparent,
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.movie,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  ),
                                ),
                          )
                          : Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                          ),
                ),
              ),
            ),

            if (showTitle || showRating) ...[
              const SizedBox(height: 8),

              // Movie title
              if (showTitle)
                Flexible(
                  child: Text(
                    movie.title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Mulish',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),

              // Rating
              if (showRating && movie.rating != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      movie.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                MovieDetailPage(movie: movie),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
