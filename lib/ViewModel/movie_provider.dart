import 'package:flutter/material.dart';
import 'package:movieapplication/Model/movie_model.dart';
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

  bool _isLoadingPopular = false;
  bool _isLoadingTopRated = false;
  bool _isLoadingUpcoming = false;
  bool _isSearching = false;

  String _errorMessage = '';

  // Debouncer for search
  Timer? _searchDebouncer;

  // Getters
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get watchlist => _watchlist;

  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingTopRated => _isLoadingTopRated;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isSearching => _isSearching;

  String get errorMessage => _errorMessage;

  // Replace with your actual API key
  final String _apiKey = 'b0ef6658940e112228613dffb70d5996';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  // Fetch popular movies
  Future<void> fetchPopularMovies() async {
    _isLoadingPopular = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _popularMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
      } else {
        _errorMessage = 'Failed to load popular movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingPopular = false;
    notifyListeners();
  }

  // Fetch top rated movies
  Future<void> fetchTopRatedMovies() async {
    _isLoadingTopRated = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _topRatedMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
      } else {
        _errorMessage = 'Failed to load top rated movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingTopRated = false;
    notifyListeners();
  }

  // Fetch upcoming movies
  Future<void> fetchUpcomingMovies() async {
    _isLoadingUpcoming = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _upcomingMovies =
            (data['results'] as List)
                .map((movie) => Movie.fromJson(movie))
                .toList();
      } else {
        _errorMessage = 'Failed to load upcoming movies';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    }

    _isLoadingUpcoming = false;
    notifyListeners();
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
