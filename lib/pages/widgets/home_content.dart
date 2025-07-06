import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/providers/movie_provider.dart';
import 'package:movieapplication/pages/widgets/movie_section_consumer.dart';
import 'package:movieapplication/pages/see_all_page.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<MovieProvider>().loadInitialData(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Popular Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSectionConsumer(
                  title: 'Popular Movies',
                  movies: provider.popularMovies,
                  isLoading: provider.isLoadingPopular,
                  category: MovieCategory.popular,
                );
              },
            ),
            const SizedBox(height: 8),
            // Top Rated Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSectionConsumer(
                  title: 'Top Rated',
                  movies: provider.topRatedMovies,
                  isLoading: provider.isLoadingTopRated,
                  category: MovieCategory.topRated,
                );
              },
            ),
            const SizedBox(height: 8),
            // Action Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSectionConsumer(
                  title: 'Action',
                  movies: provider.actionMovies,
                  isLoading: provider.isLoadingAction,
                  category: MovieCategory.action,
                );
              },
            ),
            const SizedBox(height: 8),
            // Comedy Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSectionConsumer(
                  title: 'Comedy',
                  movies: provider.comedyMovies,
                  isLoading: provider.isLoadingComedy,
                  category: MovieCategory.comedy,
                );
              },
            ),
            const SizedBox(height: 8),
            // Horror Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSectionConsumer(
                  title: 'Horror',
                  movies: provider.horrorMovies,
                  isLoading: provider.isLoadingHorror,
                  category: MovieCategory.horror,
                );
              },
            ),
            const SizedBox(height: 8),
            // In Theaters Now Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSectionConsumer(
                  title: 'In Theaters Now',
                  movies: provider.nowPlayingMovies,
                  isLoading: provider.isLoadingNowPlaying,
                  category: MovieCategory.nowPlaying,
                );
              },
            ),
            const SizedBox(height: 8),
            // Upcoming Movies Section
            Consumer<MovieProvider>(
              builder: (context, provider, child) {
                return MovieSectionConsumer(
                  title: 'Upcoming',
                  movies: provider.upcomingMovies,
                  isLoading: provider.isLoadingUpcoming,
                  category: MovieCategory.upcoming,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
