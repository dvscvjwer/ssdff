import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
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
                          color: Colors.white,
                          fontSize: 18,
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
          _feature(Icons.hd, s.premiumFeature4k),
          _feature(Icons.devices, s.premiumFeatureDevices),
          _feature(Icons.download_for_offline, s.premiumFeatureOffline),
          _feature(Icons.block, s.premiumFeatureNoAds),
          _feature(Icons.translate, s.premiumFeatureLangs),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.premiumRedirect),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                s.premiumContinueWith(plans[_selected].name),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
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

  Widget _planTile(List<_Plan> plans, int i) {
    final plan = plans[i];
    final selected = _selected == i;
    final isMostPopular = i == 1; // Middle plan — Standard

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () => setState(() => _selected = i),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: AppGradients.cardGradient,
                    border: Border.all(
                      color: Colors.transparent,
                      width: 0,
                    ),
                  )
                : BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.divider,
                      width: 0.8,
                    ),
                  ),
            child: selected
                ? _GradientBorderWrapper(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    strokeWidth: 1.8,
                    child: _planContent(plan, selected),
                  )
                : _planContent(plan, selected),
          ),
        ),
        // "Most Popular" badge on middle plan
        if (isMostPopular)
          PositionedDirectional(
            top: -11,
            end: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppGradients.premiumGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.premium,
              ),
              child: Text(
                'الأكثر شعبية',
                style: AppTextStyles.badge.copyWith(
                  color: Colors.black,
                  fontSize: 10,
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

  Widget _feature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a gradient border around [child] without clipping the child itself.
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
