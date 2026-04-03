import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_destinations.dart';
import '../../../features/auth/auth_providers.dart';
import '../../../features/auth/models/auth_models.dart';
import '../../../features/notifications/presentation/widgets/foreground_push_banner.dart';
import '../../../features/notifications/presentation/widgets/notification_toast_host.dart';
import '../../notifications/notification_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/page_palettes.dart';
import '../../theme/theme_extensions.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const double _hideHeaderThreshold = 28;
  static const double _showHeaderThreshold = 18;
  static const _doubleBackWindow = Duration(seconds: 2);
  static const _shellRootRoutes = <String>{
    '/home',
    '/dictionary',
    '/vocabulary/check',
    '/vocabulary-tests',
    '/ielts',
    '/writing',
    '/speaking',
    '/custom-speaking',
    '/weekly-report',
    '/challenges',
    '/notifications',
    '/profile',
    '/leaderboard',
    '/xp-history',
    '/preview',
    '/settings',
  };

  bool _isHeaderVisible = true;
  double _scrollAccumulator = 0;
  DateTime? _lastBackPressedAt;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification.metrics.pixels <= 0) {
      _scrollAccumulator = 0;
      if (!_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = true;
        });
      }
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.outOfRange) {
        _scrollAccumulator = 0;
        return false;
      }

      final delta = notification.scrollDelta ?? 0;
      if (delta == 0) {
        return false;
      }

      // Ignore the rebound that happens when the list hits the bottom edge.
      if (notification.metrics.extentAfter == 0 && delta < 0) {
        _scrollAccumulator = 0;
        return false;
      }

      if ((_scrollAccumulator > 0 && delta < 0) ||
          (_scrollAccumulator < 0 && delta > 0)) {
        _scrollAccumulator = 0;
      }

      _scrollAccumulator += delta;

      if (_isHeaderVisible && _scrollAccumulator >= _hideHeaderThreshold) {
        _scrollAccumulator = 0;
        setState(() {
          _isHeaderVisible = false;
        });
      } else if (!_isHeaderVisible &&
          _scrollAccumulator <= -_showHeaderThreshold) {
        _scrollAccumulator = 0;
        setState(() {
          _isHeaderVisible = true;
        });
      }
    }

    if (notification is ScrollEndNotification ||
        notification is UserScrollNotification) {
      if (notification is UserScrollNotification &&
          notification.direction != ScrollDirection.idle) {
        return false;
      }

      _scrollAccumulator = 0;
    }

    return false;
  }

  Future<void> _handleBackPressed(
    BuildContext context,
    AppDestination currentDestination,
  ) async {
    final target = _resolveBackTarget(currentDestination);
    if (target != null) {
      ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
      context.go(target);
      return;
    }

    final now = DateTime.now();
    if (_lastBackPressedAt == null ||
        now.difference(_lastBackPressedAt!) > _doubleBackWindow) {
      _lastBackPressedAt = now;
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: _doubleBackWindow,
          ),
        );
      return;
    }

    await SystemNavigator.pop();
  }

  String? _resolveBackTarget(AppDestination currentDestination) {
    final location = widget.location;

    if (location == '/custom-speaking' ||
        location.startsWith('/custom-speaking/')) {
      return '/speaking';
    }

    if (_shellRootRoutes.contains(location)) {
      return null;
    }

    return currentDestination.route == location
        ? null
        : currentDestination.route;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final currentDestination = resolveDestination(widget.location);
    final auth = ref.watch(authControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _handleBackPressed(context, currentDestination);
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tokens.background.body,
                tokens.background.canvas,
                tokens.background.body,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    AnimatedSize(
                      duration: tokens.motion.normal,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: ClipRect(
                        child: Align(
                          heightFactor: _isHeaderVisible ? 1 : 0,
                          child: AnimatedSlide(
                            offset: _isHeaderVisible
                                ? Offset.zero
                                : const Offset(0, -0.18),
                            duration: tokens.motion.normal,
                            curve: Curves.easeOutCubic,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                              child: _ShellHeader(
                                user: auth.user,
                                onLogout: auth.isSubmitting
                                    ? null
                                    : () => ref
                                          .read(authControllerProvider)
                                          .logout(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final destination = appPrimaryDestinations[index];
                          final selected =
                              destination.route == currentDestination.route;
                          final palette = context.pagePalette(
                            destination.paletteKey,
                          );

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                tokens.radius.hero,
                              ),
                              onTap: () => context.go(destination.route),
                              child: AnimatedContainer(
                                duration: tokens.motion.normal,
                                curve: Curves.easeOutCubic,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? palette.accent.withValues(alpha: 0.16)
                                      : tokens.background.mobileDrawer,
                                  borderRadius: BorderRadius.circular(
                                    tokens.radius.hero,
                                  ),
                                  border: Border.all(
                                    color: selected
                                        ? palette.accent.withValues(alpha: 0.42)
                                        : tokens.border.subtle,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      destination.icon,
                                      size: 18,
                                      color: selected
                                          ? palette.accent
                                          : tokens.text.secondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.tr(destination.labelKey),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: selected
                                                ? tokens.text.primary
                                                : tokens.text.secondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemCount: appPrimaryDestinations.length,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
                const NotificationToastHost(),
                const ForegroundPushBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({required this.user, required this.onLogout});

  final AuthUser? user;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: tokens.background.mobileDrawer,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.shell,
            blurRadius: tokens.motion.blurStrong + 8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(child: _HeaderBrand()),
          const SizedBox(width: 12),
          _HeaderActionCluster(user: user, onLogout: onLogout),
        ],
      ),
    );
  }
}

class _HeaderBrand extends StatelessWidget {
  const _HeaderBrand();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(AppPagePaletteKey.dashboard);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.heroTop, palette.heroBottom],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(tokens.radius.lg),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            context.tr('common.appName'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

enum _HeaderMenuAction { profile, theme, settings, logout }

class _HeaderActionCluster extends StatelessWidget {
  const _HeaderActionCluster({required this.user, required this.onLogout});

  final AuthUser? user;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.hero),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _HeaderNotificationBellButton(),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: tokens.border.subtle,
          ),
          _AvatarMenu(user: user, onLogout: onLogout),
        ],
      ),
    );
  }
}

class _HeaderNotificationBellButton extends ConsumerWidget {
  const _HeaderNotificationBellButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realtime = ref.watch(notificationRealtimeClientProvider);
    final tokens = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/notifications'),
        borderRadius: BorderRadius.circular(tokens.radius.hero),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Center(child: Icon(Icons.notifications_none_rounded)),
              if (realtime.unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.danger,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      realtime.unreadCount > 99
                          ? '99+'
                          : '${realtime.unreadCount}',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarMenu extends StatelessWidget {
  const _AvatarMenu({required this.user, required this.onLogout});

  final AuthUser? user;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(AppPagePaletteKey.profile);
    final initials = user?.initials ?? 'U';
    final displayName = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName
        : context.tr('app.nav.profile');
    final email = user?.email ?? '';

    return PopupMenuButton<_HeaderMenuAction>(
      tooltip: context.tr('app.nav.profile'),
      position: PopupMenuPosition.under,
      color: tokens.background.mobileDrawer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        side: BorderSide(color: tokens.border.subtle),
      ),
      onSelected: (value) {
        switch (value) {
          case _HeaderMenuAction.profile:
            context.go('/profile');
          case _HeaderMenuAction.theme:
            context.go('/preview');
          case _HeaderMenuAction.settings:
            context.go('/settings');
          case _HeaderMenuAction.logout:
            onLogout?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_HeaderMenuAction>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: _MenuHeader(
            initials: initials,
            displayName: displayName,
            email: email,
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<_HeaderMenuAction>(
          value: _HeaderMenuAction.profile,
          child: _MenuOption(
            icon: Icons.account_circle_rounded,
            label: context.tr('app.nav.profile'),
            subtitle: 'Account and progress',
          ),
        ),
        PopupMenuItem<_HeaderMenuAction>(
          value: _HeaderMenuAction.theme,
          child: _MenuOption(
            icon: Icons.palette_outlined,
            label: context.tr('common.theme'),
            subtitle: 'Colors and preview',
          ),
        ),
        PopupMenuItem<_HeaderMenuAction>(
          value: _HeaderMenuAction.settings,
          child: _MenuOption(
            icon: Icons.tune_rounded,
            label: context.tr('app.nav.settings'),
            subtitle: 'Language and app options',
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<_HeaderMenuAction>(
          value: _HeaderMenuAction.logout,
          child: _MenuOption(
            icon: Icons.logout_rounded,
            label: context.tr('common.logout'),
            subtitle: 'Sign out of this device',
            destructive: true,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 6, 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(tokens.radius.hero),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: palette.accent.withValues(alpha: 0.14),
              foregroundColor: palette.accent,
              child: Text(
                initials,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: tokens.text.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.initials,
    required this.displayName,
    required this.email,
  });

  final String initials;
  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(AppPagePaletteKey.profile);

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: palette.accent.withValues(alpha: 0.14),
          foregroundColor: palette.accent,
          child: Text(initials, style: Theme.of(context).textTheme.labelLarge),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: tokens.text.primary),
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.text.secondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.icon,
    required this.label,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = destructive ? tokens.danger : tokens.text.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: color),
              ),
              if ((subtitle ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: destructive
                          ? color.withValues(alpha: 0.8)
                          : tokens.text.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
