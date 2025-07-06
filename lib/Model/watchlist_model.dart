import 'package:hive/hive.dart';
import 'package:movieapplication/Model/movie_model.dart';

part 'watchlist_model.g.dart';

@HiveType(typeId: 1)
class Watchlist {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final List<Movie> movies;

  @HiveField(5)
  final bool? isDefault;

  Watchlist({
    required this.id,
    required this.name,
    this.description = '',
    DateTime? createdAt,
    List<Movie>? movies,
    this.isDefault,
  }) : createdAt = createdAt ?? DateTime.now(),
       movies = movies ?? [];

  // Getter to safely check if this is the default watchlist
  bool get isDefaultWatchlist => isDefault ?? false;

  void addMovie(Movie movie) {
    if (!movies.any((m) => m.id == movie.id)) {
      movies.add(movie);
    }
  }

  void removeMovie(Movie movie) {
    movies.removeWhere((m) => m.id == movie.id);
  }

  bool containsMovie(Movie movie) {
    return movies.any((m) => m.id == movie.id);
  }

  int get movieCount => movies.length;
}
