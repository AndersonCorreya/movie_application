import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/ViewModel/movie_provider.dart';
import 'package:movieapplication/View/widgets/movie_grid.dart';
import 'package:movieapplication/View/movie_detail_page.dart';
import 'package:movieapplication/Model/movie_model.dart';

enum MovieCategory { popular, topRated, upcoming }

class SeeAllPage extends StatefulWidget {
  final MovieCategory category;
  final String title;

  const SeeAllPage({Key? key, required this.category, required this.title})
    : super(key: key);

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Defer data loading to after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = context.read<MovieProvider>();
    switch (widget.category) {
      case MovieCategory.popular:
        provider.fetchAllPopularMovies();
        break;
      case MovieCategory.topRated:
        provider.fetchAllTopRatedMovies();
        break;
      case MovieCategory.upcoming:
        provider.fetchAllUpcomingMovies();
        break;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      print('Scroll detected - Loading more data...');
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    final provider = context.read<MovieProvider>();
    bool hasMore = false;
    bool isLoading = false;

    switch (widget.category) {
      case MovieCategory.popular:
        hasMore = provider.hasMorePopular;
        isLoading = provider.isLoadingMorePopular;
        break;
      case MovieCategory.topRated:
        hasMore = provider.hasMoreTopRated;
        isLoading = provider.isLoadingMoreTopRated;
        break;
      case MovieCategory.upcoming:
        hasMore = provider.hasMoreUpcoming;
        isLoading = provider.isLoadingMoreUpcoming;
        break;
    }

    print('LoadMoreData - HasMore: $hasMore, IsLoading: $isLoading');

    if (hasMore && !isLoading) {
      print('Loading more movies for category: ${widget.category}');
      switch (widget.category) {
        case MovieCategory.popular:
          provider.loadMorePopularMovies();
          break;
        case MovieCategory.topRated:
          provider.loadMoreTopRatedMovies();
          break;
        case MovieCategory.upcoming:
          provider.loadMoreUpcomingMovies();
          break;
      }
    } else {
      print('Not loading more - HasMore: $hasMore, IsLoading: $isLoading');
    }
  }

  List<Movie> _getMovies() {
    final provider = context.read<MovieProvider>();
    switch (widget.category) {
      case MovieCategory.popular:
        return provider.allPopularMovies;
      case MovieCategory.topRated:
        return provider.allTopRatedMovies;
      case MovieCategory.upcoming:
        return provider.allUpcomingMovies;
    }
  }

  bool _getIsLoading() {
    final provider = context.read<MovieProvider>();
    switch (widget.category) {
      case MovieCategory.popular:
        return provider.isLoadingMorePopular;
      case MovieCategory.topRated:
        return provider.isLoadingMoreTopRated;
      case MovieCategory.upcoming:
        return provider.isLoadingMoreUpcoming;
    }
  }

  bool _getHasMore() {
    final provider = context.read<MovieProvider>();
    switch (widget.category) {
      case MovieCategory.popular:
        return provider.hasMorePopular;
      case MovieCategory.topRated:
        return provider.hasMoreTopRated;
      case MovieCategory.upcoming:
        return provider.hasMoreUpcoming;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Mulish',
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          final movies = _getMovies();
          final isLoading = _getIsLoading();
          final hasMore = _getHasMore();

          if (movies.isEmpty && isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (movies.isEmpty) {
            return const Center(
              child: Text(
                'No movies found',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadInitialData();
                  },
                  child: MovieGrid(
                    movies: movies,
                    heroTagPrefix: widget.category.name,
                    scrollController: _scrollController,
                    onMovieTap: (movie) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MovieDetailPage(
                                movie: movie,
                                heroTag:
                                    '${widget.category.name}_movie_poster_${movie.id}',
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              if (!hasMore && movies.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'No more movies to load',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
