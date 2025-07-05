import 'package:flutter/material.dart';
import 'package:movieapplication/Model/movie_model.dart';
import 'package:movieapplication/Model/cast_model.dart';
import 'package:movieapplication/config/secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Movie Provider for state management
class MovieProvider extends ChangeNotifier {
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _upcomingMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _watchlist = [];
  Map<int, List<CastMember>> _movieCast = {};

  // Pagination support for "See All" pages
  List<Movie> _allPopularMovies = [];
  List<Movie> _allTopRatedMovies = [];
  List<Movie> _allUpcomingMovies = [];

  bool _isLoadingPopular = false;
  bool _isLoadingTopRated = false;
  bool _isLoadingUpcoming = false;
  bool _isSearching = false;
  bool _isLoadingMorePopular = false;
  bool _isLoadingMoreTopRated = false;
  bool _isLoadingMoreUpcoming = false;

  String _errorMessage = '';

  // Pagination state
  int _popularPage = 1;
  int _topRatedPage = 1;
  int _upcomingPage = 1;
  bool _hasMorePopular = true;
  bool _hasMoreTopRated = true;
  bool _hasMoreUpcoming = true;

  // Debouncer for search
  Timer? _searchDebouncer;

  // Getters
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get watchlist => _watchlist;
  Map<int, List<CastMember>> get movieCast => _movieCast;

  // "See All" page getters
  List<Movie> get allPopularMovies => _allPopularMovies;
  List<Movie> get allTopRatedMovies => _allTopRatedMovies;
  List<Movie> get allUpcomingMovies => _allUpcomingMovies;

  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingTopRated => _isLoadingTopRated;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isSearching => _isSearching;
  bool get isLoadingMorePopular => _isLoadingMorePopular;
  bool get isLoadingMoreTopRated => _isLoadingMoreTopRated;
  bool get isLoadingMoreUpcoming => _isLoadingMoreUpcoming;

  String get errorMessage => _errorMessage;

  // Pagination getters
  bool get hasMorePopular => _hasMorePopular;
  bool get hasMoreTopRated => _hasMoreTopRated;
  bool get hasMoreUpcoming => _hasMoreUpcoming;

  // API configuration from secrets
  final String _apiKey = Secrets.movieApiKey;
  final String _baseUrl = Secrets.movieBaseUrl;

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

  // Watchlist management
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

  // Load all initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      fetchPopularMovies(),
      fetchTopRatedMovies(),
      fetchUpcomingMovies(),
    ]);
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    super.dispose();
  }
}
