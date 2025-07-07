import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myflicks/Model/movie_model.dart';
import 'package:myflicks/providers/movie_provider.dart';

class WatchlistSelectionDialog extends StatelessWidget {
  final List<dynamic> watchlists;
  final Movie movie;
  final VoidCallback onCreateNew;
  final Function(String) onSnackBar;

  const WatchlistSelectionDialog({
    Key? key,
    required this.watchlists,
    required this.movie,
    required this.onCreateNew,
    required this.onSnackBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<MovieProvider>();

    return AlertDialog(
      backgroundColor: theme.cardTheme.color,
      title: Text(
        'Add to Watchlist',
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: watchlists.length,
          itemBuilder: (context, index) {
            final watchlist = watchlists[index];
            final isInWatchlist = provider.isMovieInWatchlist(
              watchlist.id,
              movie,
            );

            return ListTile(
              leading: Icon(
                isInWatchlist
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color:
                    isInWatchlist
                        ? Colors.green
                        : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              title: Text(
                watchlist.name,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              subtitle: Text(
                '${watchlist.movieCount} movies',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              onTap: () async {
                if (isInWatchlist) {
                  await provider.removeMovieFromWatchlist(watchlist.id, movie);
                  onSnackBar('Removed from ${watchlist.name}');
                } else {
                  await provider.addMovieToWatchlist(watchlist.id, movie);
                  onSnackBar('Added to ${watchlist.name}');
                }
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onCreateNew();
          },
          child: const Text('Create New List'),
        ),
      ],
    );
  }
}

class CreateWatchlistDialog extends StatefulWidget {
  final Movie movie;
  final Function(String) onSnackBar;

  const CreateWatchlistDialog({
    Key? key,
    required this.movie,
    required this.onSnackBar,
  }) : super(key: key);

  @override
  State<CreateWatchlistDialog> createState() => _CreateWatchlistDialogState();
}

class _CreateWatchlistDialogState extends State<CreateWatchlistDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
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
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Watchlist Name',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
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
          child: Text(
            'Cancel',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.trim().isNotEmpty) {
              final watchlist = await context
                  .read<MovieProvider>()
                  .createCustomWatchlist(
                    _nameController.text.trim(),
                    description: _descriptionController.text.trim(),
                  );
              await context.read<MovieProvider>().addMovieToWatchlist(
                watchlist.id,
                widget.movie,
              );
              Navigator.pop(context);
              widget.onSnackBar('Created "${watchlist.name}" and added movie');
            }
          },
          child: const Text('Create & Add'),
        ),
      ],
    );
  }
}
