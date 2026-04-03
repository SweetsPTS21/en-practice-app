import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/push/push_providers.dart';
import '../../../../core/theme/theme_extensions.dart';

class ForegroundPushBanner extends ConsumerStatefulWidget {
  const ForegroundPushBanner({super.key});

  @override
  ConsumerState<ForegroundPushBanner> createState() => _ForegroundPushBannerState();
}

class _ForegroundPushBannerState extends ConsumerState<ForegroundPushBanner> {
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pushLifecycleControllerProvider);
    final message = controller.foregroundMessage;
    if (message == null) {
      return const SizedBox.shrink();
    }

    _dismissTimer?.cancel();
    _dismissTimer = Timer(
      const Duration(seconds: 6),
      () => ref.read(pushLifecycleControllerProvider).dismissForegroundMessage(),
    );

    final tokens = context.tokens;
    return Positioned(
      top: 92,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radius.hero),
          onTap: () async {
            final outcome = await ref.read(pushLifecycleControllerProvider).openForegroundMessage();
            if (!context.mounted || outcome == null) {
              return;
            }
            if (outcome.target.kind.name == 'external') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('External push routes are not enabled on mobile yet.')),
              );
              return;
            }
            context.go(outcome.target.href);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.background.panel,
              borderRadius: BorderRadius.circular(tokens.radius.hero),
              border: Border.all(color: tokens.border.subtle),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadow.shell,
                  blurRadius: tokens.motion.blurStrong,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tokens.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                  ),
                  child: Icon(Icons.campaign_rounded, color: tokens.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.title, style: Theme.of(context).textTheme.titleMedium),
                      if ((message.body ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          message.body!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: tokens.text.secondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(pushLifecycleControllerProvider).dismissForegroundMessage(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
