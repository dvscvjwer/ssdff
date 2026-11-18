import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/live_broadcast_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  LiveTvScreen v4.0 — Quiet Luxury Edition (Apple TV+ & B&O Restraint)
//  Responsive Split-View (>= 960px) & Sticky Cinema Stage (< 960px)
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
  int _mobileTabIndex = 0;
  String _selectedQuality = 'Auto';
  bool _fillScreen = true;

  final Set<String> _favoriteIds = <String>{
    'bein_1_premium',
    'sky_sports_pl',
    'hbo_max_live',
  };
  final Set<String> _remindedSlotIds = <String>{};

  // Video & Browser-Safe Autoplay State
  VideoPlayerController? _videoController;
  int _loadGeneration = 0;
  bool _isVideoInitialized = false;
  bool _isLoadingStream = true;
  bool _hasStreamError = false;
  bool _isPlaying = true;
  bool _isMuted = true;
  bool _userUnmutedSession = false;
  double _volume = 1.0;

  // HUD, OSD & Live Clock State
  bool _showHud = true;
  bool _showOsdBanner = false;
  DateTime _now = DateTime.now();
  double _viewerDeltaK = 0.0;

  late final AnimationController _studioAnimCtrl;
  late final AnimationController _pulseAnimCtrl;
  late final AnimationController _eqAnimCtrl;
  late final TextEditingController _searchCtrl;
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
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _eqAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
    _searchCtrl = TextEditingController();

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
      // Ignore storage write issues in restricted web incognito sessions.
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
              width: 0.6,
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
    _playerSyncTick.dispose();
    _videoController?.dispose();
    super.dispose();
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

  void _openFullscreenPlayer() {
    unawaited(HapticFeedback.lightImpact());
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: AppDurations.medium,
        reverseTransitionDuration: AppDurations.normal,
        pageBuilder: (BuildContext ctx, Animation<double> anim, _) {
          return FadeTransition(
            opacity: anim,
            child: _FullscreenBroadcastPage(
              syncListenable: _playerSyncTick,
              stageBuilder: (BuildContext fullscreenCtx) => _buildPlayerStage(
                fullscreenCtx,
                isFullscreen: true,
                borderRadius: 0,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    return Scaffold(
      backgroundColor: LiveLuxuryPalette.obsidianCanvas,
      body: SafeArea(
        bottom: canPop,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth >= 960;
            return Column(
              children: <Widget>[
                _buildTopHeader(
                  context,
                  l10n: l10n,
                  canPop: canPop,
                  isWide: isWide,
                ),
                Expanded(
                  child: isWide
                      ? _buildWideSplitLayout(
                          context,
                          l10n: l10n,
                          canPop: canPop,
                          constraints: constraints,
                        )
                      : _buildCompactMobileLayout(
                          context,
                          l10n: l10n,
                          canPop: canPop,
                          constraints: constraints,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Quiet Luxury Editorial Top Header (Zero Marketing Clutter) ────────────
  Widget _buildTopHeader(
    BuildContext context, {
    required AppLocalizations? l10n,
    required bool canPop,
    required bool isWide,
  }) {
    final bool ar = LiveBroadcastType.isAr(context);
    final bool favActive = _selectedCategory == LiveCategory.favorites;

    return Container(
      height: isWide ? 56 : 50,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: isWide ? 26 : 16,
        vertical: 6,
      ),
      child: Row(
        children: <Widget>[
          if (canPop) ...<Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: const BorderRadius.all(Radius.circular(11)),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: LiveLuxuryPalette.salonTile,
                    borderRadius: const BorderRadius.all(Radius.circular(11)),
                    border: Border.all(
                      color: LiveLuxuryPalette.hairlineSubtle,
                      width: 0.6,
                    ),
                  ),
                  child: Icon(
                    ar
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    size: 15,
                    color: LiveLuxuryPalette.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Calm Ruby Broadcast Indicator Dot
          AnimatedBuilder(
            animation: _pulseAnimCtrl,
            builder: (BuildContext context, _) {
              return Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LiveLuxuryPalette.rubyLive.withValues(
                    alpha: 0.68 + 0.32 * _pulseAnimCtrl.value,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: LiveLuxuryPalette.rubyLive.withValues(alpha: 0.42),
                      blurRadius: 8,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),

          // Editorial Title
          Flexible(
            child: Text(
              l10n?.liveTvTitle ?? (ar ? 'البث المباشر' : 'Live TV'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LiveBroadcastType.style(
                context,
                size: isWide ? 20 : 18,
                weight: FontWeight.w800,
                color: LiveLuxuryPalette.textPrimary,
                letterSpacing: ar ? 0.0 : -0.3,
                display: true,
              ),
            ),
          ),
          const Spacer(),

          // Unboxed Platinum Digital Clock
          Text(
            EpgSlot.formatClock(_now),
            style: LiveBroadcastType.style(
              context,
              size: 13.5,
              weight: FontWeight.w500,
              color: LiveLuxuryPalette.silverSecondary,
              letterSpacing: 0.4,
              tabular: true,
            ),
          ),
          const SizedBox(width: 12),

          // Refined Glass Favorites Filter Pill
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                setState(() {
                  _selectedCategory =
                      favActive ? LiveCategory.all : LiveCategory.favorites;
                  if (!isWide) {
                    _mobileTabIndex = 0;
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(17)),
              child: AnimatedContainer(
                duration: AppDurations.normal,
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: favActive
                      ? LiveLuxuryPalette.rubyLive.withValues(alpha: 0.14)
                      : LiveLuxuryPalette.salonTile,
                  borderRadius: const BorderRadius.all(Radius.circular(17)),
                  border: Border.all(
                    color: favActive
                        ? LiveLuxuryPalette.rubyLive.withValues(alpha: 0.36)
                        : LiveLuxuryPalette.hairlineSubtle,
                    width: favActive ? 0.75 : 0.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      favActive
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 15,
                      color: favActive
                          ? LiveLuxuryPalette.rubyLive
                          : LiveLuxuryPalette.silverSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_favoriteIds.length}',
                      style: LiveBroadcastType.style(
                        context,
                        size: 12,
                        weight: favActive ? FontWeight.w700 : FontWeight.w600,
                        color: favActive
                            ? LiveLuxuryPalette.textPrimary
                            : LiveLuxuryPalette.silverSecondary,
                        tabular: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Wide Web / Desktop Split-View Cockpit (width >= 960px, gap: 20px) ─────
  Widget _buildWideSplitLayout(
    BuildContext context, {
    required AppLocalizations? l10n,
    required bool canPop,
    required BoxConstraints constraints,
  }) {
    final List<EpgSlot> slots = _activeChannel.buildSchedule(_now);
    final EpgSlot currentSlot = slots.first;
    final EpgSlot nextSlot = slots.length > 1 ? slots[1] : slots.first;
    final double maxPlayerHeight =
        (constraints.maxHeight * 0.54).clamp(260.0, 500.0);
    final double stageWidth = (constraints.maxWidth - 72) * 0.62;
    final double playerHeight =
        math.min(stageWidth * 9.0 / 16.0, maxPlayerHeight);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        26,
        6,
        26,
        canPop ? 18 : 22,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Main Cinema Stage + Editorial Program & Match Details (62%)
          Expanded(
            flex: 62,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: playerHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(18)),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.09),
                        width: 0.6,
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x99000000),
                          blurRadius: 36,
                          offset: Offset(0, 16),
                        ),
                        ...AppShadows.card,
                      ],
                    ),
                    child: _buildPlayerStage(
                      context,
                      isFullscreen: false,
                      borderRadius: 17.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ActiveProgramCard(
                    channel: _activeChannel,
                    currentSlot: currentSlot,
                    nextSlot: nextSlot,
                    now: _now,
                    isFavorite: _favoriteIds.contains(_activeChannel.id),
                    onToggleFavorite: () => _toggleFavorite(_activeChannel),
                  ),
                  if (_activeChannel.liveMatch != null) ...<Widget>[
                    const SizedBox(height: 14),
                    LiveMatchScorebugCard(
                      match: _activeChannel.liveMatch!,
                      pulseAnimation: _pulseAnimCtrl,
                    ),
                  ],
                  const SizedBox(height: 16),
                  BroadcastScheduleStrip(
                    channel: _activeChannel,
                    slots: slots,
                    now: _now,
                    remindedSlotIds: _remindedSlotIds,
                    onToggleReminder: _toggleSlotReminder,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Smoked Obsidian Salon Guide Sidebar (38%)
          Expanded(
            flex: 38,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                decoration: BoxDecoration(
                  color: LiveLuxuryPalette.smokedPanel,
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                  border: Border.all(
                    color: LiveLuxuryPalette.hairlineSubtle,
                    width: 0.6,
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: _buildGuidePanel(
                  context,
                  l10n: l10n,
                  isWide: true,
                  bottomPad: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile & Portrait Tablet Sticky Stage Layout (width < 960px) ──────────
  Widget _buildCompactMobileLayout(
    BuildContext context, {
    required AppLocalizations? l10n,
    required bool canPop,
    required BoxConstraints constraints,
  }) {
    final List<EpgSlot> slots = _activeChannel.buildSchedule(_now);
    final EpgSlot currentSlot = slots.first;
    final EpgSlot nextSlot = slots.length > 1 ? slots[1] : slots.first;
    final double stickyMaxHeight =
        (constraints.maxHeight * 0.34).clamp(185.0, 290.0);

    return Column(
      children: <Widget>[
        // Sticky Top Frameless OLED Player Stage
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: stickyMaxHeight),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.09),
                    width: 0.6,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x85000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: _buildPlayerStage(
                  context,
                  isFullscreen: false,
                  borderRadius: 17.4,
                ),
              ),
            ),
          ),
        ),

        // Live Match Quick Ribbon (Sports Channels)
        if (_activeChannel.liveMatch != null)
          CompactMatchRibbon(
            match: _activeChannel.liveMatch!,
            pulseAnimation: _pulseAnimCtrl,
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              setState(() => _mobileTabIndex = 1);
            },
          ),

        // Quiet Luxury Segmented Switcher
        _buildMobileSegmentedTabs(context),

        // Active Tab Body
        Expanded(
          child: _mobileTabIndex == 0
              ? _buildGuidePanel(
                  context,
                  l10n: l10n,
                  isWide: false,
                  bottomPad: canPop ? 18 : 26,
                )
              : SingleChildScrollView(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    14,
                    4,
                    14,
                    canPop ? 18 : 26,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ActiveProgramCard(
                        channel: _activeChannel,
                        currentSlot: currentSlot,
                        nextSlot: nextSlot,
                        now: _now,
                        isFavorite: _favoriteIds.contains(_activeChannel.id),
                        onToggleFavorite: () => _toggleFavorite(_activeChannel),
                      ),
                      if (_activeChannel.liveMatch != null) ...<Widget>[
                        const SizedBox(height: 14),
                        LiveMatchScorebugCard(
                          match: _activeChannel.liveMatch!,
                          pulseAnimation: _pulseAnimCtrl,
                        ),
                      ],
                      const SizedBox(height: 16),
                      BroadcastScheduleStrip(
                        channel: _activeChannel,
                        slots: slots,
                        now: _now,
                        remindedSlotIds: _remindedSlotIds,
                        onToggleReminder: _toggleSlotReminder,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMobileSegmentedTabs(BuildContext context) {
    final bool ar = LiveBroadcastType.isAr(context);
    final int count = _filteredChannels.length;
    final List<String> labels = <String>[
      ar ? 'دليل القنوات ($count)' : 'Live Channels ($count)',
      ar ? 'تفاصيل البث والجدول' : 'Program & Match Info',
    ];

    return Container(
      height: 40,
      margin: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LiveLuxuryPalette.smokedPanel,
        borderRadius: const BorderRadius.all(Radius.circular(13)),
        border: Border.all(
          color: LiveLuxuryPalette.hairlineSubtle,
          width: 0.6,
        ),
      ),
      child: Row(
        children: List<Widget>.generate(2, (int idx) {
          final bool active = _mobileTabIndex == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                setState(() => _mobileTabIndex = idx);
              },
              child: AnimatedContainer(
                duration: AppDurations.normal,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF1F1F27) : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: active
                      ? Border.all(
                          color: LiveLuxuryPalette.hairlineMedium,
                          width: 0.6,
                        )
                      : null,
                ),
                child: Text(
                  labels[idx],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LiveBroadcastType.style(
                    context,
                    size: 12,
                    weight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? LiveLuxuryPalette.textPrimary
                        : LiveLuxuryPalette.silverSecondary,
                    tabular: true,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Interactive Salon Guide Panel (Velvet Search + ShaderMask Categories) ─
  Widget _buildGuidePanel(
    BuildContext context, {
    required AppLocalizations? l10n,
    required bool isWide,
    required double bottomPad,
  }) {
    final bool ar = LiveBroadcastType.isAr(context);
    final List<LiveChannel> filtered = _filteredChannels;
    final bool audioActive = _isVideoInitialized && _isPlaying && !_isMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            16,
            isWide ? 16 : 4,
            16,
            10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isWide) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n?.liveTvGuide ??
                            (ar ? 'دليل القنوات المباشرة' : 'Live TV Guide'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LiveBroadcastType.style(
                          context,
                          size: 15.5,
                          weight: FontWeight.w700,
                          color: LiveLuxuryPalette.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      ar ? '${filtered.length} قناة' : '${filtered.length} CH',
                      style: LiveBroadcastType.style(
                        context,
                        size: 12,
                        weight: FontWeight.w500,
                        color: LiveLuxuryPalette.silverMuted,
                        tabular: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Velvet Hairline Search Input
              SizedBox(
                height: 42,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (String v) => setState(() => _searchQuery = v),
                  style: LiveBroadcastType.style(
                    context,
                    size: 13,
                    weight: FontWeight.w500,
                    color: LiveLuxuryPalette.textPrimary,
                  ),
                  cursorColor: Colors.white70,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: LiveLuxuryPalette.salonTile,
                    hintText: ar
                        ? 'ابحث عن قناة، برنامج، أو مباراة...'
                        : 'Search channel, show, or live match...',
                    hintStyle: LiveBroadcastType.style(
                      context,
                      size: 12.5,
                      weight: FontWeight.w400,
                      color: LiveLuxuryPalette.silverMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: LiveLuxuryPalette.silverMuted,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: LiveLuxuryPalette.silverSecondary,
                            ),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                      borderSide: BorderSide(
                        color: LiveLuxuryPalette.hairlineSubtle,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                      borderSide: BorderSide(
                        color: LiveLuxuryPalette.hairlineMedium,
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Seamless Edge-Faded Category Strip (Mouse + Touch Drag)
        SizedBox(
          height: 34,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: ar ? Alignment.centerRight : Alignment.centerLeft,
                end: ar ? Alignment.centerLeft : Alignment.centerRight,
                stops: const <double>[0.0, 0.025, 0.90, 1.0],
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
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 24, 0),
                itemCount: LiveCategory.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final LiveCategory cat = LiveCategory.values[index];
                  final bool selected = _selectedCategory == cat;
                  final Color iconColor = selected
                      ? (cat == LiveCategory.favorites
                          ? LiveLuxuryPalette.rubyLive
                          : LiveLuxuryPalette.textPrimary)
                      : LiveLuxuryPalette.silverMuted;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        unawaited(HapticFeedback.selectionClick());
                        setState(() => _selectedCategory = cat);
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(17)),
                      child: AnimatedContainer(
                        duration: AppDurations.normal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF22222A)
                              : LiveLuxuryPalette.salonTile,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(17)),
                          border: Border.all(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.22)
                                : LiveLuxuryPalette.hairlineSubtle,
                            width: selected ? 0.7 : 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(cat.icon, size: 13.5, color: iconColor),
                            const SizedBox(width: 6),
                            Text(
                              cat.label(context, l10n),
                              style: LiveBroadcastType.style(
                                context,
                                size: 11.5,
                                weight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? LiveLuxuryPalette.textPrimary
                                    : LiveLuxuryPalette.silverSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filtered Salon Channels List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.tv_off_rounded,
                          size: 36,
                          color: LiveLuxuryPalette.silverMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.liveNoChannelsInCategory ??
                              (ar
                                  ? 'لا توجد قنوات مطابقة للفلتر الحالي'
                                  : 'No channels match your current filter'),
                          textAlign: TextAlign.center,
                          style: LiveBroadcastType.style(
                            context,
                            size: 13,
                            weight: FontWeight.w500,
                            color: LiveLuxuryPalette.silverSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = LiveCategory.all;
                              });
                            },
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: LiveLuxuryPalette.salonTileActive,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(18)),
                                border: Border.all(
                                  color: LiveLuxuryPalette.hairlineMedium,
                                  width: 0.6,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(
                                    Icons.restart_alt_rounded,
                                    size: 15,
                                    color: LiveLuxuryPalette.textPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    ar
                                        ? 'عرض جميع القنوات'
                                        : 'Show All Channels',
                                    style: LiveBroadcastType.style(
                                      context,
                                      size: 12,
                                      weight: FontWeight.w600,
                                      color: LiveLuxuryPalette.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    14,
                    2,
                    14,
                    bottomPad,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final LiveChannel channel = filtered[index];
                    final bool isSelected = channel.id == _activeChannel.id;
                    return EpgChannelTile(
                      channel: channel,
                      now: _now,
                      isSelected: isSelected,
                      isPlayingAudio: isSelected && audioActive,
                      isFavorite: _favoriteIds.contains(channel.id),
                      equalizerAnim: _eqAnimCtrl,
                      onTap: () {
                        if (!isSelected) {
                          _loadChannel(channel);
                        } else {
                          _revealHudTemporarily();
                        }
                      },
                      onToggleFavorite: () => _toggleFavorite(channel),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── 4-Layer Frameless Cinema Player Stage ─────────────────────────────────
  Widget _buildPlayerStage(
    BuildContext stageContext, {
    required bool isFullscreen,
    required double borderRadius,
  }) {
    final VideoPlayerController? ctrl = _videoController;
    final bool hasValidSize =
        ctrl != null && _isVideoInitialized && !ctrl.value.size.isEmpty;
    final double videoW = hasValidSize ? ctrl.value.size.width : 1600.0;
    final double videoH = hasValidSize ? ctrl.value.size.height : 900.0;

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints stageBox) {
          final bool wideHud = stageBox.maxWidth >= 520;

          return MouseRegion(
            onHover: (_) => _revealHudTemporarily(),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // Layer 0: Velvet Studio Backdrop (Zero Black Box)
                AnimatedStudioCanvas(
                  animation: _studioAnimCtrl,
                  channel: _activeChannel,
                  isLoading: _isLoadingStream && !_isVideoInitialized,
                  hasError: _hasStreamError,
                  onRetry: () => _loadChannel(_activeChannel, showOsd: false),
                ),

                // Layer 1: Hardware-Accelerated Video Surface
                if (ctrl != null)
                  AnimatedOpacity(
                    opacity: _isVideoInitialized ? 1.0 : 0.0,
                    duration: AppDurations.medium,
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: _fillScreen ? BoxFit.cover : BoxFit.contain,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: videoW,
                          height: videoH,
                          child: VideoPlayer(ctrl),
                        ),
                      ),
                    ),
                  ),

                // Tap Surface to Toggle Frameless HUD
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _toggleHudVisibility,
                  child: const SizedBox.expand(),
                ),

                // OSD Quick Channel Zapping Banner (when HUD is hidden)
                if (_showOsdBanner && !_showHud)
                  PositionedDirectional(
                    top: 14,
                    start: 14,
                    child: _buildOsdBanner(stageContext),
                  ),

                // Layer 3: Auto-Hide Frameless Cinema HUD (2600ms)
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
                            Color(0xA6000000),
                            Color(0x0A000000),
                            Color(0x14000000),
                            Color(0xBF000000),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          isFullscreen ? 26 : 14,
                          isFullscreen ? 22 : 12,
                          isFullscreen ? 26 : 14,
                          isFullscreen ? 20 : 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _buildHudTopBar(
                              stageContext,
                              isFullscreen: isFullscreen,
                              wideHud: wideHud,
                            ),
                            if (_isVideoInitialized &&
                                !_isLoadingStream &&
                                !_hasStreamError)
                              _buildHudCenterControls(
                                stageContext,
                                wideHud: wideHud,
                              )
                            else
                              const SizedBox.shrink(),
                            _buildHudBottomBar(
                              stageContext,
                              isFullscreen: isFullscreen,
                              wideHud: wideHud,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer 4: Independent Smoked Glass Unmute Pill (Always Clickable)
                if (_isMuted && _isVideoInitialized && !_hasStreamError)
                  PositionedDirectional(
                    bottom: _showHud ? (isFullscreen ? 68 : 54) : 14,
                    start: isFullscreen ? 26 : 14,
                    child: FloatingUnmutePill(
                      pulseAnimation: _pulseAnimCtrl,
                      onTap: _unmuteFromPill,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: LiveLuxuryPalette.velvetHudGlass,
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            border: Border.all(
              color: LiveLuxuryPalette.hairlineMedium,
              width: 0.6,
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
                constraints: const BoxConstraints(maxWidth: 230),
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
                        color: LiveLuxuryPalette.textPrimary,
                        tabular: true,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      current.title(ar),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LiveBroadcastType.style(
                        context,
                        size: 10.5,
                        weight: FontWeight.w400,
                        color: LiveLuxuryPalette.silverSecondary,
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

  Widget _buildHudTopBar(
    BuildContext stageContext, {
    required bool isFullscreen,
    required bool wideHud,
  }) {
    final bool ar = LiveBroadcastType.isAr(stageContext);
    final EpgSlot current = _activeChannel.buildSchedule(_now).first;
    final String qualityLabel = _selectedQuality == 'Auto'
        ? _activeChannel.qualityTag
        : _selectedQuality;

    return Row(
      children: <Widget>[
        NetworkEmblem(channel: _activeChannel, size: 30, borderRadius: 8),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _activeChannel.name(ar),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LiveBroadcastType.style(
                  stageContext,
                  size: wideHud ? 14 : 12.5,
                  weight: FontWeight.w700,
                  color: LiveLuxuryPalette.textPrimary,
                ),
              ),
              if (isFullscreen)
                Text(
                  current.title(ar),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LiveBroadcastType.style(
                    stageContext,
                    size: 11.5,
                    weight: FontWeight.w400,
                    color: LiveLuxuryPalette.silverSecondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Smoked Glass • LIVE Pill (Restrained Ruby Dot)
        AnimatedBuilder(
          animation: _pulseAnimCtrl,
          builder: (BuildContext context, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
              decoration: BoxDecoration(
                color: const Color(0xB8121216),
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                border: Border.all(
                  color: LiveLuxuryPalette.hairlineMedium,
                  width: 0.55,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 5.5,
                    height: 5.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LiveLuxuryPalette.rubyLive.withValues(
                        alpha: 0.65 + 0.35 * _pulseAnimCtrl.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ar ? 'مباشر' : 'LIVE',
                    style: LiveBroadcastType.style(
                      stageContext,
                      size: 10,
                      weight: FontWeight.w700,
                      color: LiveLuxuryPalette.textPrimary,
                      letterSpacing: ar ? 0.0 : 0.7,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Spacer(),

        // Calm Platinum Viewers Readout (Zero Neon Cyan)
        if (wideHud) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x9E101014),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              border: Border.all(
                color: LiveLuxuryPalette.hairlineSubtle,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.visibility_outlined,
                  size: 13,
                  color: LiveLuxuryPalette.silverSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  _formattedViewers,
                  style: LiveBroadcastType.style(
                    stageContext,
                    size: 11,
                    weight: FontWeight.w500,
                    color: const Color(0xFFC4C4CE),
                    tabular: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Smoked Glass Quality Selector (Soft Champagne Typography)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _openQualitySheet(stageContext),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xB8121216),
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                border: Border.all(
                  color: LiveLuxuryPalette.hairlineMedium,
                  width: 0.6,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    qualityLabel,
                    style: LiveBroadcastType.style(
                      stageContext,
                      size: 10.5,
                      weight: FontWeight.w700,
                      color: LiveLuxuryPalette.champagneSoft,
                      letterSpacing: 0.3,
                      tabular: true,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.tune_rounded,
                    size: 11.5,
                    color: LiveLuxuryPalette.champagneSoft,
                  ),
                ],
              ),
            ),
          ),
        ),

        if (isFullscreen) ...<Widget>[
          const SizedBox(width: 8),
          _HudCircleBtn(
            icon: Icons.close_rounded,
            size: 34,
            iconSize: 17.5,
            onTap: () => Navigator.of(stageContext).maybePop(),
          ),
        ],
      ],
    );
  }

  Widget _buildHudCenterControls(
    BuildContext stageContext, {
    required bool wideHud,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _HudCircleBtn(
          icon: Icons.skip_previous_rounded,
          size: wideHud ? 42 : 38,
          iconSize: wideHud ? 22 : 19,
          onTap: () => _stepChannel(-1),
        ),
        SizedBox(width: wideHud ? 24 : 16),
        _HudCircleBtn(
          icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: wideHud ? 56 : 48,
          iconSize: wideHud ? 28 : 24,
          isPrimary: true,
          onTap: _togglePlayPause,
        ),
        SizedBox(width: wideHud ? 24 : 16),
        _HudCircleBtn(
          icon: Icons.skip_next_rounded,
          size: wideHud ? 42 : 38,
          iconSize: wideHud ? 22 : 19,
          onTap: () => _stepChannel(1),
        ),
      ],
    );
  }

  Widget _buildHudBottomBar(
    BuildContext stageContext, {
    required bool isFullscreen,
    required bool wideHud,
  }) {
    final bool ar = LiveBroadcastType.isAr(stageContext);
    final EpgSlot current = _activeChannel.buildSchedule(_now).first;
    final double progress = current.progressAt(_now);
    final bool audioActive = _isVideoInitialized && _isPlaying && !_isMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Ultra-Thin 2px Monochrome Luxury Progress Hairline (Zero Rainbow)
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: Container(
            height: 2.0,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.14),
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: const ColoredBox(
                color: Color(0xEBFFFFFF),
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            _HudCircleBtn(
              icon: _isMuted
                  ? Icons.volume_off_rounded
                  : (_volume < 0.5
                      ? Icons.volume_down_rounded
                      : Icons.volume_up_rounded),
              size: 34,
              iconSize: 17.5,
              onTap: _toggleMute,
            ),
            if (wideHud) ...<Widget>[
              SizedBox(
                width: 90,
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
                    activeTrackColor: Colors.white.withValues(alpha: 0.88),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.20),
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
              color: const Color(0xFFD8D8E2),
              height: 12,
              barWidth: 1.8,
            ),
            const Spacer(),

            // Smoked Glass Live Edge Pill
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _jumpToLiveEdge,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
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
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: LiveLuxuryPalette.rubyLive,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        ar ? 'اللحظة الحية' : 'LIVE EDGE',
                        style: LiveBroadcastType.style(
                          stageContext,
                          size: 10,
                          weight: FontWeight.w700,
                          color: const Color(0xFFE6E6EE),
                          letterSpacing: ar ? 0.0 : 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),

            // Fit / Cover Aspect Ratio Toggle
            _HudCircleBtn(
              icon: _fillScreen
                  ? Icons.fit_screen_rounded
                  : Icons.aspect_ratio_rounded,
              size: 34,
              iconSize: 16.5,
              onTap: () {
                setState(() => _fillScreen = !_fillScreen);
                _notifyPlayerSync();
                _revealHudTemporarily();
              },
            ),
            const SizedBox(width: 7),

            // Fullscreen Toggle
            _HudCircleBtn(
              icon: isFullscreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              size: 34,
              iconSize: 18.5,
              onTap: isFullscreen
                  ? () => Navigator.of(stageContext).maybePop()
                  : _openFullscreenPlayer,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Smoked Obsidian Liquid-Glass HUD Circle Button & Fullscreen Stage
// ─────────────────────────────────────────────────────────────────────────────

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
                    ? const Color(0xCF14141A)
                    : LiveLuxuryPalette.velvetHudGlass,
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: isPrimary ? 0.22 : 0.14,
                  ),
                  width: isPrimary ? 0.75 : 0.6,
                ),
                boxShadow: isPrimary
                    ? const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x73000000),
                          blurRadius: 18,
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
