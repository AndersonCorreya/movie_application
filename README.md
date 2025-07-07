# 🎬 **MyFlicks – A Movie Watchlist App**

**MyFlicks** is a Flutter-based movie application that allows users to browse, search, and curate custom movie watchlists using data from TMDb API. With a focus on minimal design, real-time search, and local data storage, MyFlicks makes organizing your film library effortless—even when offline.

---

## 📌 **About the App**

**MyFlicks** delivers an immersive movie discovery experience with clean UI, persistent custom watchlists, and rich movie details—all powered by TMDb. Whether you're a casual movie watcher or a film buff, this app will help you explore trending content, save what you love, and build your own watchlist universe.

---

## ⚙️ **Assumptions & Considerations**

- The app uses TMDb as its primary content source; availability of data depends on TMDb’s API services.  
- All watchlist data is stored locally using Hive; syncing across devices is not included in this version.  
- API key management is manually configured via a `secrets.dart` file.  
- Due to potential TMDb API blocks on certain networks (e.g., Jio), the app may require VPN for data fetching.  
- By default, the app follows system theme, but it can be changed in the settings.  

---

## 🚀 **Features**

### 🎥 **Movie Browsing**

- **Popular Movies** – Discover what’s trending  
- **Top Rated** – Explore critically acclaimed films  
- **Upcoming** – Keep an eye on future releases  
- **Search** – Find movies in real-time by title  

### 🗂️ **Custom Watchlists**

- **Create Multiple Lists** – Group movies by genre, mood, or preference  
- **Add/Remove Movies** – Manage movies from the detail page  
- **Offline Support** – Watchlists are stored locally with Hive  
- **Persistent Data** – All lists remain saved between app launches  

### 📄 **Movie Details**

View full movie information including:

- Poster, rating, overview  
- Cast details  
- Add to watchlist directly from the movie page  

---

## 🧑‍💻 **Technical Features**

### 📦 **State Management**

- Built using the **Provider** pattern  
- Real-time updates on UI when watchlists change  

### 💾 **Local Storage**

- Hive database for fast and lightweight local persistence  
- Offline-first experience for managing watchlists  

### 🖌️ **UI/UX**

- Dark Mode for an immersive experience  
- Responsive Design for multiple device sizes  
- Smooth Animations and intuitive navigation  

---

## 🔧 **Getting Started**

### ✅ **Prerequisites**

- Flutter SDK 3.8.0 or higher  
- Dart SDK  
- Android Studio or VS Code  

### 🛠️ **Installation**

```bash
# Clone the repo:
git clone <repository-url>
cd myflicks

# Get dependencies:
flutter pub get

# Generate Hive adapters:
flutter packages pub run build_runner build

# Run the app:
flutter run

🔐 Configuration

Create a file at:
lib/config/secrets.dart

Add the following code with your TMDb API key:

class Secrets {
  static const String movieApiKey = 'YOUR_TMDB_API_KEY';
  static const String movieBaseUrl = 'https://api.themoviedb.org/3';
}

Get your API key from: The Movie Database
📱 Usage Guide
➕ Creating a Watchlist

    Go to the Watchlist tab

    Tap the “+” button

    Enter list name and optional description

    Hit Create

🎞️ Adding Movies

    Visit a movie’s detail page

    Tap the bookmark icon

    Choose or create a watchlist

🗑️ Managing Watchlists

    Tap to view any list

    Remove movies in a watchlist by holding to the poster card

    Delete lists using the "⋮" menu

🧱 Architecture
📂 Models

    Movie: Movie data (Hive-serializable)

    Watchlist: Stores movie collections

    CastMember: Stores cast info

🧰 Services

    WatchlistService: Handles Hive operations

🧠 Providers

    MovieProvider: Manages movie & watchlist logic

🖼️ Pages

    MovieHomePage: Main screen with tabs

    WatchlistPage: Manages custom lists

    MovieDetailPage: Movie overview + add to list

📦 Dependencies

    provider – State management

    hive & hive_flutter – Local storage

    http – REST API calls

    cached_network_image – Cached image loading

    flutter_svg – SVG rendering

    shared_preferences

    url_launcher

    flutter_native_splash

🤝 Contributing

Contributions are welcome!

    Fork this repo

    Create a new feature branch

    Make your changes & commit

    Submit a pull request

📄 License

This project is licensed under the MIT License.
