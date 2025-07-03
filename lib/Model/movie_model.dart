import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Movie model for better data structure
class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String? backdropUrl;
  final double? rating;
  final String? releaseDate;
  final String? overview;

  const Movie({
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
}
