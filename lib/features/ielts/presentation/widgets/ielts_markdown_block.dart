import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/theme_extensions.dart';

class IeltsMarkdownBlock extends StatelessWidget {
  const IeltsMarkdownBlock({
    super.key,
    required this.data,
    this.selectable = false,
  });

  final String data;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final normalized = data.trim();
    if (normalized.isEmpty) {
      return const SizedBox.shrink();
    }

    final baseStyle = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: Theme.of(context).textTheme.bodyMedium,
      h1: Theme.of(context).textTheme.headlineSmall,
      h2: Theme.of(context).textTheme.titleLarge,
      h3: Theme.of(context).textTheme.titleMedium,
      blockquote: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: context.tokens.text.secondary),
      listBullet: Theme.of(context).textTheme.bodyMedium,
      code: Theme.of(context).textTheme.bodySmall?.copyWith(
        backgroundColor: context.tokens.background.panelStrong,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.tokens.border.subtle),
        ),
      ),
    );

    return MarkdownBody(
      data: normalized,
      selectable: selectable,
      shrinkWrap: true,
      styleSheet: baseStyle,
      sizedImageBuilder: (config) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.tokens.radius.lg),
            child: Image.network(
              config.uri.toString(),
              width: config.width,
              height: config.height,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
