import 'package:flutter/material.dart';
import 'package:myflicks/providers/movie_provider.dart';
import 'package:provider/provider.dart';
import 'package:myflicks/pages/app_wrapper.dart';
import 'package:myflicks/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the movie provider and watchlist service
  final movieProvider = MovieProvider();
  await movieProvider.initializeWatchlistService();

  // Initialize theme provider
  final themeProvider = ThemeProvider();

  runApp(MyApp(movieProvider: movieProvider, themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final MovieProvider movieProvider;
  final ThemeProvider themeProvider;

  const MyApp({
    super.key,
    required this.movieProvider,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: movieProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MyFlicks',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AppWrapper(),
          );
        },
      ),
    );
  }
}
