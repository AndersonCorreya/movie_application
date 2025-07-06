import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movieapplication/Model/movie_model.dart';
import 'package:movieapplication/Model/cast_model.dart';
import 'package:movieapplication/ViewModel/movie_provider.dart';
import 'package:movieapplication/View/widgets/youtube_trailer_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollController();
    _loadCastData();
    _loadTrailerData();
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

    // Start animations
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
    if (_trailerVideoId != null) return; // Already loaded

    if (!mounted) return;
    setState(() {
      _isLoadingTrailer = true;
    });

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
      setState(() {
        _isLoadingTrailer = false;
      });
    }
  }

  Future<void> _loadCastData() async {
    if (_castMembers.isNotEmpty) return; // Already loaded

    if (!mounted) return;
    setState(() {
      _isLoadingCast = true;
    });

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
      setState(() {
        _isLoadingCast = false;
      });
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

    // Add safety check for movie data
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
      appBar: _buildAppBar(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [_buildHeroSection(), _buildMovieContent()],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: AnimatedOpacity(
        opacity: _isAppBarVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        AnimatedOpacity(
          opacity: _isAppBarVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Consumer<MovieProvider>(
              builder: (context, provider, child) {
                final isInWatchlist = provider.isInDefaultWatchlist(
                  widget.movie,
                );
                return PopupMenuButton<String>(
                  icon: Icon(
                    isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                    color: isInWatchlist ? Colors.amber : Colors.white,
                  ),
                  onSelected: (value) async {
                    HapticFeedback.lightImpact();
                    if (value == 'quick_add') {
                      if (isInWatchlist) {
                        await provider.removeFromDefaultWatchlist(widget.movie);
                        if (mounted) {
                          _showSnackBar('Removed from default watchlist');
                        }
                      } else {
                        await provider.addToDefaultWatchlist(widget.movie);
                        if (mounted) {
                          _showSnackBar('Added to default watchlist');
                        }
                      }
                    } else if (value == 'add_to_list') {
                      _showWatchlistSelectionDialog();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'quick_add',
                          child: Row(
                            children: [
                              Icon(
                                isInWatchlist
                                    ? Icons.bookmark_remove
                                    : Icons.bookmark_add,
                                color:
                                    isInWatchlist
                                        ? Colors.red
                                        : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isInWatchlist
                                    ? 'Remove from Default Watchlist'
                                    : 'Quick Add to Default Watchlist',
                                style: TextStyle(
                                  color:
                                      isInWatchlist
                                          ? Colors.red
                                          : theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'add_to_list',
                          child: Row(
                            children: [
                              Icon(Icons.playlist_add, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text(
                                'Add to Custom List',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 400,
      pinned: false,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            Hero(
              tag: widget.heroTag ?? 'movie_poster_${widget.movie.id}',
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child:
                    widget.movie.posterUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: widget.movie.posterUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: theme.cardTheme.color,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: theme.cardTheme.color,
                                child: Icon(
                                  Icons.movie,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  size: 80,
                                ),
                              ),
                        )
                        : Container(
                          color: theme.cardTheme.color,
                          child: Icon(
                            Icons.movie,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            size: 80,
                          ),
                        ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            // Movie title at bottom
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.movie.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.movie.rating!.toStringAsFixed(1)}/10)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieContent() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCastSection(),
                  const SizedBox(height: 24),
                  _buildMovieInfo(),
                  const SizedBox(height: 24),
                  _buildOverview(),
                  const SizedBox(height: 24),
                  _buildTrailerSection(),
                  const SizedBox(height: 24),
                  _buildAdditionalInfo(),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildCastSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingCast)
          SizedBox(
            height: 110,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          )
        else if (_castMembers.isEmpty)
          SizedBox(
            height: 110,
            child: Center(
              child: Text(
                'No cast information available',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _castMembers.length,
              itemBuilder: (context, index) {
                final castMember = _castMembers[index];
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child:
                              castMember.profileUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                    imageUrl: castMember.profileUrl,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Container(
                                          color: theme.cardTheme.color,
                                          child: Icon(
                                            Icons.person,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.5),
                                            size: 30,
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color: theme.cardTheme.color,
                                          child: Icon(
                                            Icons.person,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.5),
                                            size: 30,
                                          ),
                                        ),
                                  )
                                  : Container(
                                    color: theme.cardTheme.color,
                                    child: Icon(
                                      Icons.person,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                      size: 30,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 60,
                        child: Text(
                          castMember.name,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMovieInfo() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.movie.releaseDate != null) ...[
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Release Date: ${widget.movie.releaseDate}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        // Language information removed as it's not available in the Movie model
      ],
    );
  }

  Widget _buildOverview() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          (widget.movie.overview?.isNotEmpty == true)
              ? (widget.movie.overview ?? 'No overview available.')
              : 'No overview available.',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailerSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trailer',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingTrailer)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          )
        else if (_trailerVideoId != null)
          YouTubeTrailerWidget(
            videoId: _trailerVideoId!,
            movieTitle: widget.movie.title,
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No trailer available',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Movie ID', widget.movie.id.toString()),
          if (widget.movie.rating != null)
            _buildInfoRow(
              'Rating',
              '${widget.movie.rating!.toStringAsFixed(1)}/10',
            ),
          if (widget.movie.releaseDate != null)
            _buildInfoRow('Release Date', widget.movie.releaseDate!),
          // Language information removed as it's not available in the Movie model
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWatchlistSelectionDialog() {
    final theme = Theme.of(context);
    final provider = context.read<MovieProvider>();
    final watchlists = provider.customWatchlists;

    if (watchlists.isEmpty) {
      _showCreateWatchlistDialog();
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(
              'Add to Watchlist',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: watchlists.length,
                itemBuilder: (context, index) {
                  final watchlist = watchlists[index];
                  final isInWatchlist = provider.isMovieInWatchlist(
                    watchlist.id,
                    widget.movie,
                  );

                  return ListTile(
                    leading: Icon(
                      isInWatchlist
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          isInWatchlist
                              ? Colors.green
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      watchlist.name,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      '${watchlist.movieCount} movies',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    onTap: () async {
                      if (isInWatchlist) {
                        await provider.removeMovieFromWatchlist(
                          watchlist.id,
                          widget.movie,
                        );
                        if (mounted) {
                          _showSnackBar('Removed from ${watchlist.name}');
                        }
                      } else {
                        await provider.addMovieToWatchlist(
                          watchlist.id,
                          widget.movie,
                        );
                        if (mounted) {
                          _showSnackBar('Added to ${watchlist.name}');
                        }
                      }
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateWatchlistDialog();
                },
                child: const Text('Create New List'),
              ),
            ],
          ),
    );
  }

  void _showCreateWatchlistDialog() {
    final theme = Theme.of(context);
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: Text(
              'Create New Watchlist',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Watchlist Name',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    final watchlist = await context
                        .read<MovieProvider>()
                        .createCustomWatchlist(
                          nameController.text.trim(),
                          description: descriptionController.text.trim(),
                        );
                    await context.read<MovieProvider>().addMovieToWatchlist(
                      watchlist.id,
                      widget.movie,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      _showSnackBar(
                        'Created "${watchlist.name}" and added movie',
                      );
                    }
                  }
                },
                child: const Text('Create & Add'),
              ),
            ],
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
