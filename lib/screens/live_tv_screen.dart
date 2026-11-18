import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/live_broadcast_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  LiveTvScreen v3.0 — World-Class Responsive Split-View & Broadcast Player
// ─────────────────────────────────────────────────────────────────────────────

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen>
    with TickerProviderStateMixin {
  static const String _prefsFavoritesKey = 'skylive_live_favorites_v3';

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
      duration: const Duration(seconds: 6),
    )..repeat();
    _pulseAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _eqAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    final bool added;
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
          content: Text(
            added
                ? (ar
                    ? 'تم تفعيل التذكير لبرنامج: ${slot.title(true)}'
                    : 'Reminder set for: ${slot.title(false)}')
                : (ar ? 'تم إلغاء التذكير' : 'Reminder cancelled'),
            style: LiveBroadcastType.style(context, size: 13),
          ),
        ),
      );
  }

  void _scheduleHudAutoHide() {
    _hudHideTimer?.cancel();
    if (!_isPlaying) {
      return;
    }
    _hudHideTimer = Timer(const Duration(milliseconds: 3500), () {
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

      if (!useFallbackUrl && channel.initialSeekSeconds > 0) {
        final int totalSec = controller.value.duration.inSeconds;
        if (totalSec > channel.initialSeekSeconds + 2) {
          await controller.seekTo(
            Duration(seconds: channel.initialSeekSeconds),
          );
        }
      }

      if (!mounted || gen != _loadGeneration) {
        await controller.dispose();
        return;
      }

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
      backgroundColor: AppColors.surfaceModal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      backgroundColor: AppColors.background,
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
                  maxWidth: constraints.maxWidth,
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

  // ── Top Broadcast Status Header ────────────────────────────────────────────
  Widget _buildTopHeader(
    BuildContext context, {
    required AppLocalizations? l10n,
    required bool canPop,
    required double maxWidth,
    required bool isWide,
  }) {
    final bool ar = LiveBroadcastType.isAr(context);
    final bool favActive = _selectedCategory == LiveCategory.favorites;

    return Container(
      height: isWide ? 54 : 48,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: isWide ? 24 : 14,
        vertical: 6,
      ),
      child: Row(
        children: <Widget>[
          if (canPop) ...<Widget>[
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(
                  ar
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          AnimatedBuilder(
            animation: _pulseAnimCtrl,
            builder: (BuildContext context, _) {
              return Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withValues(
                    alpha: 0.65 + 0.35 * _pulseAnimCtrl.value,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: AppColors.glowRed, blurRadius: 10),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              l10n?.liveTvTitle ?? (ar ? 'البث المباشر' : 'Live TV'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LiveBroadcastType.style(
                context,
                size: isWide ? 20 : 17.5,
                weight: FontWeight.w800,
                display: true,
              ),
            ),
          ),
          if (maxWidth >= 540) ...<Widget>[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                  color: AppColors.accentCyan.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                ar
                    ? '${LiveBroadcastCatalog.channels.length} قناة مباشرة • استجابة فورية'
                    : '${LiveBroadcastCatalog.channels.length} LIVE • ULTRA LOW LATENCY',
                style: LiveBroadcastType.style(
                  context,
                  size: 10.5,
                  weight: FontWeight.w700,
                  color: AppColors.accentCyan,
                  tabular: true,
                ),
              ),
            ),
          ],
          const Spacer(),

          // Quick Favorites Toggle Pill
          InkWell(
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              setState(() {
                _selectedCategory = favActive
                    ? LiveCategory.all
                    : LiveCategory.favorites;
                if (!isWide) {
                  _mobileTabIndex = 0;
                }
              });
            },
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: AnimatedContainer(
              duration: AppDurations.normal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: favActive
                    ? AppColors.primary.withValues(alpha: 0.22)
                    : AppColors.surfaceAlt,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                  color: favActive ? AppColors.primary : AppColors.cardBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: favActive
                        ? AppColors.primaryLight
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${_favoriteIds.length}',
                    style: LiveBroadcastType.style(
                      context,
                      size: 11.5,
                      weight: FontWeight.w700,
                      tabular: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Live Broadcast Clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.access_time_filled_rounded,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  EpgSlot.formatClock(_now),
                  style: LiveBroadcastType.style(
                    context,
                    size: 12,
                    weight: FontWeight.w700,
                    tabular: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Wide Web / Desktop Split-View Cockpit (width >= 960px) ────────────────
  Widget _buildWideSplitLayout(
    BuildContext context, {
    required AppLocalizations? l10n,
    required bool canPop,
    required BoxConstraints constraints,
  }) {
    final List<EpgSlot> slots = _activeChannel.buildSchedule(_now);
    final double maxPlayerHeight =
        (constraints.maxHeight * 0.54).clamp(260.0, 500.0);
    final double stageWidth = (constraints.maxWidth - 64) * 0.62;
    final double playerHeight =
        math.min(stageWidth * 9.0 / 16.0, maxPlayerHeight);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        24,
        4,
        24,
        canPop ? 16 : 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Main Cinema Stage + Live Match + Timeline (62%)
          Expanded(
            flex: 62,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: playerHeight,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(18)),
                      border: Border.all(
                        color:
                            _activeChannel.brandPrimary.withValues(alpha: 0.42),
                        width: 1.2,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: _activeChannel.brandPrimary
                              .withValues(alpha: 0.24),
                          blurRadius: 42,
                          spreadRadius: 1,
                          offset: const Offset(0, 12),
                        ),
                        ...AppShadows.card,
                      ],
                    ),
                    child: _buildPlayerStage(
                      context,
                      isFullscreen: false,
                      borderRadius: 17,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ActiveProgramCard(
                    channel: _activeChannel,
                    currentSlot: slots[0],
                    nextSlot: slots[1],
                    now: _now,
                    isFavorite: _favoriteIds.contains(_activeChannel.id),
                    onToggleFavorite: () => _toggleFavorite(_activeChannel),
                    onPrevChannel: () => _stepChannel(-1),
                    onNextChannel: () => _stepChannel(1),
                  ),
                  if (_activeChannel.liveMatch != null) ...<Widget>[
                    const SizedBox(height: 12),
                    LiveMatchScorebugCard(
                      match: _activeChannel.liveMatch!,
                      pulseAnimation: _pulseAnimCtrl,
                    ),
                  ],
                  const SizedBox(height: 14),
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
          const SizedBox(width: 16),

          // Interactive TV Guide Sidebar (38%)
          Expanded(
            flex: 38,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppShadows.card,
                ),
                child: _buildGuidePanel(
                  context,
                  l10n: l10n,
                  isWide: true,
                  bottomPad: 14,
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
    final double stickyMaxHeight =
        (constraints.maxHeight * 0.34).clamp(185.0, 290.0);

    return Column(
      children: <Widget>[
        // Sticky Top Broadcast Player Stage
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 2, 12, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: stickyMaxHeight),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(
                    color: _activeChannel.brandPrimary.withValues(alpha: 0.42),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color:
                          _activeChannel.brandPrimary.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _buildPlayerStage(
                  context,
                  isFullscreen: false,
                  borderRadius: 14,
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

        // Segmented Switcher: Live Channels vs Program & Match Info
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
                        currentSlot: slots[0],
                        nextSlot: slots[1],
                        now: _now,
                        isFavorite: _favoriteIds.contains(_activeChannel.id),
                        onToggleFavorite: () => _toggleFavorite(_activeChannel),
                        onPrevChannel: () => _stepChannel(-1),
                        onNextChannel: () => _stepChannel(1),
                      ),
                      if (_activeChannel.liveMatch != null) ...<Widget>[
                        const SizedBox(height: 12),
                        LiveMatchScorebugCard(
                          match: _activeChannel.liveMatch!,
                          pulseAnimation: _pulseAnimCtrl,
                        ),
                      ],
                      const SizedBox(height: 14),
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
      margin: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 6),
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: AppColors.cardBorder),
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
                  gradient: active
                      ? const LinearGradient(
                          colors: <Color>[
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                        )
                      : null,
                  borderRadius: const BorderRadius.all(Radius.circular(9)),
                ),
                child: Text(
                  labels[idx],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LiveBroadcastType.style(
                    context,
                    size: 12,
                    weight: active ? FontWeight.w800 : FontWeight.w600,
                    color:
                        active ? Colors.white : AppColors.textSecondary,
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

  // ── Interactive TV Guide Panel (Search + Category Pills + Channel List) ───
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
            14,
            isWide ? 14 : 4,
            14,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isWide) ...<Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.live_tv_rounded,
                      size: 18,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n?.liveTvGuide ??
                            (ar ? 'دليل القنوات المباشرة' : 'Live TV Guide'),
                        style: LiveBroadcastType.style(
                          context,
                          size: 16,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        '${filtered.length}',
                        style: LiveBroadcastType.style(
                          context,
                          size: 11.5,
                          weight: FontWeight.w800,
                          color: AppColors.accentCyan,
                          tabular: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Instant Search Input
              SizedBox(
                height: 42,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (String v) => setState(() => _searchQuery = v),
                  style: LiveBroadcastType.style(
                    context,
                    size: 13,
                    weight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    hintText: ar
                        ? 'ابحث عن قناة، برنامج، أو مباراة...'
                        : 'Search channel, show, or live match...',
                    hintStyle: LiveBroadcastType.style(
                      context,
                      size: 12.5,
                      weight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 19,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 17,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Category Filter Chips
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: LiveCategory.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 7),
                  itemBuilder: (BuildContext context, int index) {
                    final LiveCategory cat = LiveCategory.values[index];
                    final bool selected = _selectedCategory == cat;
                    return InkWell(
                      onTap: () {
                        unawaited(HapticFeedback.selectionClick());
                        setState(() => _selectedCategory = cat);
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(18)),
                      child: AnimatedContainer(
                        duration: AppDurations.normal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(
                                  colors: <Color>[
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                )
                              : null,
                          color: selected ? null : AppColors.surfaceAlt,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(18)),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryLight
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              cat.icon,
                              size: 14,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.label(context, l10n),
                              style: LiveBroadcastType.style(
                                context,
                                size: 11.5,
                                weight:
                                    selected ? FontWeight.w800 : FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Filtered Channels List
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
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n?.liveNoChannelsInCategory ??
                              (ar
                                  ? 'لا توجد قنوات مطابقة للفلتر الحالي'
                                  : 'No channels match your current filter'),
                          textAlign: TextAlign.center,
                          style: LiveBroadcastType.style(
                            context,
                            size: 13.5,
                            weight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = LiveCategory.all;
                            });
                          },
                          icon: const Icon(Icons.restart_alt_rounded, size: 17),
                          label: Text(
                            ar ? 'عرض جميع القنوات' : 'Show All Channels',
                            style: LiveBroadcastType.style(
                              context,
                              size: 12.5,
                              weight: FontWeight.w700,
                              color: AppColors.accentCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    12,
                    2,
                    12,
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

  // ── 4-Layer Bulletproof Broadcast Player Stage ────────────────────────────
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
                // Layer 0: Animated Broadcast Studio Backdrop (Zero Black Box)
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

                // Tap Surface to Toggle HUD
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

                // Layer 3: Auto-Hide Broadcast HUD Controls
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
                          stops: <double>[0.0, 0.28, 0.68, 1.0],
                          colors: <Color>[
                            Color(0xBD000000),
                            Color(0x1F000000),
                            Color(0x2E000000),
                            Color(0xD6000000),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          isFullscreen ? 24 : 14,
                          isFullscreen ? 20 : 12,
                          isFullscreen ? 24 : 14,
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
                            _buildHudCenterControls(
                              stageContext,
                              wideHud: wideHud,
                            ),
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

                // Layer 2/4: Independent Floating Unmute Pill (Always Clickable)
                if (_isMuted && _isVideoInitialized && !_hasStreamError)
                  PositionedDirectional(
                    bottom: _showHud ? (isFullscreen ? 68 : 54) : 14,
                    start: isFullscreen ? 24 : 14,
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xCC0D0D12),
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            border: Border.all(
              color: _activeChannel.brandPrimary.withValues(alpha: 0.60),
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
                constraints: const BoxConstraints(maxWidth: 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'CH ${_activeChannel.number} • ${_activeChannel.name(ar)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LiveBroadcastType.style(
                        context,
                        size: 12,
                        weight: FontWeight.w800,
                        tabular: true,
                      ),
                    ),
                    Text(
                      current.title(ar),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LiveBroadcastType.style(
                        context,
                        size: 10.5,
                        weight: FontWeight.w500,
                        color: AppColors.textSecondary,
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
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${_activeChannel.number} • ${_activeChannel.name(ar)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LiveBroadcastType.style(
                  stageContext,
                  size: wideHud ? 13.5 : 12,
                  weight: FontWeight.w800,
                  tabular: true,
                ),
              ),
              if (wideHud)
                Text(
                  current.title(ar),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LiveBroadcastType.style(
                    stageContext,
                    size: 11,
                    weight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Pulsing LIVE Badge
        AnimatedBuilder(
          animation: _pulseAnimCtrl,
          builder: (BuildContext context, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.35 + 0.35 * _pulseAnimCtrl.value,
                    ),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(
                        alpha: 0.55 + 0.45 * _pulseAnimCtrl.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ar ? 'مباشر' : 'LIVE',
                    style: LiveBroadcastType.style(
                      stageContext,
                      size: 10.5,
                      weight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Live Viewers Counter
        if (wideHud) ...<Widget>[
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x99111111),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.visibility_rounded,
                  size: 13,
                  color: AppColors.accentCyan,
                ),
                const SizedBox(width: 4),
                Text(
                  _formattedViewers,
                  style: LiveBroadcastType.style(
                    stageContext,
                    size: 10.5,
                    weight: FontWeight.w700,
                    tabular: true,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Quality Selector Pill
        const SizedBox(width: 7),
        InkWell(
          onTap: () => _openQualitySheet(stageContext),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xAD141418),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.55),
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
                    weight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.tune_rounded,
                  size: 12,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        ),

        if (isFullscreen) ...<Widget>[
          const SizedBox(width: 8),
          _HudCircleBtn(
            icon: Icons.close_rounded,
            size: 34,
            iconSize: 18,
            onTap: () => Navigator.of(stageContext).maybePop(),
          ),
        ],
      ],
    );
  }