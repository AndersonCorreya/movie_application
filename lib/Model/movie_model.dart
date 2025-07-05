import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class Movie {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterUrl;

  @HiveField(3)
  final String? backdropUrl;

  @HiveField(4)
  final double? rating;

  @HiveField(5)
  final String? releaseDate;

  @HiveField(6)
  final String? overview;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    this.backdropUrl,
    this.rating,
    this.releaseDate,
    this.overview,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterUrl:
          json['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
              : '',
      backdropUrl:
          json['backdrop_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${json['backdrop_path']}'
              : null,
      rating: json['vote_average']?.toDouble(),
      releaseDate: json['release_date'],
      overview: json['overview'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterUrl.replaceFirst(
        'https://image.tmdb.org/t/p/w500',
        '',
      ),
      'backdrop_path': backdropUrl?.replaceFirst(
        'https://image.tmdb.org/t/p/w500',
        '',
      ),
      'vote_average': rating,
      'release_date': releaseDate,
      'overview': overview,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Movie && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
