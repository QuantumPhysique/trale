/// Shared Flutter library for QuantumPhysique apps.
///
/// Provides shared theme, preferences, notifier, settings pages, dialog
/// patterns, bento widgets, and the changelog system.
library;

// Utils
export 'src/utils/qp_color_utils.dart';

// Types
export 'src/types/contrast.dart';
export 'src/types/scheme_variant.dart';
export 'src/types/language.dart';
export 'src/types/first_day.dart';
export 'src/types/first_day_localizations_delegate.dart';
export 'src/types/date_format.dart';
export 'src/types/logger.dart';
export 'src/types/font.dart';
export 'src/types/icons.dart';
export 'src/types/strings.dart';
export 'src/types/string_extension.dart';
export 'src/types/about_strings.dart';

// Changelog
export 'src/changelog/changelog.dart';

// Preferences
export 'src/preferences/qp_preferences.dart';

// Notifier
export 'src/notifier/qp_notifier.dart';

// App
export 'src/app/qp_app.dart';
export 'src/app/qp_notification_service.dart';

// Widgets
export 'src/widgets/qp_layout.dart';
export 'src/widgets/burger_theme.dart';
export 'src/widgets/colored_container.dart';
export 'src/widgets/fade_in_effect.dart';
export 'src/widgets/tile_group/tile_group.dart';
export 'src/widgets/dialog.dart';
export 'src/widgets/bullet_list.dart';
export 'src/widgets/animate_in_effect.dart';
export 'src/widgets/animation_replay_scope.dart';
export 'src/widgets/bento_card.dart';
export 'src/widgets/bento_grid.dart';
export 'src/widgets/settings_banner.dart';
export 'src/widgets/changelog_widget.dart';
export 'src/widgets/sliver_app_bar_snap.dart';
export 'src/widgets/selection_carousel.dart';
export 'src/widgets/third_party_licence.dart';

// Pages
export 'src/pages/qp_theme_settings_page.dart';
export 'src/pages/qp_language_settings_page.dart';
export 'src/pages/qp_notifications_settings_page.dart';
export 'src/pages/qp_settings_overview_page.dart';
export 'src/pages/qp_about_page.dart';
export 'src/pages/qp_faq_page.dart';
