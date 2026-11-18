import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  LiveTvScreen â€” Redesigned with AppColors tokens + pulsing LIVE
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  int _selectedChannelIndex = 0;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // â”€â”€â”€ Pulsing LIVE badge animation â”€â”€â”€
  late final AnimationController _livePulseCtrl;

  @override
  void initState() {
    super.initState();
    _livePulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initializeVideoPlayer(_currentChannel.videoUrl);
  }

  _Channel get _currentChannel {
    return _MockEpgData
        .categories[_selectedCategoryIndex].channels[_selectedChannelIndex];
  }

  void _initializeVideoPlayer(String url) async {
    final oldController = _videoController;
    if (oldController != null) {
      oldController.pause();
      oldController.dispose();
    }

    setState(() {
      _isVideoInitialized = false;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(1.0);
      _videoController!.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  void _onCategorySelected(int index) {
    if (_selectedCategoryIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategoryIndex = index;
      _selectedChannelIndex = 0;
    });
    _initializeVideoPlayer(_currentChannel.videoUrl);
  }

  void _onChannelSelected(int index) {
    if (_selectedChannelIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedChannelIndex = index;
    });
    _initializeVideoPlayer(_currentChannel.videoUrl);
  }

  @override
  void dispose() {
    _livePulseCtrl.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredChannel = _currentChannel;
    final screenPadding = MediaQuery.of(context).padding;
    final currentCategory = _MockEpgData.categories[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // â”€â”€â”€ Ambient Glow â”€â”€â”€
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            top: 100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            top: 300,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // â”€â”€â”€ Edge-to-Edge Video Player â”€â”€â”€
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: screenPadding.top),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_isVideoInitialized && _videoController != null)
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 500),
                              child: VideoPlayer(_videoController!),
                            )
                          else
                            Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),

                          // Smooth gradient fade
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 1.0),
                                    Colors.black.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // â”€â”€â”€ LIVE Badge with pulsing animation â”€â”€â”€
                          Positioned(
                            top: 16,
                            left: 16,
                            child: AnimatedBuilder(
                              animation: _livePulseCtrl,
                              builder: (context, child) {
                                final opacity =
                                    0.85 + (_livePulseCtrl.value * 0.15);
                                return Opacity(
                                  opacity: opacity,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE50914), // AppColors.primary
                                          Color(0xFFFF3B30), // AppColors.primaryLight
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'LIVE',
                                      style: GoogleFonts.inter(
                                        color: AppColors.textPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Fullscreen Button
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  child: IconButton(
                                    icon: const Icon(Icons.fullscreen,
                                        color: AppColors.textPrimary, size: 24),
                                    onPressed: () {
                                      if (_videoController != null) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                _LiveFullscreenPlayer(
                                              controller: _videoController!,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // â”€â”€â”€ Channel Header â”€â”€â”€
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // â”€â”€â”€ Logo: 56x56 borderRadius:14 â”€â”€â”€
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111), // AppColors.surface
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0x1AFFFFFF)), // glassSurface
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CachedNetworkImage(
                            imageUrl: featuredChannel.logo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                featuredChannel.name,
                                key: ValueKey(featuredChannel.name),
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                featuredChannel.nowPlaying,
                                key: ValueKey(featuredChannel.nowPlaying),
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryLight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // â”€â”€â”€ Section Title (Channels) â”€â”€â”€
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Up Next',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // â”€â”€â”€ Channel Cards: 72x72 width:100 borderRadius:16 â”€â”€â”€
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentCategory.channels.length,
                    itemBuilder: (context, index) {
                      final channel = currentCategory.channels[index];
                      final isSelected = index == _selectedChannelIndex;

                      return GestureDetector(
                        onTap: () => _onChannelSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : const Color(0x0DFFFFFF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              // â”€â”€â”€ Backdrop blur: sigma 12 (was 15) â”€â”€â”€
                              filter:
                                  ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Center(
                                child: AnimatedScale(
                                  scale: isSelected ? 1.05 : 0.95,
                                  duration: const Duration(milliseconds: 300),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CachedNetworkImage(
                                      imageUrl: channel.logo,
                                      fit: BoxFit.contain,
                                      color: isSelected
                                          ? AppColors.textPrimary
                                          : AppColors.textPrimary
                                              .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // â”€â”€â”€ Section Title (Categories) â”€â”€â”€
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Categories',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // â”€â”€â”€ Category Tiles â”€â”€â”€
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = _MockEpgData.categories[index];
                      final isSelected = index == _selectedCategoryIndex;

                      return _MinimalistCategoryTile(
                        category: category,
                        isSelected: isSelected,
                        onTap: () => _onCategorySelected(index),
                      );
                    },
                    childCount: _MockEpgData.categories.length,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SafeArea(
                  top: false,
                  child: const SizedBox(height: 60),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Category Tile â”€â”€â”€
class _MinimalistCategoryTile extends StatelessWidget {
  final _Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _MinimalistCategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.textPrimary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            // â”€â”€â”€ Backdrop blur: sigma 12 (was 15) â”€â”€â”€
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  // â”€â”€â”€ Icon: 18px, circle, padding:10 â”€â”€â”€
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.textPrimary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tv_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white54,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // â”€â”€â”€ name: 16px â”€â”€â”€
                        Text(
                          category.name,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // â”€â”€â”€ count: 12px â”€â”€â”€
                        Text(
                          '${category.channels.length} Channels',
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? AppColors.textPrimary
                                    .withValues(alpha: 0.8)
                                : AppColors.textPrimary
                                    .withValues(alpha: 0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  Mock Data
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class _Channel {
  final String id;
  final String name;
  final String logo;
  final String videoUrl;
  final String nowPlaying;

  _Channel({
    required this.id,
    required this.name,
    required this.logo,
    required this.videoUrl,
    required this.nowPlaying,
  });
}

class _Category {
  final String id;
  final String name;
  final String logo;
  final List<_Channel> channels;

  _Category({
    required this.id,
    required this.name,
    required this.logo,
    required this.channels,
  });
}

class _MockEpgData {
  static final List<_Category> categories = [
    _Category(
      id: 'cat_sky',
      name: 'Sky Sports',
      logo:
          'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/kodi.png',
      channels: [
        _Channel(
          id: 'sky1',
          name: 'Main Event',
          logo:
              'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/kodi.png',
          videoUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
          nowPlaying: 'Arsenal vs Chelsea',
        ),
        _Channel(
          id: 'sky2',
          name: 'Premier League',
          logo:
              'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/kodi.png',
          videoUrl:
              'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
          nowPlaying: 'Match Analysis',
        ),
      ],
    ),
    _Category(
      id: 'cat_bein',
      name: 'beIN Sports',
      logo:
          'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/twitch.png',
      channels: [
        _Channel(
          id: 'bein1',
          name: 'beIN 1',
          logo:
              'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/twitch.png',
          videoUrl:
              'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
          nowPlaying: 'UCL Final',
        ),
      ],
    ),
    _Category(
      id: 'cat_hbo',
      name: 'Cinema',
      logo:
          'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/hbo.png',
      channels: [
        _Channel(
          id: 'hbo1',
          name: 'HBO Max',
          logo:
              'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/hbo.png',
          videoUrl:
              'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
          nowPlaying: 'House of the Dragon',
        ),
      ],
    ),
  ];
}

// â”€â”€â”€ Fullscreen Player â”€â”€â”€
class _LiveFullscreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const _LiveFullscreenPlayer({required this.controller});

  @override
  State<_LiveFullscreenPlayer> createState() => _LiveFullscreenPlayerState();
}

class _LiveFullscreenPlayerState extends State<_LiveFullscreenPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textPrimary, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
