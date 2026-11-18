// ─────────────────────────────────────────────────────────────
//  player_screen.dart — SkyLive Redesign
// ─────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/title.dart';
import '../theme/app_theme.dart';

// ─── Screen ──────────────────────────────────────────────────
class PlayerScreen extends StatefulWidget {
  final TitleItem title;
  const PlayerScreen({super.key, required this.title});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double _progress = 0.18;
  final double _duration = 5640; // 94 minutes in seconds
  bool _playing = true;
  bool _showControls = true;
  bool _locked = false;
  double _speed = 1.0;
  String _quality = 'auto';
  double _brightness = 0.7;
  double _volume = 0.8;
  Timer? _hideTimer;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scheduleHide();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_playing) return;
      setState(() {
        _progress = (_progress + 1 / _duration).clamp(0.0, 1.0);
      });
    });
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _hideTimer?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(text),
      ),
    );
  }

  String _fmt(double seconds) {
    final s = seconds.toInt();
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final ss = s % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ─── Video placeholder ───
            Container(color: AppColors.background),
            CachedNetworkImage(
              imageUrl: widget.title.backdrop,
              fit: BoxFit.contain,
            ),
            if (_showControls && !_locked) _controlsOverlay(),
            if (_showControls && _locked) _lockedOverlay(),
          ],
        ),
      ),
    );
  }

  // ─── Controls Overlay ──────────────────────────────────────
  Widget _controlsOverlay() {
    final t = widget.title;
    final pos = _progress * _duration;
    return Container(
      color: AppColors.overlayBlackLight,
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            // ─ Top bar ─
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    t.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _topBtn(Icons.cast, () => _toast(
                    AppLocalizations.of(context).snackCastUnavailable)),
                _topBtn(Icons.picture_in_picture_alt, () => _toast(
                    AppLocalizations.of(context).snackComingSoon)),
                _topBtn(Icons.closed_caption_outlined, () => _toast(
                    AppLocalizations.of(context).snackComingSoon)),
                _topBtn(Icons.more_vert, _openOptions),
              ],
            ),
            const Spacer(),
            // ─ Center controls ─
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bigBtn(
                  Icons.skip_previous,
                  onTap: () => setState(() => _progress = 0),
                ),
                _bigBtn(
                  Icons.replay,
                  onTap: () => setState(() {
                    _progress =
                        ((pos - 15) / _duration).clamp(0.0, 1.0).toDouble();
                  }),
                  badge: '15',
                ),
                _bigBtn(
                  _playing ? Icons.pause_circle : Icons.play_circle,
                  size: 72,
                  onTap: () {
                    setState(() => _playing = !_playing);
                    _scheduleHide();
                  },
                ),
                _bigBtn(
                  Icons.forward_30,
                  onTap: () => setState(() {
                    _progress =
                        ((pos + 15) / _duration).clamp(0.0, 1.0).toDouble();
                  }),
                  badge: '15',
                ),
                _bigBtn(
                  Icons.skip_next,
                  onTap: () => _toast(
                      AppLocalizations.of(context).snackComingSoon),
                ),
              ],
            ),
            const Spacer(),
            _bottomBar(pos),
          ],
        ),
      ),
    );
  }

  // ─── Locked Overlay ────────────────────────────────────────
  Widget _lockedOverlay() {
    return SafeArea(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.lock,
                color: AppColors.textPrimary, size: 28),
            onPressed: () {
              setState(() {
                _locked = false;
                _showControls = true;
              });
              _scheduleHide();
            },
          ),
        ),
      ),
    );
  }

  // ─── Bottom Bar ────────────────────────────────────────────
  Widget _bottomBar(double pos) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceHigh,
            thumbColor: AppColors.textPrimary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _progress,
            onChanged: (v) => setState(() => _progress = v),
            onChangeEnd: (_) => _scheduleHide(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                _fmt(pos),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                _fmt(_duration),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 12),
              ),
            ],
          ),
        ),
        Builder(builder: (ctx) {
          final s = AppLocalizations.of(ctx);
          return Row(
            children: [
              _smallBtn(Icons.lock_open, s.playerLock, () {
                setState(() {
                  _locked = true;
                  _showControls = true;
                });
                _scheduleHide();
              }),
              _smallBtn(
                Icons.brightness_6,
                s.playerBrightness,
                () => _openSlider(
                  label: s.playerBrightness,
                  icon: Icons.brightness_6,
                  value: _brightness,
                  onChanged: (v) => setState(() => _brightness = v),
                ),
              ),
              _smallBtn(
                Icons.volume_up,
                s.playerVolume,
                () => _openSlider(
                  label: s.playerVolume,
                  icon: Icons.volume_up,
                  value: _volume,
                  onChanged: (v) => setState(() => _volume = v),
                ),
              ),
              _smallBtn(Icons.speed, '${_speed}x', _openSpeed),
              _smallBtn(Icons.hd, _qualityLabel(ctx), _openQuality),
              _smallBtn(
                Icons.fullscreen_exit,
                s.playerExit,
                () => Navigator.pop(context),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ─── Button helpers ────────────────────────────────────────
  Widget _topBtn(IconData icon, VoidCallback onTap) => IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 22),
        onPressed: () {
          onTap();
          _scheduleHide();
        },
      );

  Widget _bigBtn(IconData icon,
      {double size = 44, required VoidCallback onTap, String? badge}) {
    final btn = IconButton(
      iconSize: size,
      onPressed: () {
        onTap();
        _scheduleHide();
      },
      icon: Icon(icon, color: AppColors.textPrimary),
    );
    if (badge == null) return btn;
    return Stack(
      alignment: Alignment.center,
      children: [
        btn,
        IgnorePointer(
          child: Text(
            badge,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap();
          _scheduleHide();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Dialogs ───────────────────────────────────────────────
  String _qualityLabel(BuildContext c) {
    final s = AppLocalizations.of(c);
    return _quality == 'auto' ? s.playerQualityAuto : _quality;
  }

  void _openOptions() {
    final s = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceModal,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.speed),
              title: Text(s.playerSpeed),
              subtitle: Text('${_speed}x'),
              onTap: () {
                Navigator.pop(context);
                _openSpeed();
              },
            ),
            ListTile(
              leading: const Icon(Icons.hd),
              title: Text(s.playerQuality),
              subtitle: Text(_qualityLabel(context)),
              onTap: () {
                Navigator.pop(context);
                _openQuality();
              },
            ),
            ListTile(
              leading: const Icon(Icons.closed_caption_outlined),
              title: Text(s.playerSubtitles),
              subtitle: Text(widget.title.subtitles.join(', ')),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: Text(s.playerAudio),
              subtitle: Text(widget.title.audio.join(', ')),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.aspect_ratio),
              title: Text(s.playerAspect),
              subtitle: Text(s.playerAspectFit),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openSlider({
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceModal,
      builder: (ctx) => SafeArea(
        child: StatefulBuilder(
          builder: (c, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Slider(
                    value: value,
                    onChanged: (v) {
                      setSheetState(() => value = v);
                      onChanged(v);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openSpeed() {
    _pickValue<double>(
      title: AppLocalizations.of(context).playerSpeed,
      values: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
      selected: _speed,
      labelOf: (v) => '${v}x',
      onPick: (v) => setState(() => _speed = v),
    );
  }

  void _openQuality() {
    final s = AppLocalizations.of(context);
    _pickValue<String>(
      title: s.playerQuality,
      values: const ['auto', '1080p', '720p', '480p', '360p'],
      selected: _quality,
      labelOf: (v) => v == 'auto' ? s.playerQualityAuto : v,
      onPick: (v) => setState(() => _quality = v),
    );
  }

  void _pickValue<T>({
    required String title,
    required List<T> values,
    required T selected,
    required String Function(T) labelOf,
    required ValueChanged<T> onPick,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceModal,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            for (final v in values)
              ListTile(
                title: Text(labelOf(v)),
                trailing: v == selected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onPick(v);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}
