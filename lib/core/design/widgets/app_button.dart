import 'package:flutter/material.dart';

enum AppButtonVariant { filled, tonal, outline }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = _buttonStyle(context);

    switch (variant) {
      case AppButtonVariant.filled:
        return icon == null
            ? FilledButton(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              )
            : FilledButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon),
                label: Text(label),
              );
      case AppButtonVariant.tonal:
        return icon == null
            ? FilledButton.tonal(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              )
            : FilledButton.tonalIcon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon),
                label: Text(label),
              );
      case AppButtonVariant.outline:
        return icon == null
            ? OutlinedButton(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              )
            : OutlinedButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon),
                label: Text(label),
              );
    }
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    final density = compact ? VisualDensity.compact : VisualDensity.standard;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    final minHeight = compact ? 34.0 : 40.0;

    return ButtonStyle(
      visualDensity: density,
      tapTargetSize: compact
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
      minimumSize: WidgetStatePropertyAll(Size(0, minHeight)),
      padding: WidgetStatePropertyAll(padding),
      textStyle: WidgetStatePropertyAll(
        compact
            ? Theme.of(context).textTheme.labelLarge
            : Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
