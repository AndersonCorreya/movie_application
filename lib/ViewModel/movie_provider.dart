import 'package:flutter/material.dart';
import 'package:movieapplication/Model/movie_model.dart';
import 'package:movieapplication/Model/cast_model.dart';
import 'package:movieapplication/Model/watchlist_model.dart';
import 'package:movieapplication/services/watchlist_service.dart';
import 'package:movieapplication/config/secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Movie Provider for state management
class MovieProvider extends ChangeNotifier {
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _upcomingMovies = [];
  List<Movie> _actionMovies = [];
  List<Movie> _comedyMovies = [];
  List<Movie> _horrorMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _watchlist = [];
  List<Watchlist> _customWatchlists = [];
  Map<int, List<CastMember>> _movieCast = {};
  Map<int, String?> _movieTrailers = {};

  // Pagination support for "See All" pages
  List<Movie> _allPopularMovies = [];
  List<Movie> _allTopRatedMovies = [];
  List<Movie> _allUpcomingMovies = [];
  List<Movie> _allActionMovies = [];
  List<Movie> _allComedyMovies = [];
  List<Movie> _allHorrorMovies = [];

  bool _isLoadingPopular = false;
  bool _isLoadingTopRated = false;
  bool _isLoadingUpcoming = false;
  bool _isLoadingAction = false;
  bool _isLoadingComedy = false;
  bool _isLoadingHorror = false;
  bool _isSearching = false;
  bool _isLoadingMorePopular = false;
  bool _isLoadingMoreTopRated = false;
  bool _isLoadingMoreUpcoming = false;
  bool _isLoadingMoreAction = false;
  bool _isLoadingMoreComedy = false;
  bool _isLoadingMoreHorror = false;

  String _errorMessage = '';

  // Pagination state
  int _popularPage = 1;
  int _topRatedPage = 1;
  int _upcomingPage = 1;
  int _actionPage = 1;
  int _comedyPage = 1;
  int _horrorPage = 1;
  bool _hasMorePopular = true;
  bool _hasMoreTopRated = true;
  bool _hasMoreUpcoming = true;
  bool _hasMoreAction = true;
  bool _hasMoreComedy = true;
  bool _hasMoreHorror = true;

  // Debouncer for search
  Timer? _searchDebouncer;

  // Watchlist service
  final WatchlistService _watchlistService = WatchlistService();

  // Getters
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Movie> get actionMovies => _actionMovies;
  List<Movie> get comedyMovies => _comedyMovies;
  List<Movie> get horrorMovies => _horrorMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get watchlist => _watchlist;
  List<Watchlist> get customWatchlists => _customWatchlists;
  Map<int, List<CastMember>> get movieCast => _movieCast;
  Map<int, String?> get movieTrailers => _movieTrailers;

  // "See All" page getters
  List<Movie> get allPopularMovies => _allPopularMovies;
  List<Movie> get allTopRatedMovies => _allTopRatedMovies;
  List<Movie> get allUpcomingMovies => _allUpcomingMovies;
  List<Movie> get allActionMovies => _allActionMovies;
  List<Movie> get allComedyMovies => _allComedyMovies;
  List<Movie> get allHorrorMovies => _allHorrorMovies;

  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingTopRated => _isLoadingTopRated;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isLoadingAction => _isLoadingAction;
  bool get isLoadingComedy => _isLoadingComedy;
  bool get isLoadingHorror => _isLoadingHorror;
  bool get isSearching => _isSearching;
  bool get isLoadingMorePopular => _isLoadingMorePopular;
  bool get isLoadingMoreTopRated => _isLoadingMoreTopRated;
  bool get isLoadingMoreUpcoming => _isLoadingMoreUpcoming;
  bool get isLoadingMoreAction => _isLoadingMoreAction;
  bool get isLoadingMoreComedy => _isLoadingMoreComedy;
  bool get isLoadingMoreHorror => _isLoadingMoreHorror;

  String get errorMessage => _errorMessage;

  // Pagination getters
  bool get hasMorePopular => _hasMorePopular;
  bool get hasMoreTopRated => _hasMoreTopRated;
  bool get hasMoreUpcoming => _hasMoreUpcoming;
  bool get hasMoreAction => _hasMoreAction;
  bool get hasMoreComedy => _hasMoreComedy;
  bool get hasMoreHorror => _hasMoreHorror;

  // API configuration from secrets
  final String _apiKey = Secrets.movieApiKey;
  final String _baseUrl = Secrets.movieBaseUrl;

  // Initialize watchlist service
  Future<void> initializeWatchlistService() async {
    await _watchlistService.initialize();
    await loadCustomWatchlists();
  }

  // Load custom watchlists from storage
  Future<void> loadCustomWatchlists() async {
    // Only include non-default watchlists
    _customWatchlists = _watchlistService.getCustomWatchlists();
    notifyListeners();
  }

  // Get the default watchlist
  Watchlist? getDefaultWatchlist() {
    return _watchlistService.getDefaultWatchlist();
  }

  // Get all custom watchlists (excluding default)
  List<Watchlist> getCustomWatchlistsOnly() {
    return _watchlistService.getCustomWatchlists();
  }

  // Create a new custom watchlist
  Future<Watchlist> createCustomWatchlist(
    String name, {
    String description = '',
  }) async {
    final watchlist = await _watchlistService.createWatchlist(
      name,
      description: description,
    );
    _customWatchlists.add(watchlist);
    notifyListeners();
    return watchlist;
  }

  // Delete a custom watchlist
  Future<void> deleteCustomWatchlist(String id) async {
    await _watchlistService.deleteWatchlist(id);
    _customWatchlists.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  // Update a custom watchlist
  Future<void> updateCustomWatchlist(
    String id,
    String name, {
    String description = '',
  }) async {
    // Prevent updating the default watchlist
    final defaultWatchlist = getDefaultWatchlist();
    if (defaultWatchlist != null && defaultWatchlist.id == id) {
      throw Exception('Cannot update the default watchlist');
    }

    final watchlist = _customWatchlists.firstWhere((w) => w.id == id);
    final updatedWatchlist = Watchlist(
      id: id,
      name: name,
      description: description,
      movies: watchlist.movies,
    );

    await _watchlistService.updateWatchlist(updatedWatchlist);
    final index = _customWatchlists.indexWhere((w) => w.id == id);
    if (index != -1) {
      _customWatchlists[index] = updatedWatchlist;
      notifyListeners();
    }
  }

  // Add movie to a specific watchlist
  Future<void> addMovieToWatchlist(String watchlistId, Movie movie) async {
    await _watchlistService.addMovieToWatchlist(watchlistId, movie);
    await loadCustomWatchlists(); // Reload to get updated data
  }

  // Remove movie from a specific watchlist
  Future<void> removeMovieFromWatchlist(String watchlistId, Movie movie) async {
    await _watchlistService.removeMovieFromWatchlist(watchlistId, movie);
    await loadCustomWatchlists(); // Reload to get updated data
  }

  // Check if movie is in a specific watchlist
  bool isMovieInWatchlist(String watchlistId, Movie movie) {
    return _watchlistService.isMovieInWatchlist(watchlistId, movie);
  }

  // Get all watchlists containing a specific movie
  List<Watchlist> getWatchlistsContainingMovie(Movie movie) {
    return _watchlistService.getWatchlistsContainingMovie(movie);
  }

  // Legacy watchlist methods (for backward compatibility)
  void addToWatchlist(Movie movie) {
    if (!_watchlist.any((m) => m.id == movie.id)) {
      _watchlist.add(movie);
      notifyListeners();
    }
  }

  void removeFromWatchlist(Movie movie) {
    _watchlist.removeWhere((m) => m.id == movie.id);
    notifyListeners();
  }

  bool isInWatchlist(Movie movie) {
    return _watchlist.any((m) => m.id == movie.id);
  }

  // Default watchlist methods
  Future<void> addToDefaultWatchlist(Movie movie) async {
    final defaultWatchlist = getDefaultWatchlist();
    if (defaultWatchlist != null) {
      await addMovieToWatchlist(defaultWatchlist.id, movie);
    }
  }

  Future<void> removeFromDefaultWatchlist(Movie movie) async {
    final defaultWatchlist = getDefaultWatchlist();
    if (defaultWatchlist != null) {
      await removeMovieFromWatchlist(defaultWatchlist.id, movie);
    }
  }

  bool isInDefaultWatchlist(Movie movie) {
    final defaultWatchlist = getDefaultWatchlist();
    if (defaultWatchlist != null) {
      return isMovieInWatchlist(defaultWatchlist.id, movie);
    }
    return false;
  }

  // Fetch popular movies (initial load - first page only)
  Future<void> fetchPopularMovies() async {
    _isLoadingPopular = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&page=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _popularMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
        _popularPage = 1;
        _hasMorePopular = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load popular movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingPopular = false;
    notifyListeners();
  }

  // Fetch all popular movies for "See All" page
  Future<void> fetchAllPopularMovies() async {
    _allPopularMovies = [];
    _popularPage = 1;
    _hasMorePopular = true;
    await _loadMorePopularMovies();
  }

  // Load more popular movies (pagination)
  Future<void> _loadMorePopularMovies() async {
    if (!_hasMorePopular || _isLoadingMorePopular) return;

    print('Loading popular movies page $_popularPage');
    _isLoadingMorePopular = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/popular?api_key=$_apiKey&page=$_popularPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();

        print(
          'Loaded ${newMovies.length} new popular movies. Page: ${data['page']}, Total Pages: ${data['total_pages']}',
        );

        _allPopularMovies.addAll(newMovies);
        _popularPage++;
        _hasMorePopular = data['page'] < data['total_pages'];

        print(
          'Total popular movies: ${_allPopularMovies.length}, HasMore: $_hasMorePopular',
        );
      } else {
        _errorMessage = 'Failed to load more popular movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingMorePopular = false;
    notifyListeners();
  }

  // Public method to load more popular movies
  Future<void> loadMorePopularMovies() async {
    await _loadMorePopularMovies();
  }

  // Fetch top rated movies (initial load - first page only)
  Future<void> fetchTopRatedMovies() async {
    _isLoadingTopRated = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&page=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _topRatedMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
        _topRatedPage = 1;
        _hasMoreTopRated = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load top rated movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingTopRated = false;
    notifyListeners();
  }

  // Fetch all top rated movies for "See All" page
  Future<void> fetchAllTopRatedMovies() async {
    _allTopRatedMovies = [];
    _topRatedPage = 1;
    _hasMoreTopRated = true;
    await _loadMoreTopRatedMovies();
  }

  // Load more top rated movies (pagination)
  Future<void> _loadMoreTopRatedMovies() async {
    if (!_hasMoreTopRated || _isLoadingMoreTopRated) return;

    _isLoadingMoreTopRated = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/top_rated?api_key=$_apiKey&page=$_topRatedPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();

        _allTopRatedMovies.addAll(newMovies);
        _topRatedPage++;
        _hasMoreTopRated = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load more top rated movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingMoreTopRated = false;
    notifyListeners();
  }

  // Public method to load more top rated movies
  Future<void> loadMoreTopRatedMovies() async {
    await _loadMoreTopRatedMovies();
  }

  // Fetch upcoming movies (initial load - first page only)
  Future<void> fetchUpcomingMovies() async {
    _isLoadingUpcoming = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey&page=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _upcomingMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
        _upcomingPage = 1;
        _hasMoreUpcoming = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load upcoming movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingUpcoming = false;
    notifyListeners();
  }

  // Fetch all upcoming movies for "See All" page
  Future<void> fetchAllUpcomingMovies() async {
    _allUpcomingMovies = [];
    _upcomingPage = 1;
    _hasMoreUpcoming = true;
    await _loadMoreUpcomingMovies();
  }

  // Load more upcoming movies (pagination)
  Future<void> _loadMoreUpcomingMovies() async {
    if (!_hasMoreUpcoming || _isLoadingMoreUpcoming) return;

    _isLoadingMoreUpcoming = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/upcoming?api_key=$_apiKey&page=$_upcomingPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();

        _allUpcomingMovies.addAll(newMovies);
        _upcomingPage++;
        _hasMoreUpcoming = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load more upcoming movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingMoreUpcoming = false;
    notifyListeners();
  }

  // Public method to load more upcoming movies
  Future<void> loadMoreUpcomingMovies() async {
    await _loadMoreUpcomingMovies();
  }

  // Fetch action movies (initial load - first page only)
  Future<void> fetchActionMovies() async {
    _isLoadingAction = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=28&page=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _actionMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
        _actionPage = 1;
        _hasMoreAction = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load action movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingAction = false;
    notifyListeners();
  }

  // Fetch all action movies for "See All" page
  Future<void> fetchAllActionMovies() async {
    _allActionMovies = [];
    _actionPage = 1;
    _hasMoreAction = true;
    await _loadMoreActionMovies();
  }

  // Load more action movies (pagination)
  Future<void> _loadMoreActionMovies() async {
    if (!_hasMoreAction || _isLoadingMoreAction) return;

    _isLoadingMoreAction = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=28&page=$_actionPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();

        _allActionMovies.addAll(newMovies);
        _actionPage++;
        _hasMoreAction = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load more action movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingMoreAction = false;
    notifyListeners();
  }

  // Public method to load more action movies
  Future<void> loadMoreActionMovies() async {
    await _loadMoreActionMovies();
  }

  // Fetch comedy movies (initial load - first page only)
  Future<void> fetchComedyMovies() async {
    _isLoadingComedy = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=35&page=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _comedyMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
        _comedyPage = 1;
        _hasMoreComedy = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load comedy movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingComedy = false;
    notifyListeners();
  }

  // Fetch all comedy movies for "See All" page
  Future<void> fetchAllComedyMovies() async {
    _allComedyMovies = [];
    _comedyPage = 1;
    _hasMoreComedy = true;
    await _loadMoreComedyMovies();
  }

  // Load more comedy movies (pagination)
  Future<void> _loadMoreComedyMovies() async {
    if (!_hasMoreComedy || _isLoadingMoreComedy) return;

    _isLoadingMoreComedy = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=35&page=$_comedyPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();

        _allComedyMovies.addAll(newMovies);
        _comedyPage++;
        _hasMoreComedy = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load more comedy movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingMoreComedy = false;
    notifyListeners();
  }

  // Public method to load more comedy movies
  Future<void> loadMoreComedyMovies() async {
    await _loadMoreComedyMovies();
  }

  // Fetch horror movies (initial load - first page only)
  Future<void> fetchHorrorMovies() async {
    _isLoadingHorror = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=27&page=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _horrorMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
        _horrorPage = 1;
        _hasMoreHorror = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load horror movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingHorror = false;
    notifyListeners();
  }

  // Fetch all horror movies for "See All" page
  Future<void> fetchAllHorrorMovies() async {
    _allHorrorMovies = [];
    _horrorPage = 1;
    _hasMoreHorror = true;
    await _loadMoreHorrorMovies();
  }

  // Load more horror movies (pagination)
  Future<void> _loadMoreHorrorMovies() async {
    if (!_hasMoreHorror || _isLoadingMoreHorror) return;

    _isLoadingMoreHorror = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=27&page=$_horrorPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();

        _allHorrorMovies.addAll(newMovies);
        _horrorPage++;
        _hasMoreHorror = data['page'] < data['total_pages'];
      } else {
        _errorMessage = 'Failed to load more horror movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingMoreHorror = false;
    notifyListeners();
  }

  // Public method to load more horror movies
  Future<void> loadMoreHorrorMovies() async {
    await _loadMoreHorrorMovies();
  }

  // Search movies with debouncing
  void searchMovies(String query) {
    // Cancel previous timer if it exists
    _searchDebouncer?.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    // Set loading state immediately
    _isSearching = true;
    notifyListeners();

    // Create a new timer for debouncing (500ms delay)
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  // Actual search implementation
  Future<void> _performSearch(String query) async {
    _isSearching = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _searchResults =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
      } else {
        _errorMessage = 'Failed to search movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isSearching = false;
    notifyListeners();
  }

  // Fetch cast for a specific movie
  Future<List<CastMember>> fetchMovieCast(int movieId) async {
    // Return cached cast if available
    if (_movieCast.containsKey(movieId)) {
      return _movieCast[movieId]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final castList =
            (data['cast'] as List)
                .map((cast) => CastMember.fromJson(cast))
                .toList();

        // Sort by order (main cast first) and limit to top 10
        castList.sort((a, b) => a.order.compareTo(b.order));
        final topCast = castList.take(10).toList();

        // Cache the cast data
        _movieCast[movieId] = topCast;

        return topCast;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching cast: $e');
      return [];
    }
  }

  // Get cast for a movie (returns cached data if available)
  List<CastMember> getMovieCast(int movieId) {
    return _movieCast[movieId] ?? [];
  }

  // Fetch trailer for a specific movie
  Future<String?> fetchMovieTrailer(int movieId) async {
    // Return cached trailer if available
    if (_movieTrailers.containsKey(movieId)) {
      return _movieTrailers[movieId];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videos = data['results'] as List;

        // Find the first official trailer
        final trailer = videos.firstWhere(
          (video) =>
              video['type'] == 'Trailer' &&
              video['site'] == 'YouTube' &&
              video['official'] == true,
          orElse: () => null,
        );

        if (trailer != null) {
          final trailerKey = trailer['key'];
          _movieTrailers[movieId] = trailerKey;
          return trailerKey;
        }

        // If no official trailer, try to find any trailer
        final anyTrailer = videos.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        );

        if (anyTrailer != null) {
          final trailerKey = anyTrailer['key'];
          _movieTrailers[movieId] = trailerKey;
          return trailerKey;
        }

        // Cache null if no trailer found
        _movieTrailers[movieId] = null;
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching trailer: $e');
      return null;
    }
  }

  // Get trailer for a movie (returns cached data if available)
  String? getMovieTrailer(int movieId) {
    return _movieTrailers[movieId];
  }

  // Load all initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      fetchPopularMovies(),
      fetchTopRatedMovies(),
      fetchUpcomingMovies(),
      fetchActionMovies(),
      fetchComedyMovies(),
      fetchHorrorMovies(),
    ]);
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    super.dispose();
  }
}
