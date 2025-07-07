import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myflicks/Model/movie_model.dart';
import 'package:myflicks/Model/cast_model.dart';
import 'package:myflicks/providers/movie_provider.dart';
import 'package:myflicks/pages/widgets/movie_detail_app_bar.dart';
import 'package:myflicks/pages/widgets/movie_hero_section.dart';
import 'package:myflicks/pages/widgets/movie_content_section.dart';
import 'package:myflicks/pages/widgets/watchlist_dialogs.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final String? heroTag;

  const MovieDetailPage({Key? key, required this.movie, this.heroTag})
    : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;

  bool _isAppBarVisible = true;
  double _scrollOffset = 0;
  List<CastMember> _castMembers = [];
  bool _isLoadingCast = false;
  String? _trailerVideoId;
  bool _isLoadingTrailer = false;
  List<Movie> _recommendedMovies = [];
  bool _isLoadingRecommended = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollController();
    _loadCastData();
    _loadTrailerData();
    _loadRecommendedMovies();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.offset;
          _isAppBarVisible = _scrollOffset < 200;
        });
      }
    });
  }

  Future<void> _loadTrailerData() async {
    if (_trailerVideoId != null) return;
    if (!mounted) return;
    setState(() => _isLoadingTrailer = true);
    try {
      final provider = context.read<MovieProvider>();
      final trailerId = await provider.fetchMovieTrailer(widget.movie.id);
      if (!mounted) return;
      setState(() {
        _trailerVideoId = trailerId;
        _isLoadingTrailer = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingTrailer = false);
    }
  }

  Future<void> _loadCastData() async {
    if (_castMembers.isNotEmpty) return;
    if (!mounted) return;
    setState(() => _isLoadingCast = true);
    try {
      final provider = context.read<MovieProvider>();
      final cast = await provider.fetchMovieCast(widget.movie.id);
      if (!mounted) return;
      setState(() {
        _castMembers = cast;
        _isLoadingCast = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCast = false);
    }
  }

  Future<void> _loadRecommendedMovies() async {
    if (_recommendedMovies.isNotEmpty) return;
    if (!mounted) return;
    setState(() => _isLoadingRecommended = true);
    try {
      final provider = context.read<MovieProvider>();
      final recommended = await provider.fetchRecommendedMovies(
        widget.movie.id,
      );
      if (!mounted) return;
      setState(() {
        _recommendedMovies = recommended;
        _isLoadingRecommended = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRecommended = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.movie.id == 0 || widget.movie.title.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Invalid movie data',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: MovieDetailAppBar(
        isVisible: _isAppBarVisible,
        movie: widget.movie,
        onBackPressed: () => Navigator.of(context).pop(),
        onWatchlistAction: _showWatchlistSelectionDialog,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          MovieHeroSection(
            movie: widget.movie,
            heroTag: widget.heroTag,
            fadeAnimation: _fadeAnimation,
            slideAnimation: _slideAnimation,
          ),
          MovieContentSection(
            movie: widget.movie,
            castMembers: _castMembers,
            isLoadingCast: _isLoadingCast,
            trailerVideoId: _trailerVideoId,
            isLoadingTrailer: _isLoadingTrailer,
            recommendedMovies: _recommendedMovies,
            isLoadingRecommended: _isLoadingRecommended,
            fadeAnimation: _fadeAnimation,
            slideAnimation: _slideAnimation,
          ),
        ],
      ),
    );
  }

  void _showWatchlistSelectionDialog() {
    final provider = context.read<MovieProvider>();
    final watchlists = provider.customWatchlists;

    if (watchlists.isEmpty) {
      _showCreateWatchlistDialog();
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => WatchlistSelectionDialog(
            watchlists: watchlists,
            movie: widget.movie,
            onCreateNew: _showCreateWatchlistDialog,
            onSnackBar: _showSnackBar,
          ),
    );
  }

  void _showCreateWatchlistDialog() {
    showDialog(
      context: context,
      builder:
          (context) => CreateWatchlistDialog(
            movie: widget.movie,
            onSnackBar: _showSnackBar,
          ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        backgroundColor: theme.cardTheme.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
