import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedChannelIndex = 0;
  
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Premium Colors (Red Theme)
  final Color _primaryRed = const Color(0xFFE50914); // Deep Netflix Red
  final Color _brightRed = const Color(0xFFFF3B30); // Bright iOS Red

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(_currentChannel.videoUrl);
  }
  
  _Channel get _currentChannel {
    return _MockEpgData.categories[_selectedCategoryIndex].channels[_selectedChannelIndex];
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
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredChannel = _currentChannel;
    final screenPadding = MediaQuery.of(context).padding;
    final currentCategory = _MockEpgData.categories[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle Colorful Ambient Glow based on selection
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
                    _primaryRed.withValues(alpha: 0.15),
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
                    _brightRed.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── Edge-to-Edge Video Player ───
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
                                color: _primaryRed,
                                strokeWidth: 2,
                              ),
                            ),
                          
                          // Smooth gradient fade
                          Positioned(
                            bottom: 0, left: 0, right: 0,
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
                          
                          // Colorful Live Badge
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_primaryRed, _brightRed],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryRed.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: Text(
                                'LIVE',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),

                          // Fullscreen Button
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  child: IconButton(
                                    icon: const Icon(Icons.fullscreen, color: Colors.white, size: 24),
                                    onPressed: () {
                                      if (_videoController != null) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => _LiveFullscreenPlayer(
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

              // ─── Minimalist Channel Header ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // Clean Logo Box
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryRed.withValues(alpha: 0.15),
                              blurRadius: 15,
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
                      // Large Clean Typography
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
                                  color: Colors.white,
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
                                  color: _brightRed,
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

              // ─── Section Title (Channels) ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _primaryRed,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Up Next',
                        style: GoogleFonts.inter(
                          color: Colors.white,
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
              
              // ─── Minimalist Floating Cards (Channels) ───
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
                          width: 110, 
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? _primaryRed.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? _primaryRed.withValues(alpha: 0.5) 
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: _primaryRed.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ] : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
                                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
              
              // ─── Section Title (Categories) ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _primaryRed,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Categories',
                        style: GoogleFonts.inter(
                          color: Colors.white,
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

              // ─── Apple TV Style Minimalist List (Packages) ───
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
                        accentColor: _primaryRed,
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

class _MinimalistCategoryTile extends StatelessWidget {
  final _Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  const _MinimalistCategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
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
              ? accentColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? accentColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tv_rounded, 
                      color: isSelected ? accentColor : Colors.white54,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${category.channels.length} Channels',
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Right Action Icon
                  if (isSelected)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: accentColor,
                      size: 18,
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mock Data ───

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
      logo: 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/kodi.png',
      channels: [
        _Channel(
          id: 'sky1',
          name: 'Main Event',
          logo: 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/kodi.png',
          videoUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
          nowPlaying: 'Arsenal vs Chelsea',
        ),
        _Channel(
          id: 'sky2',
          name: 'Premier League',
          logo: 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/kodi.png',
          videoUrl: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
          nowPlaying: 'Match Analysis',
        ),
      ],
    ),
    _Category(
      id: 'cat_bein',
      name: 'beIN Sports',
      logo: 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/twitch.png',
      channels: [
        _Channel(
          id: 'bein1',
          name: 'beIN 1',
          logo: 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/twitch.png',
          videoUrl: 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
          nowPlaying: 'UCL Final',
        ),
      ],
    ),
    _Category(
      id: 'cat_hbo',
      name: 'Cinema',
      logo: 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/hbo.png',
      channels: [
        _Channel(
          id: 'hbo1',
          name: 'HBO Max',
          logo: 'https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/hbo.png',
          videoUrl: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
          nowPlaying: 'House of the Dragon',
        ),
      ],
    ),
  ];
}

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
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
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
