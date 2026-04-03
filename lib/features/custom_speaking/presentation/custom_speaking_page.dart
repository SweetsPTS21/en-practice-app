import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/custom_speaking/custom_speaking_models.dart';
import '../../../core/custom_speaking/custom_speaking_providers.dart';
import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_header_icon_action.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/theme/page_palettes.dart';

class CustomSpeakingPage extends ConsumerStatefulWidget {
  const CustomSpeakingPage({super.key});

  @override
  ConsumerState<CustomSpeakingPage> createState() => _CustomSpeakingPageState();
}

class _CustomSpeakingPageState extends ConsumerState<CustomSpeakingPage> {
  late final TextEditingController _topicController;
  String _style = customSpeakingStyleOptions.first;
  String _personality = customSpeakingPersonalityOptions.first;
  String _expertise = customSpeakingExpertiseOptions.first;
  String _voice = customSpeakingVoiceOptions.first;
  bool _gradingEnabled = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Custom speaking',
      subtitle:
          'Create a freestyle conversation with a chosen tone, personality, and voice, then continue the chat in a dedicated mobile session.',
      paletteKey: AppPagePaletteKey.speaking,
      trailing: AppHeaderIconAction(
        tooltip: 'History',
        icon: Icons.history_rounded,
        onPressed: () => context.go('/custom-speaking/history'),
      ),
      children: [
        AppCard(
          strong: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Conversation topic',
                  hintText:
                      'Example: handling a tough client meeting in English',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _style,
                decoration: const InputDecoration(labelText: 'Style'),
                items: customSpeakingStyleOptions
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _style = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _personality,
                decoration: const InputDecoration(labelText: 'Personality'),
                items: customSpeakingPersonalityOptions
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _personality = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _expertise,
                decoration: const InputDecoration(labelText: 'Expertise'),
                items: customSpeakingExpertiseOptions
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _expertise = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _voice,
                decoration: const InputDecoration(labelText: 'Voice'),
                items: customSpeakingVoiceOptions
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _voice = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _gradingEnabled,
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable grading'),
                subtitle: const Text(
                  'Keep async grading and result revisit enabled for this conversation.',
                ),
                onChanged: (value) => setState(() => _gradingEnabled = value),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: _isSubmitting ? 'Starting...' : 'Start conversation',
                icon: Icons.play_circle_fill_rounded,
                onPressed: _isSubmitting
                    ? null
                    : () => _startConversation(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _startConversation(BuildContext context) async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Topic is required.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final step = await ref
          .read(customSpeakingApiProvider)
          .startConversation(
            StartCustomSpeakingPayload(
              topic: topic,
              style: _style,
              personality: _personality,
              expertise: _expertise,
              voiceName: _voice,
              gradingEnabled: _gradingEnabled,
            ),
          );
      if (!context.mounted) {
        return;
      }
      context.go(
        '/custom-speaking/conversation/${step.conversationId}',
        extra: step,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
