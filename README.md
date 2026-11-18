# Sky Live

**Sky Live** is a modern, full-featured streaming application built with Flutter. It delivers a cinematic, Netflix-inspired experience with a dark-first design system, multi-language support (Arabic & English), and a rich content browsing experience.

## ✨ Features

- 🎬 **Browse & Discover** — Movies, series, kids content, and live TV channels organized into curated collections
- 🔴 **Live TV** — Real-time channel browsing with animated LIVE indicators and category filters
- 🌟 **Hero Banner** — Full-bleed featured content with gradient overlays and animated slide indicators
- 💎 **Premium Plans** — Tiered subscription UI (Basic / Standard / Premium) with gradient borders and "Most Popular" badge
- 🔍 **Search** — Instant search with trending suggestions and empty-state guidance
- 📥 **Downloads** — Offline download tracking with progress indicators
- 📋 **My List** — Persistent watch list powered by shared preferences
- 👤 **Profile Selector** — Multi-profile support with glow selection effect
- ⚙️ **Settings** — Video quality, subtitle style, audio preferences, language switching, and more
- 🌐 **Localization** — Full Arabic (RTL) and English support via Flutter's ARB-based l10n system
- 🎨 **Design System** — `AppColors`, `AppGradients`, `AppTextStyles`, `AppShadows` — ready for use across all widgets

## 🏗️ Architecture

```
lib/
├── data/           # Mock data layer & catalog helpers
├── l10n/           # ARB localization files (ar + en)
├── models/         # TitleItem, Collection, Profile data models
├── screens/        # All app screens (Home, Search, Detail, Player, Premium…)
├── services/       # LocaleController, ProfileManager, UserState (ChangeNotifier)
├── theme/          # AppColors, AppGradients, AppTextStyles, AppShadows, buildDarkTheme()
├── util/           # i18n helpers
└── widgets/        # Reusable UI components (HeroBanner, TitleCard, TitleRow…)
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK `>=3.0.0`

### Setup

```bash
git clone https://github.com/dvscvjwer/ssdff.git
cd ssdff
flutter pub get
flutter gen-l10n
flutter run
```

### Web Build

```bash
flutter build web --release
```

## 🛠️ Tech Stack

| Package | Purpose |
|---|---|
| `google_fonts` | Inter typeface throughout the UI |
| `cached_network_image` | Efficient image loading with placeholders |
| `video_player` | Native video playback |
| `lottie` | Lottie animation support |
| `shared_preferences` | Persistent user state (list, downloads, settings) |
| `flutter_localizations` | RTL layout & ARB-based localization |
| `flutter_svg` | SVG icon rendering |
| `image_picker` | Profile avatar selection |

## 🎨 Design System

```dart
// Colors
AppColors.primary       // #E50914 — Brand red
AppColors.gold          // #FFD700 — Premium gold
AppColors.glowRed       // Translucent red glow

// Gradients
AppGradients.heroGradient     // Full-bleed hero overlay
AppGradients.premiumGradient  // Gold shimmer for VIP elements
AppGradients.cardGradient     // Subtle card surface

// Typography
AppTextStyles.heroTitle    // 48px / w900 — Detail screen headline
AppTextStyles.sectionTitle // 22px / w700 — Row headers
AppTextStyles.cardTitle    // 14px / w600 — Below thumbnail

// Shadows
AppShadows.card     // Subtle elevation
AppShadows.glow     // Red glow for featured artwork
AppShadows.premium  // Gold glow for VIP badges
```

## 📄 License

This project is provided as a UI template for educational and portfolio purposes.
