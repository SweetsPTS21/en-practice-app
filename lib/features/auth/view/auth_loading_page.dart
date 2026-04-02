import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';

class AuthLoadingPage extends StatelessWidget {
  const AuthLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.background.panelStrong,
                        border: Border.all(color: tokens.border.subtle),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.shadow.accent,
                            blurRadius: tokens.motion.blurStrong + 12,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: tokens.primaryStrong,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('auth.loading.title'),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('auth.loading.subtitle'),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
