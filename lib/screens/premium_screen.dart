import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  PremiumScreen â€” Redesigned with AppColors/AppGradients tokens
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selected = 1;

  List<_Plan> _plans(BuildContext c) {
    final s = AppLocalizations.of(c);
    return [
      _Plan(s.planBasicName, r'$4.99', s.planPerMonth, s.planBasicDesc),
      _Plan(s.planStandardName, r'$9.99', s.planPerMonth, s.planStandardDesc),
      _Plan(s.planPremiumName, r'$14.99', s.planPerMonth, s.planPremiumDesc),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final plans = _plans(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.premiumTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // â”€â”€â”€ Header Banner â”€â”€â”€
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE50914),  // AppColors.primary
                  Color(0xFFB2070F),  // AppColors.primaryDark
                  Color(0xFF7A0007),  // gradientRedEnd
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppColors.textPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.premiumUnlock,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.premiumPitch,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            s.premiumChoose,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < plans.length; i++) _planTile(plans, i),
          const SizedBox(height: 20),
          Text(
            s.premiumWhat,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          // â”€â”€â”€ Feature Items â”€â”€â”€
          _feature(Icons.hd, s.premiumFeature4k),
          _feature(Icons.devices, s.premiumFeatureDevices),
          _feature(Icons.download_for_offline, s.premiumFeatureOffline),
          _feature(Icons.block, s.premiumFeatureNoAds),
          _feature(Icons.translate, s.premiumFeatureLangs),
          const SizedBox(height: 28),
          // â”€â”€â”€ CTA Button â”€â”€â”€
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE50914),  // AppColors.primary
                    Color(0xFFB2070F),  // AppColors.primaryDark
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.premiumRedirect),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  s.premiumContinueWith(plans[_selected].name),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.premiumCancel,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textTertiary, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Plan Tile â”€â”€â”€
  Widget _planTile(List<_Plan> plans, int i) {
    final plan = plans[i];
    final selected = _selected == i;
    final isMostPopular = i == 1;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () => setState(() => _selected = i),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF161616), // AppColors.surfaceCard
                        Color(0xFF1A1A1A), // AppColors.surfaceAlt
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 20,
                      ),
                    ],
                  )
                : BoxDecoration(
                    color: const Color(0xFF111111), // AppColors.surface
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2A2A2A), // AppColors.divider
                      width: 0.8,
                    ),
                  ),
            child: selected
                ? _GradientBorderWrapper(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE50914),  // AppColors.primary
                        Color(0xFFFF3B30),  // AppColors.primaryLight
                        Color(0xFFB2070F),  // AppColors.primaryDark
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    strokeWidth: 2.0,
                    child: _planContent(plan, selected),
                  )
                : _planContent(plan, selected),
          ),
        ),
        // â”€â”€â”€ "Most Popular" badge â”€â”€â”€
        if (isMostPopular)
          PositionedDirectional(
            top: -12,
            end: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppGradients.premiumGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.premium,
              ),
              child: Text(
                'ط§ظ„ط£ظƒط«ط± ط´ط¹ط¨ظٹط©',
                style: AppTextStyles.badge.copyWith(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _planContent(_Plan plan, bool selected) {
    return Row(
      children: [
        Icon(
          selected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          color: selected ? AppColors.primary : AppColors.textTertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                plan.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              plan.price,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              plan.cadence,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // â”€â”€â”€ Feature Row â”€â”€â”€
  Widget _feature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Gradient Border Wrapper â”€â”€â”€
class _GradientBorderWrapper extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  const _GradientBorderWrapper({
    required this.child,
    required this.borderRadius,
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBorderPainter(
        borderRadius: borderRadius,
        gradient: gradient,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.gradient != gradient ||
      old.strokeWidth != strokeWidth ||
      old.borderRadius != borderRadius;
}

class _Plan {
  final String name;
  final String price;
  final String cadence;
  final String description;
  const _Plan(this.name, this.price, this.cadence, this.description);
}
