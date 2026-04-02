import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/app_destinations.dart';
import '../../../features/auth/auth_providers.dart';
import '../../../features/auth/models/auth_models.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/page_palettes.dart';
import '../../theme/theme_extensions.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const double _hideHeaderThreshold = 28;
  static const double _showHeaderThreshold = 18;

  bool _isHeaderVisible = true;
  double _scrollAccumulator = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
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
      final delta = notification.scrollDelta ?? 0;
      if (delta == 0) {
        return false;
      }

      if ((_scrollAccumulator > 0 && delta < 0) || (_scrollAccumulator < 0 && delta > 0)) {
        _scrollAccumulator = 0;
      }

      _scrollAccumulator += delta;

      if (_isHeaderVisible && _scrollAccumulator >= _hideHeaderThreshold) {
        _scrollAccumulator = 0;
        setState(() {
          _isHeaderVisible = false;
        });
      } else if (!_isHeaderVisible && _scrollAccumulator <= -_showHeaderThreshold) {
        _scrollAccumulator = 0;
        setState(() {
          _isHeaderVisible = true;
        });
      }
    }

    if (notification is ScrollEndNotification || notification is UserScrollNotification) {
      if (notification is UserScrollNotification &&
          notification.direction != ScrollDirection.idle) {
        return false;
      }

      _scrollAccumulator = 0;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final currentDestination = resolveDestination(widget.location);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
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
          child: Column(
            children: [
              AnimatedSize(
                duration: tokens.motion.normal,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: ClipRect(
                  child: Align(
                    heightFactor: _isHeaderVisible ? 1 : 0,
                    child: AnimatedSlide(
                      offset: _isHeaderVisible ? Offset.zero : const Offset(0, -0.18),
                      duration: tokens.motion.normal,
                      curve: Curves.easeOutCubic,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: _ShellHeader(
                          user: auth.user,
                          onLogout: auth.isSubmitting
                              ? null
                              : () => ref.read(authControllerProvider).logout(),
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
                    final selected = destination.route == currentDestination.route;
                    final palette = context.pagePalette(destination.paletteKey);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(tokens.radius.hero),
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
                            borderRadius: BorderRadius.circular(tokens.radius.hero),
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
                                color: selected ? palette.accent : tokens.text.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.tr(destination.labelKey),
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
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
        ),
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.user,
    required this.onLogout,
  });

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
          const _HeaderBrand(),
          const Spacer(),
          _AvatarMenu(
            user: user,
            onLogout: onLogout,
          ),
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
      mainAxisSize: MainAxisSize.min,
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
        Text(
          context.tr('common.appName'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

enum _HeaderMenuAction {
  theme,
  settings,
  logout,
}

class _AvatarMenu extends StatelessWidget {
  const _AvatarMenu({
    required this.user,
    required this.onLogout,
  });

  final AuthUser? user;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(AppPagePaletteKey.profile);
    final initials = user?.initials ?? 'U';

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
          value: _HeaderMenuAction.theme,
          child: _MenuOption(
            icon: Icons.palette_outlined,
            label: context.tr('common.theme'),
          ),
        ),
        PopupMenuItem<_HeaderMenuAction>(
          value: _HeaderMenuAction.settings,
          child: _MenuOption(
            icon: Icons.tune_rounded,
            label: context.tr('app.nav.settings'),
          ),
        ),
        PopupMenuItem<_HeaderMenuAction>(
          value: _HeaderMenuAction.logout,
          child: _MenuOption(
            icon: Icons.logout_rounded,
            label: context.tr('common.logout'),
            destructive: true,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: tokens.background.panelStrong,
          borderRadius: BorderRadius.circular(tokens.radius.hero),
          border: Border.all(color: tokens.border.subtle),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: palette.accent.withValues(alpha: 0.14),
          foregroundColor: palette.accent,
          child: Text(
            initials,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = destructive ? tokens.danger : tokens.text.primary;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}
