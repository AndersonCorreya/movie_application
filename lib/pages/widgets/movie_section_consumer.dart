import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/providers/movie_provider.dart';
import 'package:movieapplication/pages/widgets/movie_section.dart';
import 'package:movieapplication/pages/see_all_page.dart';
import 'package:movieapplication/Model/movie_model.dart';

class MovieSectionConsumer extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool isLoading;
  final MovieCategory category;

  const MovieSectionConsumer({
    Key? key,
    required this.title,
    required this.movies,
    required this.isLoading,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        return MovieSection(
          title: title,
          movies: movies,
          isLoading: isLoading,
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SeeAllPage(category: category, title: title),
              ),
            );
          },
        );
      },
    );
  }
}
