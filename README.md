# Movie Application

A Flutter application for browsing and discovering movies using The Movie Database (TMDB) API.

## Setup Instructions

### 1. Get API Key
1. Go to [The Movie Database](https://www.themoviedb.org/)
2. Create an account or sign in
3. Go to Settings → API
4. Request an API key for "Developer" use
5. Copy your API key

### 2. Configure API Key
1. Copy `lib/config/secrets.template.dart` to `lib/config/secrets.dart`
2. Replace `YOUR_API_KEY_HERE` with your actual API key:
   ```dart
   static const String movieApiKey = 'your_actual_api_key_here';
   ```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the Application
```bash
flutter run
```

## Security Notes

- **Never commit `lib/config/secrets.dart` to version control**
- The `secrets.dart` file is already added to `.gitignore`
- Use `secrets.template.dart` as a reference for the required configuration

## Features

- Browse popular, top-rated, and upcoming movies
- Search for movies
- Add movies to watchlist
- Movie details with ratings and descriptions
- Modern UI with dark theme

## Dependencies

- Flutter SDK
- Provider (state management)
- HTTP (API calls)
- Flutter SVG (custom icons)
- Cached Network Image (image caching) 