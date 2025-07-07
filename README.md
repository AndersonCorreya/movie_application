# Movie Application

A Flutter movie application that allows users to browse movies, search for content, and manage custom watchlists with local storage.

## Features

### Movie Browsing
- **Popular Movies**: Browse trending movies
- **Top Rated**: Discover highly-rated films
- **Upcoming**: See movies that are coming soon
- **Search**: Find movies by title with real-time search

### Custom Watchlists
- **Create Multiple Lists**: Organize movies into custom categories
- **Add/Remove Movies**: Save movies to specific watchlists from the movie detail page
- **Local Storage**: All watchlist data is stored locally using Hive
- **Persistent Data**: Watchlists persist between app sessions

### Movie Details
- **Comprehensive Information**: View movie details including cast, ratings, and overview
- **Cast Information**: See the main cast members for each movie
- **Watchlist Integration**: Add movies to custom watchlists directly from the detail page

## Technical Features

### State Management
- **Provider Pattern**: Uses Provider for state management
- **Real-time Updates**: UI updates automatically when watchlists change

### Local Storage
- **Hive Database**: Fast, lightweight local database
- **Offline Support**: All watchlist data works offline
- **Data Persistence**: Watchlists are saved locally and persist between app launches

### UI/UX
- **Dark Theme**: Modern dark theme optimized for movie viewing
- **Responsive Design**: Works on various screen sizes
- **Smooth Animations**: Hero animations and smooth transitions
- **Intuitive Navigation**: Easy-to-use bottom navigation

## Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd myflicks
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter packages pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

### Configuration

1. Create a `lib/config/secrets.dart` file with your TMDB API key:
```dart
class Secrets {
  static const String movieApiKey = 'YOUR_TMDB_API_KEY';
  static const String movieBaseUrl = 'https://api.themoviedb.org/3';
}
```

2. Get your API key from [The Movie Database](https://www.themoviedb.org/settings/api)

## Usage

### Creating Watchlists
1. Navigate to the Watchlist tab
2. Tap the "+" button in the app bar
3. Enter a name and optional description
4. Tap "Create"

### Adding Movies to Watchlists
1. Open any movie detail page
2. Tap the bookmark icon in the app bar
3. Select "Add to Custom List"
4. Choose an existing watchlist or create a new one

### Managing Watchlists
- **View Lists**: Tap on any watchlist to see its movies
- **Delete Lists**: Use the menu (⋮) on any watchlist to delete it
- **Remove Movies**: Tap on movies in watchlist detail view to remove them

## Architecture

### Models
- `Movie`: Represents movie data with Hive serialization
- `Watchlist`: Represents custom watchlists with movie collections
- `CastMember`: Represents cast information

### Services
- `WatchlistService`: Manages Hive database operations for watchlists

### ViewModels
- `MovieProvider`: Main state management for movies and watchlists

### Views
- `MovieHomePage`: Main navigation and movie browsing
- `WatchlistPage`: Custom watchlist management
- `MovieDetailPage`: Detailed movie information with watchlist integration

## Dependencies

- `provider`: State management
- `hive`: Local database
- `hive_flutter`: Flutter integration for Hive
- `http`: API requests
- `cached_network_image`: Image caching
- `flutter_svg`: SVG support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License. 