import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:myflicks/Model/movie_model.dart';
import 'package:myflicks/providers/movie_provider.dart';

class MovieDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isVisible;
  final Movie movie;
  final VoidCallback onBackPressed;
  final VoidCallback onWatchlistAction;

  const MovieDetailAppBar({
    Key? key,
    required this.isVisible,
    required this.movie,
    required this.onBackPressed,
    required this.onWatchlistAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: AnimatedBackButton(
        isVisible: isVisible,
        onPressed: onBackPressed,
      ),
      actions: [
        AnimatedWatchlistButton(
          isVisible: isVisible,
          movie: movie,
          onAction: onWatchlistAction,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AnimatedBackButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onPressed;

  const AnimatedBackButton({
    Key? key,
    required this.isVisible,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class AnimatedWatchlistButton extends StatelessWidget {
  final bool isVisible;
  final Movie movie;
  final VoidCallback onAction;

  const AnimatedWatchlistButton({
    Key? key,
    required this.isVisible,
    required this.movie,
    required this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Consumer<MovieProvider>(
          builder: (context, provider, child) {
            final isInWatchlist = provider.isInDefaultWatchlist(movie);
            return PopupMenuButton<String>(
              icon: Icon(
                isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                color: isInWatchlist ? Colors.amber : Colors.white,
              ),
              onSelected: (value) async {
                HapticFeedback.lightImpact();
                if (value == 'quick_add') {
                  if (isInWatchlist) {
                    await provider.removeFromDefaultWatchlist(movie);
                  } else {
                    await provider.addToDefaultWatchlist(movie);
                  }
                } else if (value == 'add_to_list') {
                  onAction();
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'quick_add',
                      child: Row(
                        children: [
                          Icon(
                            isInWatchlist
                                ? Icons.bookmark_remove
                                : Icons.bookmark_add,
                            color:
                                isInWatchlist
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isInWatchlist
                                  ? 'Remove from Default Watchlist'
                                  : 'Quick Add to Default Watchlist',
                              style: TextStyle(
                                color:
                                    isInWatchlist
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'add_to_list',
                      child: Row(
                        children: [
                          Icon(Icons.playlist_add, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Add to Custom List',
                              style: TextStyle(color: Colors.green),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
            );
          },
        ),
      ),
    );
  }
}
