// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myflicks/providers/movie_provider.dart';
import 'package:myflicks/Model/movie_model.dart';
import 'package:myflicks/Model/watchlist_model.dart';
import 'package:myflicks/pages/watchlist_page.dart';

void main() {
  group('Watchlist Icon Tests', () {
    testWidgets('Watchlist with movies shows first movie poster', (
      WidgetTester tester,
    ) async {
      // Create a test movie
      final testMovie = Movie(
        id: 1,
        title: 'Test Movie',
        posterUrl: 'https://image.tmdb.org/t/p/w500/test.jpg',
        rating: 8.5,
        releaseDate: '2023-01-01',
        overview: 'A test movie',
      );

      // Create a watchlist with the movie
      final watchlist = Watchlist(
        id: 'test_id',
        name: 'Test Watchlist',
        description: 'Test description',
        movies: [testMovie],
      );

      // Create movie provider and add the watchlist
      final movieProvider = MovieProvider();
      movieProvider.customWatchlists.add(watchlist);

      // Build the widget
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: movieProvider,
          child: MaterialApp(home: const WatchlistPage()),
        ),
      );

      // Verify that the watchlist shows an image (movie poster)
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsNothing);
    });

    testWidgets('Empty watchlist shows bookmark icon', (
      WidgetTester tester,
    ) async {
      // Create an empty watchlist
      final watchlist = Watchlist(
        id: 'test_id',
        name: 'Test Watchlist',
        description: 'Test description',
        movies: [],
      );

      // Create movie provider and add the watchlist
      final movieProvider = MovieProvider();
      movieProvider.customWatchlists.add(watchlist);

      // Build the widget
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: movieProvider,
          child: MaterialApp(home: const WatchlistPage()),
        ),
      );

      // Verify that the watchlist shows a bookmark icon (no movies)
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
