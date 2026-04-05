import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/custom_speaking/custom_speaking_models.dart';
import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_header_icon_action.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
import '../application/custom_speaking_setup_controller.dart';

class CustomSpeakingPage extends ConsumerStatefulWidget {
  const CustomSpeakingPage({super.key});

  @override
  ConsumerState<CustomSpeakingPage> createState() => _CustomSpeakingPageState();
}

class _CustomSpeakingPageState extends ConsumerState<CustomSpeakingPage> {
  late final TextEditingController _topicController;

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
    final state = ref.watch(customSpeakingSetupControllerProvider);
    final controller = ref.read(customSpeakingSetupControllerProvider.notifier);
    final tokens = context.tokens;

    return AppPageScaffold(
      title: 'Custom speaking',
      subtitle:
          'Start a focused speaking conversation, keep the turn loop live, and continue from the same route if you come back later.',
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
              Text(
                'Conversation setup',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a topic and tone, then jump straight into the chat loop.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _topicController,
                onChanged: controller.updateTopic,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  hintText:
                      'Example: how technology is changing the way people learn English',
                ),
              ),
              const SizedBox(height: 16),
              _OptionDropdown<String>(
                label: 'Style',
                value: state.style,
                items: customSpeakingStyleOptions
                    .map((item) => DropdownMenuItem<String>(
                          value: item.value,
                          child: Text(item.label),
                        ))
                    .toList(growable: false),
                helperText: _descriptionForOption(
                  customSpeakingStyleOptions,
                  state.style,
                ),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectStyle(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              _OptionDropdown<String>(
                label: 'Personality',
                value: state.personality,
                items: customSpeakingPersonalityOptions
                    .map((item) => DropdownMenuItem<String>(
                          value: item.value,
                          child: Text(item.label),
                        ))
                    .toList(growable: false),
                helperText: _descriptionForOption(
                  customSpeakingPersonalityOptions,
                  state.personality,
                ),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectPersonality(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              _OptionDropdown<String>(
                label: 'Expertise',
                value: state.expertise,
                items: customSpeakingExpertiseOptions
                    .map((item) => DropdownMenuItem<String>(
                          value: item.value,
                          child: Text(item.label),
                        ))
                    .toList(growable: false),
                helperText: _descriptionForOption(
                  customSpeakingExpertiseOptions,
                  state.expertise,
                ),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectExpertise(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              _OptionDropdown<String?>(
                label: 'Voice',
                value: state.voiceName,
                items: customSpeakingVoiceOptions
                    .map((item) => DropdownMenuItem<String?>(
                          value: item.value,
                          child: Text(item.label),
                        ))
                    .toList(growable: false),
                helperText: _descriptionForVoice(state.voiceName),
                onChanged: controller.selectVoice,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: state.gradingEnabled,
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable grading'),
                subtitle: const Text(
                  'Keep result review and completion scoring available after the conversation ends.',
                ),
                onChanged: controller.setGradingEnabled,
              ),
              if ((state.errorMessage ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.danger),
                ),
              ],
              const SizedBox(height: 16),
              AppButton(
                label: state.isSubmitting ? 'Starting...' : 'Start conversation',
                icon: Icons.play_circle_fill_rounded,
                onPressed: state.isSubmitting
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
    try {
      final bootstrap = await ref
          .read(customSpeakingSetupControllerProvider.notifier)
          .startConversation();
      if (!context.mounted) {
        return;
      }
      context.go(
        '/custom-speaking/conversation/${bootstrap.conversationId}',
        extra: bootstrap,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _descriptionForOption(
    List<CustomSpeakingOption> options,
    String selectedValue,
  ) {
    for (final option in options) {
      if (option.value == selectedValue) {
        return option.description;
      }
    }
    return '';
  }

  String _descriptionForVoice(String? selectedValue) {
    for (final option in customSpeakingVoiceOptions) {
      if (option.value == selectedValue) {
        return option.description;
      }
    }
    return customSpeakingVoiceOptions.first.description;
  }
}

class _OptionDropdown<T> extends StatelessWidget {
  const _OptionDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.helperText,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final String helperText;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          decoration: InputDecoration(labelText: label),
          onChanged: onChanged,
        ),
        const SizedBox(height: 6),
        Text(
          helperText,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.text.secondary),
        ),
      ],
    );
  }
}
