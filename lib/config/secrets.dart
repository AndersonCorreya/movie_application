// This file contains the actual API configuration
// You can either hardcode your API key here or use environment variables

import 'dart:io';

class Secrets {
  // Option 1: Hardcode your API key here (replace with your actual key)
  static const String _hardcodedApiKey =
      'b0ef6658940e112228613dffb70d5996'; // Replace this with your real API key

  // Option 2: Use environment variable (more secure for production)
  static String get movieApiKey {
    // Try to get from environment variable first
    final envApiKey = Platform.environment['TMDB_API_KEY'];
    if (envApiKey != null && envApiKey.isNotEmpty) {
      return envApiKey;
    }
    // Fallback to hardcoded key
    return _hardcodedApiKey;
  }

  // Base URL for the movie API
  static const String movieBaseUrl = 'https://api.themoviedb.org/3';
}
