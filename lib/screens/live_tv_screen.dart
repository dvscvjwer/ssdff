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