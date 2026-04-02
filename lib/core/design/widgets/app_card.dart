import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.strong = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: strong ? tokens.background.panelStrong : tokens.background.panel,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.card,
            blurRadius: tokens.motion.blurSoft + 8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: padding ?? EdgeInsets.all(tokens.density.panelPadding),
      child: child,
    );
  }
}
