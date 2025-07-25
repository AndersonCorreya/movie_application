import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myflicks/providers/movie_provider.dart';
import 'package:myflicks/Model/watchlist_model.dart';
import 'package:myflicks/Model/movie_model.dart';
import 'package:myflicks/pages/widgets/movie_grid.dart';
import 'package:myflicks/pages/movie_detail_page.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({Key? key}) : super(key: key);

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCreateWatchlistDialog() {
    _nameController.clear();
    _descriptionController.clear();

    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(
              'Create New Watchlist',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Watchlist Name',
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isNotEmpty) {
                    context.read<MovieProvider>().createCustomWatchlist(
                      _nameController.text.trim(),
                      description: _descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showEditWatchlistDialog(Watchlist watchlist) {
    // Prevent editing the default watchlist
    if (watchlist.isDefaultWatchlist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The default watchlist cannot be edited'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _nameController.text = watchlist.name;
    _descriptionController.text = watchlist.description;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C2128),
            title: const Text(
              'Edit Watchlist',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Watchlist Name',
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isNotEmpty) {
                    context.read<MovieProvider>().updateCustomWatchlist(
                      watchlist.id,
                      _nameController.text.trim(),
                      description: _descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(Watchlist watchlist) {
    if (watchlist.isDefaultWatchlist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The default watchlist cannot be deleted'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C2128),
            title: const Text(
              'Delete Watchlist',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to delete "${watchlist.name}"? This action cannot be undone.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<MovieProvider>().deleteCustomWatchlist(
                    watchlist.id,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showWatchlistOptions(Watchlist watchlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2128),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                if (!watchlist
                    .isDefaultWatchlist) // Only show edit option for non-default watchlists
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text(
                      'Edit Watchlist',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditWatchlistDialog(watchlist);
                    },
                  ),
                if (!watchlist
                    .isDefaultWatchlist) // Only show delete option for non-default watchlists
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete Watchlist',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(watchlist);
                    },
                  ),
                if (watchlist
                    .isDefaultWatchlist) // Show message for default watchlist
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: const Text(
                      'Default watchlist cannot be edited',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Your Watchlists',
          style: TextStyle(fontFamily: 'Mulish', fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateWatchlistDialog,
            tooltip: 'Create New Watchlist',
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final defaultWatchlist = provider.getDefaultWatchlist();
          final customWatchlists = provider.getCustomWatchlistsOnly();

          if (defaultWatchlist == null && customWatchlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No watchlists yet',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first watchlist to organize your favorite movies',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showCreateWatchlistDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Watchlist'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                (defaultWatchlist != null ? 1 : 0) + customWatchlists.length,
            itemBuilder: (context, index) {
              Watchlist watchlist;
              bool isDefault = false;

              if (index == 0 && defaultWatchlist != null) {
                watchlist = defaultWatchlist;
                isDefault = true;
              } else {
                final customIndex =
                    defaultWatchlist != null ? index - 1 : index;
                watchlist = customWatchlists[customIndex];
                isDefault = false;
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                WatchlistDetailPage(watchlist: watchlist),
                      ),
                    );
                  },
                  onLongPress:
                      isDefault ? null : () => _showWatchlistOptions(watchlist),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Watchlist icon - shows first movie poster if available, otherwise shows bookmark icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color:
                                watchlist.movies.isNotEmpty
                                    ? Colors.transparent
                                    : Colors.blue.withValues(alpha: 0.2),
                          ),
                          child:
                              watchlist.movies.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      watchlist.movies.first.posterUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.blue,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.bookmark,
                                            color: Colors.blue,
                                            size: 28,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  : const Icon(
                                    Icons.bookmark,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    watchlist.name,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.color,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        'Default',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (watchlist.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  watchlist.description,
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.color,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '${watchlist.movieCount} movie${watchlist.movieCount != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.color,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isDefault) // Only show popup menu for non-default watchlists
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: theme.colorScheme.onSurface,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditWatchlistDialog(watchlist);
                              } else if (value == 'delete') {
                                _showDeleteConfirmation(watchlist);
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WatchlistDetailPage extends StatelessWidget {
  final Watchlist watchlist;

  const WatchlistDetailPage({Key? key, required this.watchlist})
    : super(key: key);

  void _showRemoveMovieDialog(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C2128),
            title: const Text(
              'Remove Movie',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to remove "${movie.title}" from this watchlist?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await context.read<MovieProvider>().removeMovieFromWatchlist(
                    watchlist.id,
                    movie,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Remove',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(watchlist.name, style: TextStyle(fontFamily: 'Mulish')),
        actions: [
          if (!watchlist
              .isDefaultWatchlist) // Only show delete option for non-default watchlists
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete') {
                  context.read<MovieProvider>().deleteCustomWatchlist(
                    watchlist.id,
                  );
                  Navigator.pop(context);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete Watchlist',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          // Get the updated watchlist from the provider
          final updatedWatchlist =
              provider.getDefaultWatchlist()?.id == watchlist.id
                  ? provider.getDefaultWatchlist()
                  : provider.customWatchlists.firstWhere(
                    (w) => w.id == watchlist.id,
                    orElse: () => watchlist,
                  );

          final currentWatchlist = updatedWatchlist ?? watchlist;

          return currentWatchlist.movies.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_outlined,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No movies in this watchlist',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add movies from the movie details page',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : MovieGrid(
                movies: currentWatchlist.movies,
                heroTagPrefix: 'watchlist_${currentWatchlist.id}',
                onMovieTap: (movie) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MovieDetailPage(
                            movie: movie,
                            heroTag:
                                'watchlist_${currentWatchlist.id}_movie_poster_${movie.id}',
                          ),
                    ),
                  );
                },
                onMovieLongPress:
                    (movie) => _showRemoveMovieDialog(context, movie),
              );
        },
      ),
    );
  }
}
