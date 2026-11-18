import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, PointerDeviceKind;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/live_broadcast_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  LiveTvScreen v5.0 — Crimson Cinema & Full-Bleed Minimalist Edition
//  (SlothUI Design 4 Glowing 16:9 Showcase + HBO Design 5 Open Full-Bleed)
//  Zero sidebars • Zero cluttered detail boxes • 100% Edge-to-Edge Canvas
// ─────────────────────────────────────────────────────────────────────────────

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen>
    with TickerProviderStateMixin {
  static const String _prefsFavoritesKey = 'skylive_live_favorites_v3';
  static const Duration _hudAutoHideDelay = Duration(milliseconds: 2600);

  LiveChannel _activeChannel = LiveBroadcastCatalog.channels.first;
  LiveCategory _selectedCategory = LiveCategory.all;
  String _searchQuery = '';
  String _selectedQuality = 'Auto';
  bool _fillScreen = true;
  bool _isMobileSearchOpen = false;
  bool _isSearchFocused = false;
  bool _isInFullscreen = false;

  final Set<String> _favoriteIds = <String>{
    'bein_1_premium',
    'sky_sports_pl',
    'hbo_max_live',
  };
  final Set<String> _remindedSlotIds = <String>{};

  // Video & Browser-Guaranteed Autoplay State
  VideoPlayerController? _videoController;
  int _loadGeneration = 0;
  bool _isVideoInitialized = false;
  bool _isLoadingStream = true;
  bool _hasStreamError = false;
  bool _isPlaying = true;
  bool _isMuted = true;
  bool _userUnmutedSession = false;
  double _volume = 1.0;

  // Fullscreen HUD, OSD & Live Telemetry State
  bool _showHud = true;
  bool _showOsdBanner = false;
  DateTime _now = DateTime.now();
  double _viewerDeltaK = 0.0;

  late final AnimationController _studioAnimCtrl;
  late final AnimationController _pulseAnimCtrl;
  late final AnimationController _eqAnimCtrl;
  late final TextEditingController _searchCtrl;
  late final FocusNode _searchFocusNode;
  late final ScrollController _railScrollCtrl;
  late final ValueNotifier<int> _playerSyncTick;

  Timer? _clockTimer;
  Timer? _hudHideTimer;
  Timer? _osdTimer;

  @override
  void initState() {
    super.initState();
    _playerSyncTick = ValueNotifier<int>(0);
    _studioAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _pulseAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _eqAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
    _searchCtrl = TextEditingController();
    _searchFocusNode = FocusNode()
      ..addListener(() {
        if (!mounted) {
          return;
        }
        setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
      });
    _railScrollCtrl = ScrollController();

    _restoreFavorites();
    _loadChannel(_activeChannel, showOsd: false);

    _clockTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _now = DateTime.now();
        final double wave = math.sin(_now.second * 0.45);
        _viewerDeltaK = double.parse((wave * 0.6).toStringAsFixed(1));
      });
      _notifyPlayerSync();
    });
  }

  void _notifyPlayerSync() {
    _playerSyncTick.value = _playerSyncTick.value + 1;
  }

  Future<void> _restoreFavorites() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) {
        return;
      }
      final List<String>? saved = prefs.getStringList(_prefsFavoritesKey);
      if (saved != null) {
        setState(() {
          _favoriteIds
            ..clear()
            ..addAll(saved);
        });
      }
    } catch (_) {
      // Fallback to in-memory defaults silently.
    }
  }

  Future<void> _toggleFavorite(LiveChannel channel) async {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      if (_favoriteIds.contains(channel.id)) {
        _favoriteIds.remove(channel.id);
      } else {
        _favoriteIds.add(channel.id);
      }
    });
    _notifyPlayerSync();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsFavoritesKey, _favoriteIds.toList());
    } catch (_) {
      // Ignore storage write issues in restricted web sessions.
    }
  }

  void _toggleSlotReminder(EpgSlot slot) {
    unawaited(HapticFeedback.selectionClick());
    final bool ar = LiveBroadcastType.isAr(context);
    bool added = false;
    setState(() {
      if (_remindedSlotIds.contains(slot.id)) {
        _remindedSlotIds.remove(slot.id);
        added = false;
      } else {
        _remindedSlotIds.add(slot.id);
        added = true;
      }
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: LiveLuxuryPalette.salonTileActive,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(
              color: LiveLuxuryPalette.hairlineMedium,
              width: 0.7,
            ),
          ),
          content: Text(
            added
                ? (ar
                    ? 'تم تفعيل التذكير لبرنامج: ${slot.title(true)}'
                    : 'Reminder set for: ${slot.title(false)}')
                : (ar ? 'تم إلغاء التذكير' : 'Reminder cancelled'),
            style: LiveBroadcastType.style(
              context,
              size: 13,
              weight: FontWeight.w500,
              color: LiveLuxuryPalette.textPrimary,
            ),
          ),
        ),
      );
  }

  void _scheduleHudAutoHide() {
    _hudHideTimer?.cancel();
    if (!_isPlaying) {
      return;
    }
    _hudHideTimer = Timer(_hudAutoHideDelay, () {
      if (!mounted || !_isPlaying) {
        return;
      }
      setState(() => _showHud = false);
      _notifyPlayerSync();
    });
  }

  void _revealHudTemporarily() {
    if (!_showHud) {
      setState(() => _showHud = true);
      _notifyPlayerSync();
    }
    _scheduleHudAutoHide();
  }

  void _toggleHudVisibility() {
    setState(() => _showHud = !_showHud);
    _notifyPlayerSync();
    if (_showHud) {
      _scheduleHudAutoHide();
    } else {
      _hudHideTimer?.cancel();
    }
  }

  Future<void> _loadChannel(
    LiveChannel channel, {
    bool showOsd = true,
    bool useFallbackUrl = false,
  }) async {
    final int gen = ++_loadGeneration;
    final VideoPlayerController? previous = _videoController;
    _videoController = null;

    if (mounted) {
      setState(() {
        _activeChannel = channel;
        _isVideoInitialized = false;
        _isLoadingStream = true;
        _hasStreamError = false;
        _showHud = true;
        if (showOsd) {
          _showOsdBanner = true;
        }
      });
      _notifyPlayerSync();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollActiveChannelIntoView();
      });
    }

    if (showOsd) {
      _osdTimer?.cancel();
      _osdTimer = Timer(const Duration(milliseconds: 2600), () {
        if (!mounted) {
          return;
        }
        setState(() => _showOsdBanner = false);
        _notifyPlayerSync();
      });
    }

    if (previous != null) {
      unawaited(previous.dispose());
    }

    final String targetUrl = useFallbackUrl
        ? LiveBroadcastCatalog.fallbackStreamUrl
        : channel.streamUrl;
    final VideoPlayerController controller =
        VideoPlayerController.networkUrl(Uri.parse(targetUrl));

    try {
      await controller.initialize().timeout(const Duration(seconds: 12));
      if (!mounted || gen != _loadGeneration) {
        await controller.dispose();
        return;
      }

      await controller.setLooping(true);

      bool startMuted = !_userUnmutedSession || _isMuted;
      if (!startMuted) {
        try {
          await controller.setVolume(_volume.clamp(0.0, 1.0));
          await controller.play();
        } catch (_) {
          startMuted = true;
        }
      }

      if (startMuted) {
        await controller.setVolume(0.0);
        await controller.play();
      }

      if (!useFallbackUrl && channel.initialSeekSeconds > 0) {
        final int totalSec = controller.value.duration.inSeconds;
        if (totalSec > channel.initialSeekSeconds + 2) {
          unawaited(
            controller.seekTo(Duration(seconds: channel.initialSeekSeconds)),
          );
        }
      }

      if (!mounted || gen != _loadGeneration) {
        await controller.dispose();
        return;
      }

      _videoController = controller;
      setState(() {
        _isMuted = startMuted;
        _isPlaying = true;
        _isVideoInitialized = true;
        _isLoadingStream = false;
        _hasStreamError = false;
      });
      _notifyPlayerSync();
      _scheduleHudAutoHide();
    } catch (_) {
      await controller.dispose();
      if (!mounted || gen != _loadGeneration) {
        return;
      }
      if (!useFallbackUrl) {
        await _loadChannel(channel, showOsd: false, useFallbackUrl: true);
        return;
      }
      setState(() {
        _isLoadingStream = false;
        _hasStreamError = true;
        _isVideoInitialized = false;
      });
      _notifyPlayerSync();
    }
  }

  Future<void> _unmuteFromPill() async {
    unawaited(HapticFeedback.lightImpact());
    final VideoPlayerController? ctrl = _videoController;
    _userUnmutedSession = true;
    final double targetVol = _volume <= 0.05 ? 1.0 : _volume;
    if (ctrl != null && _isVideoInitialized) {
      await ctrl.setVolume(targetVol);
      if (!ctrl.value.isPlaying) {
        await ctrl.play();
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _volume = targetVol;
      _isMuted = false;
      _isPlaying = true;
    });
    _notifyPlayerSync();
    _revealHudTemporarily();
  }

  Future<void> _toggleMute() async {
    unawaited(HapticFeedback.selectionClick());
    if (_isMuted) {
      await _unmuteFromPill();
      return;
    }
    final VideoPlayerController? ctrl = _videoController;
    if (ctrl != null && _isVideoInitialized) {
      await ctrl.setVolume(0.0);
    }
    if (!mounted) {
      return;
    }
    setState(() => _isMuted = true);
    _notifyPlayerSync();
    _revealHudTemporarily();
  }

  Future<void> _setVolumeLevel(double value) async {
    final double clamped = value.clamp(0.0, 1.0);
    final VideoPlayerController? ctrl = _videoController;
    _userUnmutedSession = clamped > 0.01;
    if (ctrl != null && _isVideoInitialized) {
      await ctrl.setVolume(clamped);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _volume = clamped;
      _isMuted = clamped <= 0.01;
    });
    _notifyPlayerSync();
    _revealHudTemporarily();
  }

  Future<void> _togglePlayPause() async {
    unawaited(HapticFeedback.selectionClick());
    final VideoPlayerController? ctrl = _videoController;
    if (ctrl == null || !_isVideoInitialized) {
      return;
    }
    if (ctrl.value.isPlaying) {
      await ctrl.pause();
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlaying = false;
        _showHud = true;
      });
      _hudHideTimer?.cancel();
    } else {
      await ctrl.play();
      if (!mounted) {
        return;
      }
      setState(() => _isPlaying = true);
      _scheduleHudAutoHide();
    }
    _notifyPlayerSync();
  }

  Future<void> _jumpToLiveEdge() async {
    unawaited(HapticFeedback.lightImpact());
    final VideoPlayerController? ctrl = _videoController;
    if (ctrl != null && _isVideoInitialized) {
      final int seekTarget = _activeChannel.initialSeekSeconds;
      if (ctrl.value.duration.inSeconds > seekTarget + 1) {
        await ctrl.seekTo(Duration(seconds: seekTarget));
      }
      if (!ctrl.value.isPlaying) {
        await ctrl.play();
      }
    }
    if (!mounted) {
      return;
    }
    setState(() => _isPlaying = true);
    _notifyPlayerSync();
    _revealHudTemporarily();
  }

  void _stepChannel(int delta) {
    unawaited(HapticFeedback.selectionClick());
    const List<LiveChannel> all = LiveBroadcastCatalog.channels;
    final int currentIdx =
        all.indexWhere((LiveChannel c) => c.id == _activeChannel.id);
    final int nextIdx =
        ((currentIdx < 0 ? 0 : currentIdx) + delta + all.length) % all.length;
    _loadChannel(all[nextIdx]);
  }

  void _selectCategory(LiveCategory category) {
    unawaited(HapticFeedback.selectionClick());
    if (_selectedCategory == category) {
      return;
    }
    setState(() => _selectedCategory = category);
    final List<LiveChannel> nextList = _filteredChannels;
    if (nextList.isNotEmpty &&
        !nextList.any((LiveChannel c) => c.id == _activeChannel.id)) {
      _loadChannel(nextList.first, showOsd: false);
    } else if (_railScrollCtrl.hasClients) {
      _railScrollCtrl.animateTo(
        0,
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollRailByCards(int direction, {required double stepExtent}) {
    if (!_railScrollCtrl.hasClients) {
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    final double maxExtent = _railScrollCtrl.position.maxScrollExtent;
    final double target =
        (_railScrollCtrl.offset + (direction * stepExtent)).clamp(0.0, maxExtent);
    _railScrollCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollActiveChannelIntoView() {
    if (!mounted || !_railScrollCtrl.hasClients) {
      return;
    }
    final List<LiveChannel> list = _filteredChannels;
    final int idx = list.indexWhere((LiveChannel c) => c.id == _activeChannel.id);
    if (idx < 0) {
      return;
    }
    final double viewport = _railScrollCtrl.position.viewportDimension;
    final double maxExtent = _railScrollCtrl.position.maxScrollExtent;
    if (maxExtent <= 0 || viewport <= 0) {
      return;
    }
    final bool isWide = MediaQuery.sizeOf(context).width >= 820;
    final double itemSpan = isWide ? (236.0 + 14.0) : (192.0 + 12.0);
    final double itemStart = idx * itemSpan;
    final double itemEnd = itemStart + itemSpan;
    final double currentOffset = _railScrollCtrl.offset;
    if (itemStart >= currentOffset && itemEnd <= currentOffset + viewport) {
      return;
    }
    final double centeredTarget =
        (itemStart - (viewport - itemSpan) * 0.35).clamp(0.0, maxExtent);
    _railScrollCtrl.animateTo(
      centeredTarget,
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  List<LiveChannel> get _filteredChannels {
    final String q = _searchQuery.trim().toLowerCase();
    return LiveBroadcastCatalog.channels.where((LiveChannel ch) {
      if (_selectedCategory == LiveCategory.favorites &&
          !_favoriteIds.contains(ch.id)) {
        return false;
      }
      if (_selectedCategory != LiveCategory.all &&
          _selectedCategory != LiveCategory.favorites &&
          ch.category != _selectedCategory) {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }
      final EpgSlot currentSlot = ch.buildSchedule(_now).first;
      final bool matchesName = ch.nameAr.toLowerCase().contains(q) ||
          ch.nameEn.toLowerCase().contains(q) ||
          ch.number.contains(q);
      final bool matchesProgram =
          currentSlot.titleAr.toLowerCase().contains(q) ||
              currentSlot.titleEn.toLowerCase().contains(q);
      final bool matchesMatch = ch.liveMatch != null &&
          (ch.liveMatch!.homeTeamAr.toLowerCase().contains(q) ||
              ch.liveMatch!.homeTeamEn.toLowerCase().contains(q) ||
              ch.liveMatch!.awayTeamAr.toLowerCase().contains(q) ||
              ch.liveMatch!.awayTeamEn.toLowerCase().contains(q) ||
              ch.liveMatch!.competitionAr.toLowerCase().contains(q) ||
              ch.liveMatch!.competitionEn.toLowerCase().contains(q));
      return matchesName || matchesProgram || matchesMatch;
    }).toList();
  }

  String get _formattedViewers {
    final double val =
        (_activeChannel.baseViewersK + _viewerDeltaK).clamp(1.0, 999.9);
    return '${val.toStringAsFixed(1)}K';
  }

  void _openQualitySheet(BuildContext sheetHostContext) {
    showModalBottomSheet<void>(
      context: sheetHostContext,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => QualityPickerSheet(
        selectedQuality: _selectedQuality,
        onSelect: (String q) {
          setState(() => _selectedQuality = q);
          _notifyPlayerSync();
          _revealHudTemporarily();
        },
      ),
    );
  }

  void _openScheduleSheet(BuildContext hostContext, {required bool fromFullscreen}) {
    unawaited(HapticFeedback.selectionClick());
    CinemaScheduleSheet.show(
      hostContext,
      channel: _activeChannel,
      now: _now,
      remindedSlotIds: _remindedSlotIds,
      onToggleReminder: _toggleSlotReminder,
      onWatchLive: fromFullscreen
          ? null
          : () => _openFullscreenPlayer(autoUnmute: true),
    );
  }

  Future<void> _openFullscreenPlayer({bool autoUnmute = true}) async {
    if (_isInFullscreen) {
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    if (autoUnmute && _isMuted) {
      unawaited(_unmuteFromPill());
    }
    setState(() {
      _isInFullscreen = true;
      _showHud = true;
    });
    _scheduleHudAutoHide();
    _notifyPlayerSync();

    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: AppDurations.medium,
        reverseTransitionDuration: AppDurations.normal,
        pageBuilder: (BuildContext ctx, Animation<double> anim, _) {
          return FadeTransition(
            opacity: anim,
            child: _FullscreenBroadcastPage(
              syncListenable: _playerSyncTick,
              stageBuilder: (BuildContext fullscreenCtx) =>
                  _buildFullscreenStage(fullscreenCtx),
            ),
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() => _isInFullscreen = false);
    _notifyPlayerSync();
  }

  @override
  void dispose() {
    _loadGeneration++;
    _clockTimer?.cancel();
    _hudHideTimer?.cancel();
    _osdTimer?.cancel();
    _studioAnimCtrl.dispose();
    _pulseAnimCtrl.dispose();
    _eqAnimCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    _railScrollCtrl.dispose();
    _playerSyncTick.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  //  Main Build — Full-Bleed Open Cinema Canvas (Design 4 + Design 5)
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    return Scaffold(
      backgroundColor: LiveLuxuryPalette.obsidianCanvas,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // ── Layer 0: Full-Bleed Live Video & Cinema Backdrop (100% W×H) ──
            _buildFullBleedBackdropAndVideo(),

            // ── Layer 1: Dual Cinematic Vignette (Design 4 + Design 5) ───────
            _buildDualCinematicVignette(),

            // ── Layer 2: Open Cinema Foreground (Top Bar + Hero + 16:9 Rail) ─
            SafeArea(
              bottom: canPop,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth;
                  final double height = constraints.maxHeight;
                  final bool isWide = width >= 820;
                  final bool isCompactHeight = height < 630;
                  final bool isUltraShort = height < 480;
                  final double hPad = isWide ? 38.0 : 18.0;

                  final Widget foregroundColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: isUltraShort ? 6 : (isCompactHeight ? 10 : 16),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: hPad),
                        child: _buildTopMinimalistBar(
                          context,
                          l10n: l10n,
                          canPop: canPop,
                          width: width,
                          isWide: isWide,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsetsDirectional.fromSTEB(
                              hPad,
                              isUltraShort ? 6 : 12,
                              hPad,
                              isUltraShort ? 6 : 12,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: _buildHeroSpotlight(
                                context,
                                l10n: l10n,
                                width: width,
                                isWide: isWide,
                                isCompactHeight: isCompactHeight,
                                isUltraShort: isUltraShort,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildBottomShowcaseRail(
                        context,
                        l10n: l10n,
                        hPad: hPad,
                        isWide: isWide,
                        isUltraShort: isUltraShort,
                      ),
                      SizedBox(
                        height: isUltraShort ? 6 : (isCompactHeight ? 10 : 14),
                      ),
                    ],
                  );

                  // Safety guard for extreme vertically shrunk windows (< 340px)
                  if (height < 340) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        height: 460,
                        child: foregroundColumn,
                      ),
                    );
                  }
                  return foregroundColumn;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Layer 0: 100% Edge-to-Edge Backdrop Photography + Smooth 600ms Video ──
  Widget _buildFullBleedBackdropAndVideo() {
    final VideoPlayerController? ctrl = _videoController;
    final bool hasValidSize =
        ctrl != null && _isVideoInitialized && !ctrl.value.size.isEmpty;
    final double videoW = hasValidSize ? ctrl.value.size.width : 1600.0;
    final double videoH = hasValidSize ? ctrl.value.size.height : 900.0;
    final bool showLiveVideo = !_isInFullscreen &&
        ctrl != null &&
        _isVideoInitialized &&
        !_hasStreamError;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Ambient Studio Canvas Fallback Underneath
        AnimatedStudioCanvas(
          channel: _activeChannel,
          animation: _studioAnimCtrl,
          isLoading: false,
          hasError: false,
          onRetry: () => _loadChannel(_activeChannel, showOsd: false),
        ),

        // Cross-Fading High-Res Cinema Backdrop Image
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 520),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: SizedBox.expand(
            key: ValueKey<String>(_activeChannel.backdropUrl),
            child: CachedNetworkImage(
              imageUrl: _activeChannel.backdropUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 280),
              placeholder: (BuildContext context, String _) =>
                  CinemaBackdropFallback(channel: _activeChannel),
              errorWidget: (BuildContext context, String _, Object __) =>
                  CinemaBackdropFallback(channel: _activeChannel),
            ),
          ),
        ),

        // Full-Bleed Live Video Surface (600ms Smooth Fade-In)
        AnimatedOpacity(
          opacity: showLiveVideo ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          child: showLiveVideo
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: videoW,
                      height: videoH,
                      child: VideoPlayer(ctrl),
                    ),
                  ),
                )
              : const SizedBox.expand(),
        ),
      ],
    );
  }

  // ── Layer 1: Dual Cinematic Vignette (Directional Horizontal + Vertical) ──
  Widget _buildDualCinematicVignette() {
    return const IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 1. Directional Horizontal Vignette: deep dark behind Hero text on Start
          //    side, crystal-clear open video/photography on End side!
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                stops: <double>[0.0, 0.35, 0.65, 1.0],
                colors: <Color>[
                  Color(0xF2050507),
                  Color(0xCC050507),
                  Color(0x47050507),
                  Color(0x12050507),
                ],
              ),
            ),
          ),

          // 2. Vertical Vignette: soft top bar protection + velvet #050505 floor
          //    merging seamlessly into the bottom showcase rail & nav bar!
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: <double>[0.0, 0.25, 0.64, 0.85, 1.0],
                colors: <Color>[
                  Color(0x99050507),
                  Color(0x00000000),
                  Color(0x8C050507),
                  Color(0xEB050507),
                  Color(0xFF050505),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Layer 2A: Top Minimalist Bar (Design 4 Underline Tabs + Glass Capsule) ─
  Widget _buildTopMinimalistBar(
    BuildContext context, {
    required AppLocalizations? l10n,
    required bool canPop,
    required double width,
    required bool isWide,
  }) {
    final bool ar = LiveBroadcastType.isAr(context);
    final bool isFav = _favoriteIds.contains(_activeChannel.id);
    final bool showExpandedMobileSearch = !isWide && _isMobileSearchOpen;

    return SizedBox(
      height: isWide ? 42 : 38,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (canPop) ...<Widget>[
            _GlassCircleIconBtn(
              icon: ar
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              size: isWide ? 36 : 34,
              iconSize: 14.5,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 10),
          ],

          if (showExpandedMobileSearch) ...<Widget>[
            Expanded(
              child: _buildGlassSearchCapsule(
                context,
                ar: ar,
                autofocus: true,
                onCloseMobileSearch: () {
                  _searchCtrl.clear();
                  _searchFocusNode.unfocus();
                  setState(() {
                    _searchQuery = '';
                    _isMobileSearchOpen = false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
          ] else ...<Widget>[
            // Sleek Compact Cinema Brand Emblem
            _buildCompactBrandLogo(context, showWordmark: width >= 620),
            SizedBox(width: isWide ? 24 : 12),

            // Clean Minimalist Category Text Tabs (Zero Boxes, 2px Underline)
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: ar ? Alignment.centerRight : Alignment.centerLeft,
                    end: ar ? Alignment.centerLeft : Alignment.centerRight,
                    stops: const <double>[0.0, 0.02, 0.92, 1.0],
                    colors: const <Color>[
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: const <PointerDeviceKind>{
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    itemCount: LiveCategory.values.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: isWide ? 22 : 15),
                    itemBuilder: (BuildContext context, int index) {
                      final LiveCategory cat = LiveCategory.values[index];
                      final bool selected = _selectedCategory == cat;
                      return _MinimalCategoryTab(
                        label: cat.label(context, l10n),
                        isSelected: selected,
                        isWide: isWide,
                        onTap: () => _selectCategory(cat),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // End-Side Controls: Capsule Search (210px on Wide, Icon Trigger on Mobile)
            if (isWide) ...<Widget>[
              SizedBox(
                width: 210,
                height: 36,
                child: _buildGlassSearchCapsule(context, ar: ar),
              ),
              const SizedBox(width: 10),
            ] else ...<Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  _GlassCircleIconBtn(
                    icon: Icons.search_rounded,
                    size: 34,
                    iconSize: 16.5,
                    isActive: _searchQuery.isNotEmpty,
                    onTap: () {
                      unawaited(HapticFeedback.selectionClick());
                      setState(() => _isMobileSearchOpen = true);
                    },
                  ),
                  if (_searchQuery.isNotEmpty)
                    PositionedDirectional(
                      top: 1,
                      end: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: LiveLuxuryPalette.crimsonActiveRim,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ],

          // Background Live Audio Mute / Unmute Glass Circle Button
          _GlassCircleIconBtn(
            icon: _isMuted
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
            size: isWide ? 36 : 34,
            iconSize: 17,
            isActive: !_isMuted,
            onTap: _toggleMute,
          ),
          SizedBox(width: isWide ? 9 : 7),

          // Active Channel Favorite Heart Glass Circle Button
          _GlassCircleIconBtn(
            icon: isFav
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            size: isWide ? 36 : 34,
            iconSize: 16.5,
            iconColor:
                isFav ? LiveLuxuryPalette.crimsonActiveRim : Colors.white,
            isActive: isFav,
            activeBorderColor:
                LiveLuxuryPalette.crimsonActiveRim.withValues(alpha: 0.48),
            onTap: () => _toggleFavorite(_activeChannel),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBrandLogo(
    BuildContext context, {
    required bool showWordmark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(9)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                LiveLuxuryPalette.crimsonCtaStart,
                LiveLuxuryPalette.crimsonCtaEnd,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x59E50914),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 19,
          ),
        ),
        if (showWordmark) ...<Widget>[
          const SizedBox(width: 9),
          Text(
            'SKYLIVE',
            style: LiveBroadcastType.style(
              context,
              size: 14.5,
              weight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.1,
              display: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGlassSearchCapsule(
    BuildContext context, {
    required bool ar,
    bool autofocus = false,
    VoidCallback? onCloseMobileSearch,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          height: 36,
          decoration: BoxDecoration(
            color:
                Colors.white.withValues(alpha: _isSearchFocused ? 0.11 : 0.07),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            border: Border.all(
              color: Colors.white
                  .withValues(alpha: _isSearchFocused ? 0.30 : 0.16),
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _searchCtrl,
            focusNode: _searchFocusNode,
            autofocus: autofocus,
            onChanged: (String value) => setState(() => _searchQuery = value),
            style: LiveBroadcastType.style(
              context,
              size: 12.5,
              weight: FontWeight.w500,
              color: Colors.white,
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              hintText: ar ? 'ابحث عن قناة أو عرض...' : 'Search live TV...',
              hintStyle: LiveBroadcastType.style(
                context,
                size: 12,
                weight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.56),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.70),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 34,
              ),
              suffixIcon:
                  (_searchQuery.isNotEmpty || onCloseMobileSearch != null)
                      ? GestureDetector(
                          onTap: () {
                            if (onCloseMobileSearch != null &&
                                _searchQuery.isEmpty) {
                              onCloseMobileSearch();
                            } else {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                              if (onCloseMobileSearch != null) {
                                onCloseMobileSearch();
                              }
                            }
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        )
                      : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Layer 2B: Open Floating Hero Spotlight (Zero Background Box!) ──────────
  Widget _buildHeroSpotlight(
    BuildContext context, {
    required AppLocalizations? l10n,
    required double width,
    required bool isWide,
    required bool isCompactHeight,
    required bool isUltraShort,
  }) {
    final bool ar = LiveBroadcastType.isAr(context);
    final List<EpgSlot> slots = _activeChannel.buildSchedule(_now);
    final EpgSlot currentSlot = slots.first;
    final int remainingMins = currentSlot.remainingMinutesAt(_now);
    final LiveMatchInfo? match = _activeChannel.liveMatch;
    final String qualityLabel = _selectedQuality == 'Auto'
        ? _activeChannel.qualityTag
        : _selectedQuality;

    final double titleFontSize = isWide
        ? (isCompactHeight ? 36.0 : 42.0)
        : (isUltraShort ? 24.0 : (isCompactHeight ? 26.5 : 29.5));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 340),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> anim) {
        final Animation<Offset> slide = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).animate(anim);
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Column(
        key: ValueKey<String>('${_activeChannel.id}_${currentSlot.id}'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Precision Frosted-Glass Metadata Capsules Row (Design 4)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              // Pulsing • LIVE Capsule
              AnimatedBuilder(
                animation: _pulseAnimCtrl,
                builder: (BuildContext context, _) {
                  return _HeroGlassPill(
                    maxWidth: width - 48,
                    borderColor: LiveLuxuryPalette.crimsonActiveRim
                        .withValues(alpha: 0.42),
                    backgroundColor:
                        LiveLuxuryPalette.rubyLive.withValues(alpha: 0.18),
                    leading: Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LiveLuxuryPalette.crimsonActiveRim.withValues(
                          alpha: 0.65 + 0.35 * _pulseAnimCtrl.value,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: LiveLuxuryPalette.crimsonActiveRim
                                .withValues(alpha: 0.55),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    label: ar ? 'مباشر' : 'LIVE',
                  );
                },
              ),

              // 4K HDR Quality Capsule (Interactive Picker)
              _HeroGlassPill(
                maxWidth: width - 48,
                label: qualityLabel,
                onTap: () => _openQualitySheet(context),
              ),

              // Live Match Score Capsule OR Category + Audio Capsule
              if (match != null)
                _HeroGlassPill(
                  maxWidth: width - 48,
                  leading: const Icon(
                    Icons.sports_soccer_rounded,
                    size: 12.5,
                    color: LiveLuxuryPalette.warmNowStreaming,
                  ),
                  label: match.summaryPill(ar),
                  tabular: true,
                )
              else ...<Widget>[
                _HeroGlassPill(
                  maxWidth: width - 48,
                  label: _activeChannel.category.label(context, l10n),
                ),
                if (isWide)
                  _HeroGlassPill(
                    maxWidth: width - 48,
                    label: _activeChannel.audioTag(ar),
                  ),
              ],
            ],
          ),

          SizedBox(height: isUltraShort ? 8 : 13),

          // 2. Bold Cinematic Hero Title (36–44px Web / 26–30px Mobile, w900)
          Text(
            currentSlot.title(ar),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: LiveBroadcastType.style(
              context,
              size: titleFontSize,
              weight: FontWeight.w900,
              color: Colors.white,
              height: ar ? 1.16 : 1.06,
              letterSpacing: ar ? 0.0 : -0.9,
              display: true,
            ).copyWith(
              shadows: const <Shadow>[
                Shadow(
                  color: Color(0xB3000000),
                  blurRadius: 22,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),

          SizedBox(height: isUltraShort ? 6 : 10),

          // 3. Warm HBO "Now Streaming" Status Line (#F5A623 + Channel + Time Left)
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: ar ? 'يبث الآن مباشر' : 'Now Streaming',
                  style: LiveBroadcastType.style(
                    context,
                    size: isWide ? 13.5 : 12.5,
                    weight: FontWeight.w700,
                    color: LiveLuxuryPalette.warmNowStreaming,
                  ),
                ),
                TextSpan(
                  text:
                      '  •  ${_activeChannel.name(ar)}  •  ${ar ? 'المتبقي $remainingMins دقيقة' : '$remainingMins min left'}',
                  style: LiveBroadcastType.style(
                    context,
                    size: isWide ? 13.5 : 12.5,
                    weight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.90),
                    tabular: true,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isUltraShort ? 6 : 10),

          // 4. Calm Silver Cinematic Synopsis (#B0B4C0, 14px, max 2 lines)
          Text(
            currentSlot.description(ar),
            maxLines: isUltraShort ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: LiveBroadcastType.style(
              context,
              size: isWide ? 14.0 : 13.2,
              weight: FontWeight.w400,
              color: LiveLuxuryPalette.cinemaSilver,
              height: 1.48,
            ).copyWith(
              shadows: const <Shadow>[
                Shadow(
                  color: Color(0x99000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),

          SizedBox(height: isUltraShort ? 12 : (isCompactHeight ? 16 : 22)),

          // 5. Iconic SlothUI Design 4 Action Button Pair
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              // Primary Crimson Pill Button (#FF1E2D -> #D90712 + Soft Red Glow)
              _PrimaryCrimsonCtaBtn(
                label: ar ? 'شاهد البث الحي' : 'Watch Live Stream',
                compact: isCompactHeight,
                onTap: () => _openFullscreenPlayer(autoUnmute: true),
              ),

              // Secondary Frosted Glass Pill Button (white 8% + border white 20%)
              _SecondaryGlassCtaBtn(
                label: ar ? 'جدول البرامج' : 'Program Schedule',
                compact: isCompactHeight,
                onTap: () => _openScheduleSheet(context, fromFullscreen: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Layer 2C: Bottom 16:9 Glowing Showcase Rail (Design 4) ─────────────────
  Widget _buildBottomShowcaseRail(
    BuildContext context, {
    required AppLocalizations? l10n,
    required double hPad,
    required bool isWide,
    required bool isUltraShort,
  }) {
    final bool ar = LiveBroadcastType.isAr(context);
    final List<LiveChannel> filtered = _filteredChannels;
    final double cardWidth = isWide ? 236.0 : (isUltraShort ? 168.0 : 192.0);
    final double cardHeight = isWide ? 134.0 : (isUltraShort ? 96.0 : 112.0);
    final double gap = isWide ? 14.0 : 12.0;

    final String railHeading = _selectedCategory == LiveCategory.all
        ? (ar ? 'جميع القنوات المباشرة' : 'All Live Channels')
        : (ar
            ? 'جميع القنوات المباشرة  •  ${_selectedCategory.label(context, l10n)}'
            : 'All Live Channels  •  ${_selectedCategory.label(context, l10n)}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Showcase Header Row: Title on Start + Thin Circular < > Arrows on End
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: hPad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        railHeading,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LiveBroadcastType.style(
                          context,
                          size: isWide ? 15.5 : 14.0,
                          weight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: ar ? 0.0 : -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${filtered.length})',
                      style: LiveBroadcastType.style(
                        context,
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: LiveLuxuryPalette.silverSecondary,
                        tabular: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RailArrowBtn(
                icon: ar
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_left_rounded,
                onTap: () => _scrollRailByCards(
                  -1,
                  stepExtent: (cardWidth + gap) * 2,
                ),
              ),
              const SizedBox(width: 8),
              _RailArrowBtn(
                icon: ar
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                onTap: () => _scrollRailByCards(
                  1,
                  stepExtent: (cardWidth + gap) * 2,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: isUltraShort ? 6 : 8),

        // 16:9 Glowing Showcase Cards Rail (Mouse + Touch + Trackpad)
        SizedBox(
          height: cardHeight + 16,
          child: filtered.isEmpty
              ? Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(hPad, 6, hPad, 8),
                  child: _buildEmptyRailState(context, ar: ar),
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: const <PointerDeviceKind>{
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: ListView.separated(
                    controller: _railScrollCtrl,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: EdgeInsetsDirectional.fromSTEB(hPad, 6, hPad, 10),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => SizedBox(width: gap),
                    itemBuilder: (BuildContext context, int index) {
                      final LiveChannel channel = filtered[index];
                      final bool isSelected = channel.id == _activeChannel.id;
                      return CinemaChannelCard(
                        channel: channel,
                        now: _now,
                        isSelected: isSelected,
                        width: cardWidth,
                        height: cardHeight,
                        isFavorite: _favoriteIds.contains(channel.id),
                        onToggleFavorite: () => _toggleFavorite(channel),
                        onTap: () {
                          if (!isSelected) {
                            unawaited(HapticFeedback.selectionClick());
                            _loadChannel(channel);
                          } else {
                            _openFullscreenPlayer(autoUnmute: true);
                          }
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyRailState(BuildContext context, {required bool ar}) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.tv_off_rounded,
                size: 20,
                color: LiveLuxuryPalette.cinemaSilver,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  ar
                      ? 'لا توجد قنوات مطابقة للبحث أو الفئة المختارة'
                      : 'No channels match your search or category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LiveBroadcastType.style(
                    context,
                    size: 13,
                    weight: FontWeight.w500,
                    color: LiveLuxuryPalette.cinemaSilver,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = LiveCategory.all;
                    _isMobileSearchOpen = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    ar ? 'عرض الكل' : 'Reset',
                    style: LiveBroadcastType.style(
                      context,
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  //  Immersive Fullscreen Broadcast Stage & Clean Smoked-Glass HUD
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildFullscreenStage(BuildContext stageContext) {
    final VideoPlayerController? ctrl = _videoController;
    final bool hasValidSize =
        ctrl != null && _isVideoInitialized && !ctrl.value.size.isEmpty;
    final double videoW = hasValidSize ? ctrl.value.size.width : 1600.0;
    final double videoH = hasValidSize ? ctrl.value.size.height : 900.0;
    final bool showLiveVideo =
        ctrl != null && _isVideoInitialized && !_hasStreamError;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints stageBox) {
        final bool wideHud = stageBox.maxWidth >= 560;

        return MouseRegion(
          onHover: (_) => _revealHudTemporarily(),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Backdrop Image + Studio Canvas Spinner/Error Handling
              CachedNetworkImage(
                imageUrl: _activeChannel.backdropUrl,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String _) =>
                    CinemaBackdropFallback(channel: _activeChannel),
                errorWidget: (BuildContext context, String _, Object __) =>
                    CinemaBackdropFallback(channel: _activeChannel),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: showLiveVideo ? 0.0 : 0.45,
                  ),
                ),
              ),
              if ((_isLoadingStream && !_isVideoInitialized) || _hasStreamError)
                AnimatedStudioCanvas(
                  animation: _studioAnimCtrl,
                  channel: _activeChannel,
                  isLoading: _isLoadingStream && !_isVideoInitialized,
                  hasError: _hasStreamError,
                  onRetry: () => _loadChannel(_activeChannel, showOsd: false),
                ),

              // Hardware-Accelerated Video Surface (Smooth 600ms Fade)
              AnimatedOpacity(
                opacity: showLiveVideo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                child: showLiveVideo
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: _fillScreen ? BoxFit.cover : BoxFit.contain,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: videoW,
                            height: videoH,
                            child: VideoPlayer(ctrl),
                          ),
                        ),
                      )
                    : const SizedBox.expand(),
              ),

              // Tap Surface to Toggle HUD
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleHudVisibility,
                child: const SizedBox.expand(),
              ),

              // Quick OSD Zapping Banner when HUD is Auto-Hidden
              if (_showOsdBanner && !_showHud)
                PositionedDirectional(
                  top: 20,
                  start: 24,
                  child: _buildOsdBanner(stageContext),
                ),

              // Auto-Hiding Smoked-Glass Broadcast HUD
              IgnorePointer(
                ignoring: !_showHud,
                child: AnimatedOpacity(
                  opacity: _showHud ? 1.0 : 0.0,
                  duration: AppDurations.normal,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: <double>[0.0, 0.24, 0.72, 1.0],
                        colors: <Color>[
                          Color(0xB3000000),
                          Color(0x0D000000),
                          Color(0x14000000),
                          Color(0xCC000000),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        wideHud ? 28 : 16,
                        wideHud ? 22 : 14,
                        wideHud ? 28 : 16,
                        wideHud ? 22 : 14,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildFullscreenHudTopBar(
                            stageContext,
                            wideHud: wideHud,
                          ),
                          if (_isVideoInitialized &&
                              !_isLoadingStream &&
                              !_hasStreamError)
                            _buildFullscreenHudCenterControls(wideHud: wideHud)
                          else
                            const SizedBox.shrink(),
                          _buildFullscreenHudBottomBar(
                            stageContext,
                            wideHud: wideHud,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Independent Tap-to-Unmute Pill if Muted Inside Fullscreen
              if (_isMuted && _isVideoInitialized && !_hasStreamError)
                PositionedDirectional(
                  bottom: _showHud ? 74 : 20,
                  start: wideHud ? 28 : 16,
                  child: FloatingUnmutePill(
                    pulseAnimation: _pulseAnimCtrl,
                    onTap: _unmuteFromPill,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOsdBanner(BuildContext context) {
    final bool ar = LiveBroadcastType.isAr(context);
    final EpgSlot current = _activeChannel.buildSchedule(_now).first;

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: LiveLuxuryPalette.velvetHudGlass,
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            border: Border.all(
              color: LiveLuxuryPalette.hairlineMedium,
              width: 0.7,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              NetworkEmblem(
                channel: _activeChannel,
                size: 32,
                borderRadius: 8,
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'CH ${_activeChannel.number}  •  ${_activeChannel.name(ar)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LiveBroadcastType.style(
                        context,
                        size: 12,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        tabular: true,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      current.title(ar),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LiveBroadcastType.style(
                        context,
                        size: 11,
                        weight: FontWeight.w400,
                        color: LiveLuxuryPalette.cinemaSilver,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenHudTopBar(
    BuildContext stageContext, {
    required bool wideHud,
  }) {
    final bool ar = LiveBroadcastType.isAr(stageContext);
    final EpgSlot current = _activeChannel.buildSchedule(_now).first;
    final String qualityLabel = _selectedQuality == 'Auto'
        ? _activeChannel.qualityTag
        : _selectedQuality;

    return Row(
      children: <Widget>[
        NetworkEmblem(channel: _activeChannel, size: 34, borderRadius: 8),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'CH ${_activeChannel.number}  •  ${_activeChannel.name(ar)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LiveBroadcastType.style(
                  stageContext,
                  size: wideHud ? 14.5 : 13,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  tabular: true,
                ),
              ),
              Text(
                current.title(ar),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LiveBroadcastType.style(
                  stageContext,
                  size: 11.5,
                  weight: FontWeight.w400,
                  color: LiveLuxuryPalette.cinemaSilver,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Pulsing • LIVE Badge
        AnimatedBuilder(
          animation: _pulseAnimCtrl,
          builder: (BuildContext context, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xB8121216),
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                border: Border.all(
                  color: LiveLuxuryPalette.crimsonActiveRim
                      .withValues(alpha: 0.45),
                  width: 0.7,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LiveLuxuryPalette.crimsonActiveRim.withValues(
                        alpha: 0.65 + 0.35 * _pulseAnimCtrl.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ar ? 'مباشر' : 'LIVE',
                    style: LiveBroadcastType.style(
                      stageContext,
                      size: 10.5,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Spacer(),

        if (wideHud) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0x9E101014),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              border: Border.all(
                color: LiveLuxuryPalette.hairlineSubtle,
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.visibility_outlined,
                  size: 13.5,
                  color: LiveLuxuryPalette.cinemaSilver,
                ),
                const SizedBox(width: 5),
                Text(
                  _formattedViewers,
                  style: LiveBroadcastType.style(
                    stageContext,
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    tabular: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Quality Selector Pill
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _openQualitySheet(stageContext),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xB8121216),
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                border: Border.all(
                  color: LiveLuxuryPalette.hairlineMedium,
                  width: 0.7,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    qualityLabel,
                    style: LiveBroadcastType.style(
                      stageContext,
                      size: 11,
                      weight: FontWeight.w700,
                      color: LiveLuxuryPalette.champagneSoft,
                      tabular: true,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.tune_rounded,
                    size: 12,
                    color: LiveLuxuryPalette.champagneSoft,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // On-Demand Schedule Sheet Trigger inside Fullscreen
        _HudCircleBtn(
          icon: Icons.calendar_month_rounded,
          size: 36,
          iconSize: 16.5,
          onTap: () => _openScheduleSheet(stageContext, fromFullscreen: true),
        ),
        const SizedBox(width: 8),

        // Close Fullscreen Button
        _HudCircleBtn(
          icon: Icons.close_rounded,
          size: 36,
          iconSize: 18.5,
          onTap: () => Navigator.of(stageContext).maybePop(),
        ),
      ],
    );
  }

  Widget _buildFullscreenHudCenterControls({required bool wideHud}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _HudCircleBtn(
          icon: Icons.skip_previous_rounded,
          size: wideHud ? 46 : 40,
          iconSize: wideHud ? 24 : 20,
          onTap: () => _stepChannel(-1),
        ),
        SizedBox(width: wideHud ? 26 : 18),
        _HudCircleBtn(
          icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: wideHud ? 60 : 50,
          iconSize: wideHud ? 30 : 26,
          isPrimary: true,
          onTap: _togglePlayPause,
        ),
        SizedBox(width: wideHud ? 26 : 18),
        _HudCircleBtn(
          icon: Icons.skip_next_rounded,
          size: wideHud ? 46 : 40,
          iconSize: wideHud ? 24 : 20,
          onTap: () => _stepChannel(1),
        ),
      ],
    );
  }

  Widget _buildFullscreenHudBottomBar(
    BuildContext stageContext, {
    required bool wideHud,
  }) {
    final bool ar = LiveBroadcastType.isAr(stageContext);
    final EpgSlot current = _activeChannel.buildSchedule(_now).first;
    final double progress = current.progressAt(_now);
    final bool audioActive = _isVideoInitialized && _isPlaying && !_isMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Sleek 2.2px Crimson-Tipped Broadcast Progress Hairline
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: Container(
            height: 2.2,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.16),
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      LiveLuxuryPalette.crimsonCtaStart,
                      LiveLuxuryPalette.crimsonActiveRim,
                    ],
                  ),
                ),
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            _HudCircleBtn(
              icon: _isMuted
                  ? Icons.volume_off_rounded
                  : (_volume < 0.5
                      ? Icons.volume_down_rounded
                      : Icons.volume_up_rounded),
              size: 36,
              iconSize: 18,
              onTap: _toggleMute,
            ),
            if (wideHud) ...<Widget>[
              SizedBox(
                width: 96,
                height: 28,
                child: SliderTheme(
                  data: SliderTheme.of(stageContext).copyWith(
                    trackHeight: 2.2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: Colors.white.withValues(alpha: 0.90),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: _isMuted ? 0.0 : _volume,
                    onChanged: _setVolumeLevel,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            EqualizerBars(
              animation: _eqAnimCtrl,
              isActive: audioActive,
              color: const Color(0xFFE0E0EA),
              height: 13,
              barWidth: 2.0,
            ),
            const Spacer(),

            // Jump to Live Edge Pill
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _jumpToLiveEdge,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xB8121216),
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    border: Border.all(
                      color: LiveLuxuryPalette.hairlineSubtle,
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 5.5,
                        height: 5.5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: LiveLuxuryPalette.crimsonActiveRim,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        ar ? 'اللحظة الحية' : 'LIVE EDGE',
                        style: LiveBroadcastType.style(
                          stageContext,
                          size: 10.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Fit / Cover Aspect Ratio Toggle
            _HudCircleBtn(
              icon: _fillScreen
                  ? Icons.fit_screen_rounded
                  : Icons.aspect_ratio_rounded,
              size: 36,
              iconSize: 17,
              onTap: () {
                setState(() => _fillScreen = !_fillScreen);
                _notifyPlayerSync();
                _revealHudTemporarily();
              },
            ),
            const SizedBox(width: 8),

            // Exit Fullscreen Button
            _HudCircleBtn(
              icon: Icons.fullscreen_exit_rounded,
              size: 36,
              iconSize: 19,
              onTap: () => Navigator.of(stageContext).maybePop(),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Supporting Cinema Micro-Components (Design 4 + Design 5)
// ─────────────────────────────────────────────────────────────────────────────

class _MinimalCategoryTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isWide;
  final VoidCallback onTap;

  const _MinimalCategoryTab({
    required this.label,
    required this.isSelected,
    required this.isWide,
    required this.onTap,
  });

  @override
  State<_MinimalCategoryTab> createState() => _MinimalCategoryTabState();
}

class _MinimalCategoryTabState extends State<_MinimalCategoryTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isSelected
        ? Colors.white
        : (_hovered
            ? Colors.white.withValues(alpha: 0.88)
            : LiveLuxuryPalette.cinemaSilver.withValues(alpha: 0.78));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.label,
              style: LiveBroadcastType.style(
                context,
                size: widget.isWide ? 13.5 : 12.8,
                weight: widget.isSelected ? FontWeight.w800 : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: AppDurations.normal,
              curve: Curves.easeOutCubic,
              height: 2.0,
              width: widget.isSelected ? 22.0 : 0.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                gradient: const LinearGradient(
                  colors: <Color>[
                    Colors.white,
                    LiveLuxuryPalette.crimsonActiveRim,
                  ],
                ),
                boxShadow: widget.isSelected
                    ? const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x80FF2A3C),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCircleIconBtn extends StatefulWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color iconColor;
  final bool isActive;
  final Color? activeBorderColor;
  final VoidCallback onTap;

  const _GlassCircleIconBtn({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onTap,
    this.iconColor = Colors.white,
    this.isActive = false,
    this.activeBorderColor,
  });

  @override
  State<_GlassCircleIconBtn> createState() => _GlassCircleIconBtnState();
}

class _GlassCircleIconBtnState extends State<_GlassCircleIconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = widget.isActive
        ? (widget.activeBorderColor ?? Colors.white.withValues(alpha: 0.34))
        : Colors.white.withValues(alpha: _hovered ? 0.28 : 0.16);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: _hovered ? 0.14 : (widget.isActive ? 0.12 : 0.07),
                ),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroGlassPill extends StatelessWidget {
  final String label;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? borderColor;
  final double maxWidth;
  final bool tabular;
  final VoidCallback? onTap;

  const _HeroGlassPill({
    required this.label,
    required this.maxWidth,
    this.leading,
    this.backgroundColor,
    this.borderColor,
    this.tabular = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget pill = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.18),
                width: 0.85,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LiveBroadcastType.style(
                      context,
                      size: 11.2,
                      weight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.95),
                      tabular: tabular,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap == null) {
      return pill;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: pill),
    );
  }
}

class _PrimaryCrimsonCtaBtn extends StatefulWidget {
  final String label;
  final bool compact;
  final VoidCallback onTap;

  const _PrimaryCrimsonCtaBtn({
    required this.label,
    required this.compact,
    required this.onTap,
  });

  @override
  State<_PrimaryCrimsonCtaBtn> createState() => _PrimaryCrimsonCtaBtnState();
}

class _PrimaryCrimsonCtaBtnState extends State<_PrimaryCrimsonCtaBtn> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.97 : (_hovered ? 1.025 : 1.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: AppDurations.fast,
          curve: Curves.easeOutCubic,
          child: Container(
            height: widget.compact ? 42 : 46,
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 20 : 24,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  LiveLuxuryPalette.crimsonCtaStart,
                  LiveLuxuryPalette.crimsonCtaEnd,
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: LiveLuxuryPalette.crimsonCtaStart.withValues(
                    alpha: _hovered ? 0.52 : 0.38,
                  ),
                  blurRadius: _hovered ? 26 : 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 21,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: LiveBroadcastType.style(
                    context,
                    size: widget.compact ? 13.2 : 14.0,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryGlassCtaBtn extends StatefulWidget {
  final String label;
  final bool compact;
  final VoidCallback onTap;

  const _SecondaryGlassCtaBtn({
    required this.label,
    required this.compact,
    required this.onTap,
  });

  @override
  State<_SecondaryGlassCtaBtn> createState() => _SecondaryGlassCtaBtnState();
}

class _SecondaryGlassCtaBtnState extends State<_SecondaryGlassCtaBtn> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.97 : (_hovered ? 1.02 : 1.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: AppDurations.fast,
          curve: Curves.easeOutCubic,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                height: widget.compact ? 42 : 46,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 18 : 22,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: _hovered ? 0.13 : 0.08),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  border: Border.all(
                    color:
                        Colors.white.withValues(alpha: _hovered ? 0.30 : 0.20),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white.withValues(alpha: 0.92),
                      size: 16.5,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: LiveBroadcastType.style(
                        context,
                        size: widget.compact ? 13.0 : 13.8,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailArrowBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RailArrowBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_RailArrowBtn> createState() => _RailArrowBtnState();
}

class _RailArrowBtnState extends State<_RailArrowBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: _hovered ? 0.14 : 0.06),
            border: Border.all(
              color: Colors.white.withValues(alpha: _hovered ? 0.32 : 0.18),
              width: 0.9,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: 18,
            color: Colors.white.withValues(alpha: _hovered ? 1.0 : 0.85),
          ),
        ),
      ),
    );
  }
}

class _HudCircleBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final bool isPrimary;
  final VoidCallback onTap;

  const _HudCircleBtn({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPrimary
                    ? LiveLuxuryPalette.crimsonCtaStart.withValues(alpha: 0.88)
                    : LiveLuxuryPalette.velvetHudGlass,
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: isPrimary ? 0.30 : 0.16,
                  ),
                  width: isPrimary ? 1.0 : 0.7,
                ),
                boxShadow: isPrimary
                    ? const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x66FF1E2D),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: iconSize, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenBroadcastPage extends StatelessWidget {
  final ValueNotifier<int> syncListenable;
  final WidgetBuilder stageBuilder;

  const _FullscreenBroadcastPage({
    required this.syncListenable,
    required this.stageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: syncListenable,
          builder: (BuildContext ctx, _, __) {
            return SizedBox.expand(child: stageBuilder(ctx));
          },
        ),
      ),
    );
  }
}
