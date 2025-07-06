import 'package:hive_flutter/hive_flutter.dart';
import 'package:movieapplication/Model/movie_model.dart';
import 'package:movieapplication/Model/watchlist_model.dart';

class WatchlistService {
  static const String _watchlistBoxName = 'watchlists';
  static const String _moviesBoxName = 'movies';
  static const String _defaultWatchlistId = 'default_watchlist';

  late Box<Watchlist> _watchlistBox;
  late Box<Movie> _moviesBox;

  static final WatchlistService _instance = WatchlistService._internal();
  factory WatchlistService() => _instance;
  WatchlistService._internal();

  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MovieAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WatchlistAdapter());
    }

    // Open boxes
    _watchlistBox = await Hive.openBox<Watchlist>(_watchlistBoxName);
    _moviesBox = await Hive.openBox<Movie>(_moviesBoxName);

    // Ensure default watchlist exists
    await _ensureDefaultWatchlistExists();
  }

  // Ensure default watchlist exists
  Future<void> _ensureDefaultWatchlistExists() async {
    final defaultWatchlist = _watchlistBox.get(_defaultWatchlistId);
    if (defaultWatchlist == null) {
      final newDefaultWatchlist = Watchlist(
        id: _defaultWatchlistId,
        name: 'My Watchlist',
        description: 'Your default watchlist for quick movie additions',
        isDefault: true,
      );
      await _watchlistBox.put(_defaultWatchlistId, newDefaultWatchlist);
    }
  }

  // Get the default watchlist
  Watchlist? getDefaultWatchlist() {
    return _watchlistBox.get(_defaultWatchlistId);
  }

  // Create a new watchlist
  Future<Watchlist> createWatchlist(
    String name, {
    String description = '',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final watchlist = Watchlist(id: id, name: name, description: description);

    await _watchlistBox.put(id, watchlist);
    return watchlist;
  }

  // Get all watchlists
  List<Watchlist> getAllWatchlists() {
    return _watchlistBox.values.toList();
  }

  // Get all custom watchlists (excluding default)
  List<Watchlist> getCustomWatchlists() {
    return _watchlistBox.values
        .where((watchlist) => !watchlist.isDefaultWatchlist)
        .toList();
  }

  // Get a specific watchlist
  Watchlist? getWatchlist(String id) {
    return _watchlistBox.get(id);
  }

  // Update watchlist
  Future<void> updateWatchlist(Watchlist watchlist) async {
    await _watchlistBox.put(watchlist.id, watchlist);
  }

  // Delete watchlist (cannot delete default watchlist)
  Future<void> deleteWatchlist(String id) async {
    final watchlist = _watchlistBox.get(id);
    if (watchlist != null && !watchlist.isDefaultWatchlist) {
      await _watchlistBox.delete(id);
    }
  }

  // Add movie to watchlist
  Future<void> addMovieToWatchlist(String watchlistId, Movie movie) async {
    final watchlist = _watchlistBox.get(watchlistId);
    if (watchlist != null) {
      watchlist.addMovie(movie);
      await _watchlistBox.put(watchlistId, watchlist);
    }
  }

  // Remove movie from watchlist
  Future<void> removeMovieFromWatchlist(String watchlistId, Movie movie) async {
    final watchlist = _watchlistBox.get(watchlistId);
    if (watchlist != null) {
      watchlist.removeMovie(movie);
      await _watchlistBox.put(watchlistId, watchlist);
    }
  }

  // Check if movie is in watchlist
  bool isMovieInWatchlist(String watchlistId, Movie movie) {
    final watchlist = _watchlistBox.get(watchlistId);
    return watchlist?.containsMovie(movie) ?? false;
  }

  // Get all watchlists containing a specific movie
  List<Watchlist> getWatchlistsContainingMovie(Movie movie) {
    return _watchlistBox.values
        .where((watchlist) => watchlist.containsMovie(movie))
        .toList();
  }

  // Close boxes
  Future<void> close() async {
    await _watchlistBox.close();
    await _moviesBox.close();
  }
}
