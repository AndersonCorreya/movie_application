import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/ViewModel/movie_provider.dart';
import 'package:movieapplication/View/widgets/movie_grid.dart';
import 'package:movieapplication/View/movie_detail_page.dart';
import 'package:movieapplication/Model/movie_model.dart';

enum MovieCategory { popular, topRated, upcoming, action, comedy, horror }

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
      case MovieCategory.action:
        provider.fetchAllActionMovies();
        break;
      case MovieCategory.comedy:
        provider.fetchAllComedyMovies();
        break;
      case MovieCategory.horror:
        provider.fetchAllHorrorMovies();
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
      case MovieCategory.action:
        hasMore = provider.hasMoreAction;
        isLoading = provider.isLoadingMoreAction;
        break;
      case MovieCategory.comedy:
        hasMore = provider.hasMoreComedy;
        isLoading = provider.isLoadingMoreComedy;
        break;
      case MovieCategory.horror:
        hasMore = provider.hasMoreHorror;
        isLoading = provider.isLoadingMoreHorror;
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
        case MovieCategory.action:
          provider.loadMoreActionMovies();
          break;
        case MovieCategory.comedy:
          provider.loadMoreComedyMovies();
          break;
        case MovieCategory.horror:
          provider.loadMoreHorrorMovies();
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
      case MovieCategory.action:
        return provider.allActionMovies;
      case MovieCategory.comedy:
        return provider.allComedyMovies;
      case MovieCategory.horror:
        return provider.allHorrorMovies;
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
      case MovieCategory.action:
        return provider.isLoadingMoreAction;
      case MovieCategory.comedy:
        return provider.isLoadingMoreComedy;
      case MovieCategory.horror:
        return provider.isLoadingMoreHorror;
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
      case MovieCategory.action:
        return provider.hasMoreAction;
      case MovieCategory.comedy:
        return provider.hasMoreComedy;
      case MovieCategory.horror:
        return provider.hasMoreHorror;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: theme.colorScheme.onBackground,
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
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            );
          }

          if (movies.isEmpty) {
            return Center(
              child: Text(
                'No movies found',
                style: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                  fontSize: 16,
                ),
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
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              if (!hasMore && movies.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No more movies to load',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
