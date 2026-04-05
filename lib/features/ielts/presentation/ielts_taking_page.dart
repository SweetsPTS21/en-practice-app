import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/ielts/ielts_models.dart';
import '../../../core/learning_journey/learning_journey_providers.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../ielts/application/ielts_controllers.dart';
import 'widgets/ielts_markdown_block.dart';
import 'widgets/ielts_practice_widgets.dart';

class IeltsTakingPage extends ConsumerStatefulWidget {
  const IeltsTakingPage({super.key, required this.attemptId});

  final String attemptId;

  @override
  ConsumerState<IeltsTakingPage> createState() => _IeltsTakingPageState();
}

class _IeltsTakingPageState extends ConsumerState<IeltsTakingPage> {
  bool _trackedStart = false;
  bool _completed = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _immersiveEnabled = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _questionAnchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterImmersiveMode();
    });
  }

  @override
  void dispose() {
    _exitImmersiveMode();
    _scrollController.dispose();
    _timer?.cancel();
    if (_trackedStart && !_completed) {
      ref
          .read(learningAnalyticsServiceProvider)
          .registerLearningAbandoned(route: '/ielts/take/${widget.attemptId}');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(ieltsSessionDetailProvider(widget.attemptId));
    final tokens = context.tokens;
    final palette = context.pagePalette(AppPagePaletteKey.ielts);
    final topBarLabel = _buildTopBarLabel(detail.valueOrNull);

    if (!_trackedStart && detail.hasValue) {
      _trackedStart = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(learningAnalyticsServiceProvider)
            .registerLearningStartIfNeeded('/ielts/take/${widget.attemptId}');
      });
    }

    if (_timer == null && detail.hasValue) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _elapsedSeconds += 1;
          });
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _showBackBlockedMessage();
      },
      child: Scaffold(
        backgroundColor: tokens.background.body,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                palette.heroTop.withValues(alpha: 0.08),
                tokens.background.body,
                tokens.background.canvas,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _TakingTopBar(
                    label: topBarLabel,
                    onStopPressed: _stopSession,
                    onSubmitPressed: () {
                      if (!detail.isLoading) {
                        _submitSession();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: switch (detail) {
                    AsyncData(:final value) => _buildFullscreenLoaded(
                      context,
                      value,
                    ),
                    AsyncError(:final error) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AppErrorCard(
                        title: 'Session unavailable',
                        message: error.toString(),
                        onRetry: () => ref.invalidate(
                          ieltsSessionDetailProvider(widget.attemptId),
                        ),
                      ),
                    ),
                    _ => const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AppLoadingCard(
                        height: 240,
                        message: 'Loading session...',
                      ),
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenLoaded(
    BuildContext context,
    IeltsSessionDetail detail,
  ) {
    if (detail.allQuestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: AppEmptyState(
          icon: Icons.quiz_outlined,
          title: 'No questions in this session',
          subtitle: 'Reload the session or reopen from the detail page.',
        ),
      );
    }

    final runtime = ref.watch(ieltsSessionControllerProvider(detail));
    final controller = ref.read(
      ieltsSessionControllerProvider(detail).notifier,
    );
    final focusedQuestion =
        runtime.focusedQuestion ?? detail.allQuestions.first;
    final activeSection = detail.sections.firstWhere(
      (section) => section.id == runtime.activeSectionId,
      orElse: () => detail.sections.first,
    );
    final sectionInstructions = activeSection.instructions?.trim();
    final sectionAudioUrl = activeSection.audioUrl?.trim();
    final isPassageDrivenSection =
        detail.skill == IeltsSkill.reading ||
        detail.skill == IeltsSkill.listening;
    final currentSectionQuestions = activeSection.questions;
    final questionIndex = currentSectionQuestions.indexWhere(
      (item) => item.questionId == focusedQuestion.questionId,
    );
    final sectionQuestionPassages = _readingQuestionPassages(activeSection);
    final sharedReadingPassages = detail.skill == IeltsSkill.reading
        ? _sharedReadingPassages(activeSection)
        : const <IeltsPassageContent>[];
    final activePassage = isPassageDrivenSection
        ? _resolveActiveReadingPassage(
            activeSection,
            focusedQuestion.questionId,
          )
        : null;
    final activePassageQuestions = activePassage == null
        ? const <IeltsQuestion>[]
        : currentSectionQuestions
              .where((question) => question.passageId == activePassage.id)
              .toList(growable: false);
    final previousPassageTarget = isPassageDrivenSection
        ? _findAdjacentReadingTarget(
            detail,
            activeSectionId: activeSection.id,
            currentPassageId: activePassage?.id,
            direction: -1,
          )
        : null;
    final nextPassageTarget = isPassageDrivenSection
        ? _findAdjacentReadingTarget(
            detail,
            activeSectionId: activeSection.id,
            currentPassageId: activePassage?.id,
            direction: 1,
          )
        : null;
    final remainingSeconds = detail.remainingSeconds == null
        ? (detail.timeLimitSeconds == null
              ? null
              : math.max(detail.timeLimitSeconds! - _elapsedSeconds, 0))
        : math.max(detail.remainingSeconds! - _elapsedSeconds, 0);

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        AppCard(
          strong: true,
          child: _SessionOverviewCard(
            detail: detail,
            runtime: runtime,
            remainingSeconds: remainingSeconds ?? _elapsedSeconds,
            isCountdown: remainingSeconds != null,
            onSectionPressed: (sectionId) =>
                _selectSectionAndScrollTop(controller, sectionId),
          ),
        ),
        if ((sectionInstructions ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          _MarkdownContentCard(
            label: 'Section instructions',
            data: sectionInstructions!,
          ),
        ],
        if ((sectionAudioUrl ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Listening source',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _SectionAudioPlayer(
                  key: ValueKey(activeSection.id),
                  audioUrl: sectionAudioUrl!,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (isPassageDrivenSection && activePassage != null) ...[
          _ReadingPassageNavigator(
            section: activeSection,
            passages: sectionQuestionPassages,
            activePassageId: activePassage.id,
            answers: runtime.answers,
            questions: currentSectionQuestions,
            onPassagePressed: (passage) {
              final targetQuestionId = _firstQuestionIdForPassage(
                activeSection,
                passage.id,
              );
              if (targetQuestionId != null) {
                _focusQuestionAndScrollTop(
                  controller,
                  activeSection.id,
                  targetQuestionId,
                );
              }
            },
          ),
          if (sharedReadingPassages.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ReadingPassageSection(
              section: activeSection,
              passages: sharedReadingPassages,
              label: 'Source passage',
            ),
          ],
          const SizedBox(height: 4),
          _ReadingPassageSection(
            section: activeSection,
            passages: [activePassage],
            label: detail.skill == IeltsSkill.listening
                ? 'Passage content'
                : 'Question passage',
          ),
          const SizedBox(height: 12),
          SizedBox(key: _questionAnchorKey),
          ...activePassageQuestions.asMap().entries.expand((entry) sync* {
            final question = entry.value;
            yield IeltsQuestionRenderer(
              question: question,
              answers: runtime.answers[question.questionId] ?? const <String>[],
              onSingleAnswerSelected: (answer) =>
                  controller.selectSingleAnswer(question.questionId, answer),
              onMultipleAnswerToggled: (answer) =>
                  controller.toggleMultipleAnswer(question.questionId, answer),
              onSlotAnswerChanged: (slotIndex, answer) => controller
                  .updateSlotAnswer(question.questionId, slotIndex, answer),
              showContextText: false,
              showPassageTitle: false,
            );
            if (entry.key != activePassageQuestions.length - 1) {
              yield const SizedBox(height: 12);
            }
          }),
        ] else ...[
          SizedBox(key: _questionAnchorKey),
          IeltsQuestionRenderer(
            question: focusedQuestion,
            answers:
                runtime.answers[focusedQuestion.questionId] ?? const <String>[],
            onSingleAnswerSelected: (answer) => controller.selectSingleAnswer(
              focusedQuestion.questionId,
              answer,
            ),
            onMultipleAnswerToggled: (answer) => controller
                .toggleMultipleAnswer(focusedQuestion.questionId, answer),
            onSlotAnswerChanged: (slotIndex, answer) =>
                controller.updateSlotAnswer(
                  focusedQuestion.questionId,
                  slotIndex,
                  answer,
                ),
          ),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: isPassageDrivenSection
                      ? 'Previous passage'
                      : 'Previous',
                  variant: AppButtonVariant.outline,
                  onPressed: isPassageDrivenSection
                      ? (previousPassageTarget == null
                            ? null
                            : () => _focusQuestionAndScrollTop(
                                controller,
                                previousPassageTarget.sectionId,
                                previousPassageTarget.questionId,
                              ))
                      : (questionIndex <= 0
                            ? null
                            : () => _focusQuestionAndScrollTop(
                                controller,
                                activeSection.id,
                                currentSectionQuestions[questionIndex - 1]
                                    .questionId,
                              )),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: isPassageDrivenSection ? 'Continue' : 'Next',
                  variant: AppButtonVariant.tonal,
                  onPressed: isPassageDrivenSection
                      ? (nextPassageTarget == null
                            ? null
                            : () => _focusQuestionAndScrollTop(
                                controller,
                                nextPassageTarget.sectionId,
                                nextPassageTarget.questionId,
                              ))
                      : (questionIndex < 0 ||
                                questionIndex >=
                                    currentSectionQuestions.length - 1
                            ? null
                            : () => _focusQuestionAndScrollTop(
                                controller,
                                activeSection.id,
                                currentSectionQuestions[questionIndex + 1]
                                    .questionId,
                              )),
                ),
              ),
            ],
          ),
        ),
        if (!isPassageDrivenSection) ...[
          const SizedBox(height: 12),
          IeltsQuestionNavigator(
            questions: currentSectionQuestions,
            focusedQuestionId: focusedQuestion.questionId,
            answers: runtime.answers,
            onQuestionPressed: (question) => _focusQuestionAndScrollTop(
              controller,
              activeSection.id,
              question.questionId,
            ),
          ),
        ],
      ],
    );
  }

  String _buildTopBarLabel(IeltsSessionDetail? detail) {
    if (detail == null) {
      return 'Loading session...';
    }
    final seconds = detail.remainingSeconds == null
        ? _elapsedSeconds
        : math.max(detail.remainingSeconds! - _elapsedSeconds, 0);
    final label = detail.remainingSeconds == null ? '' : 'Remaining';
    return '$label ${_formatClock(seconds)}';
  }

  void _selectSectionAndScrollTop(
    IeltsSessionController controller,
    String sectionId,
  ) {
    controller.selectSection(sectionId);
    _jumpToTop();
  }

  void _focusQuestionAndScrollTop(
    IeltsSessionController controller,
    String sectionId,
    String questionId,
  ) {
    controller.focusQuestion(sectionId, questionId);
    _scrollToQuestionAnchor();
  }

  void _jumpToTop() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.jumpTo(0);
  }

  void _scrollToQuestionAnchor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _questionAnchorKey.currentContext;
      if (context == null) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
      );
    });
  }

  Future<void> _enterImmersiveMode() async {
    if (_immersiveEnabled) {
      return;
    }
    _immersiveEnabled = true;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _exitImmersiveMode() async {
    if (!_immersiveEnabled) {
      return;
    }
    _immersiveEnabled = false;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  void _showBackBlockedMessage() {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Use Stop test or Submit test to leave this screen.'),
        ),
      );
  }

  Future<void> _stopSession() async {
    final shouldStop =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Stop test?'),
              content: const Text(
                'You will leave full-screen mode and this attempt will remain unfinished.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Continue test'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Stop test'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!shouldStop || !mounted) {
      return;
    }
    await _exitImmersiveMode();
    if (!mounted) {
      return;
    }
    context.go('/ielts');
  }

  Future<void> _submitSession() async {
    final detail = ref
        .read(ieltsSessionDetailProvider(widget.attemptId))
        .valueOrNull;
    if (detail == null) {
      return;
    }
    try {
      await ref.read(ieltsSessionControllerProvider(detail).notifier).submit();
      _completed = true;
      await ref
          .read(learningAnalyticsServiceProvider)
          .registerLearningCompletion(route: '/ielts/take/${widget.attemptId}');
      if (!mounted) {
        return;
      }
      await _exitImmersiveMode();
      if (!mounted) {
        return;
      }
      context.go('/ielts/result/${widget.attemptId}');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _TakingTopBar extends StatelessWidget {
  const _TakingTopBar({
    required this.label,
    required this.onStopPressed,
    required this.onSubmitPressed,
  });

  final String label;
  final VoidCallback onStopPressed;
  final VoidCallback onSubmitPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: tokens.background.mobileDrawer,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          AppButton(
            label: 'Stop test',
            variant: AppButtonVariant.outline,
            icon: Icons.close_rounded,
            onPressed: onStopPressed,
          ),
          const SizedBox(width: 8),
          AppButton(
            label: 'Submit',
            icon: Icons.check_circle_rounded,
            onPressed: onSubmitPressed,
          ),
        ],
      ),
    );
  }
}

class _SectionAudioPlayer extends StatefulWidget {
  const _SectionAudioPlayer({super.key, required this.audioUrl});

  final String audioUrl;

  @override
  State<_SectionAudioPlayer> createState() => _SectionAudioPlayerState();
}

class _SectionAudioPlayerState extends State<_SectionAudioPlayer> {
  late final AudioPlayer _player;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadAudio();
  }

  @override
  void didUpdateWidget(covariant _SectionAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _loadAudio();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    setState(() {
      _loadError = null;
    });
    try {
      await _player.stop();
      await _player.setUrl(widget.audioUrl);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = 'Audio unavailable';
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
      return;
    }
    await _player.play();
  }

  Future<void> _seekRelative(Duration delta) async {
    final duration = _player.duration ?? Duration.zero;
    final current = _player.position;
    final target = current + delta;
    final bounded = target < Duration.zero
        ? Duration.zero
        : target > duration
        ? duration
        : target;
    await _player.seek(bounded);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    if (_loadError != null) {
      return Text(
        _loadError!,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: tokens.danger),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final isLoading =
                state?.processingState == ProcessingState.loading ||
                state?.processingState == ProcessingState.buffering;
            final isPlaying = state?.playing ?? false;
            final isCompleted =
                state?.processingState == ProcessingState.completed;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (isCompleted) {
                            await _player.seek(Duration.zero);
                          }
                          await _togglePlayback();
                        },
                  compact: true,
                  icon: isPlaying && !isCompleted
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: isPlaying && !isCompleted ? 'Pause' : 'Play',
                ),
                AppButton(
                  onPressed: () => _seekRelative(const Duration(seconds: -10)),
                  compact: true,
                  variant: AppButtonVariant.outline,
                  icon: Icons.replay_10_rounded,
                  label: '-10s',
                ),
                AppButton(
                  onPressed: () => _seekRelative(const Duration(seconds: 10)),
                  compact: true,
                  variant: AppButtonVariant.outline,
                  icon: Icons.forward_10_rounded,
                  label: '+10s',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        StreamBuilder<Duration?>(
          stream: _player.durationStream,
          builder: (context, durationSnapshot) {
            final total = durationSnapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final maxMillis = math.max(total.inMilliseconds, 1);
                final value = position.inMilliseconds
                    .clamp(0, maxMillis)
                    .toDouble();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: value,
                      min: 0,
                      max: maxMillis.toDouble(),
                      onChanged: total == Duration.zero
                          ? null
                          : (nextValue) => _player.seek(
                              Duration(milliseconds: nextValue.round()),
                            ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatAudioDuration(position),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: tokens.text.secondary),
                        ),
                        const Spacer(),
                        Text(
                          _formatAudioDuration(total),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: tokens.text.secondary),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

String _formatClock(int seconds) {
  final safeSeconds = math.max(seconds, 0);
  final minutes = safeSeconds ~/ 60;
  final remainSeconds = safeSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainSeconds.toString().padLeft(2, '0')}';
}

String _formatAudioDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class _SessionOverviewCard extends StatelessWidget {
  const _SessionOverviewCard({
    required this.detail,
    required this.runtime,
    required this.remainingSeconds,
    required this.isCountdown,
    required this.onSectionPressed,
  });

  final IeltsSessionDetail detail;
  final IeltsSessionRuntime runtime;
  final int remainingSeconds;
  final bool isCountdown;
  final ValueChanged<String> onSectionPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.testTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: IeltsSessionTimer(
                label: isCountdown ? 'Remaining' : '',
                seconds: remainingSeconds,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: tokens.background.panelStrong,
                  borderRadius: BorderRadius.circular(tokens.radius.xl),
                  border: Border.all(color: tokens.border.subtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${runtime.answeredCount}/${detail.questionCount}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: detail.sections
              .map((section) {
                final selected = section.id == runtime.activeSectionId;
                return InkWell(
                  onTap: () => onSectionPressed(section.id),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (selected ? tokens.primary : tokens.text.secondary)
                          .withValues(alpha: selected ? 0.16 : 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color:
                            (selected ? tokens.primary : tokens.text.secondary)
                                .withValues(alpha: 0.16),
                      ),
                    ),
                    child: Text(
                      _sectionDisplayTitle(section),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? tokens.primary
                            : tokens.text.secondary,
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

List<IeltsPassageContent> _readingQuestionPassages(
  IeltsSessionSection section,
) {
  return section.passages
      .where((passage) => passage.hasQuestions)
      .toList(growable: false);
}

List<IeltsPassageContent> _sharedReadingPassages(IeltsSessionSection section) {
  return section.passages
      .where((passage) => passage.sharedContentOnly || !passage.hasQuestions)
      .toList(growable: false);
}

IeltsPassageContent? _resolveActiveReadingPassage(
  IeltsSessionSection section,
  String focusedQuestionId,
) {
  final focusedQuestion = section.questions.where((question) {
    return question.questionId == focusedQuestionId;
  }).firstOrNull;
  final passages = _readingQuestionPassages(section);
  if (focusedQuestion?.passageId != null) {
    for (final passage in passages) {
      if (passage.id == focusedQuestion!.passageId) {
        return passage;
      }
    }
  }
  return passages.isEmpty ? null : passages.first;
}

String? _firstQuestionIdForPassage(
  IeltsSessionSection section,
  String passageId,
) {
  for (final question in section.questions) {
    if (question.passageId == passageId) {
      return question.questionId;
    }
  }
  return null;
}

_ReadingTarget? _findAdjacentReadingTarget(
  IeltsSessionDetail detail, {
  required String activeSectionId,
  required String? currentPassageId,
  required int direction,
}) {
  final sectionOrder = detail.sections
      .where((section) => _readingQuestionPassages(section).isNotEmpty)
      .toList(growable: false);
  final activeSectionIndex = sectionOrder.indexWhere(
    (section) => section.id == activeSectionId,
  );
  if (activeSectionIndex < 0) {
    return null;
  }
  final activeSection = sectionOrder[activeSectionIndex];
  final activePassages = _readingQuestionPassages(activeSection);
  final activePassageIndex = currentPassageId == null
      ? -1
      : activePassages.indexWhere((passage) => passage.id == currentPassageId);

  if (direction < 0) {
    if (activePassageIndex > 0) {
      final previousPassage = activePassages[activePassageIndex - 1];
      final questionId = _firstQuestionIdForPassage(
        activeSection,
        previousPassage.id,
      );
      return questionId == null
          ? null
          : _ReadingTarget(sectionId: activeSection.id, questionId: questionId);
    }
    if (activeSectionIndex <= 0) {
      return null;
    }
    final previousSection = sectionOrder[activeSectionIndex - 1];
    final previousPassages = _readingQuestionPassages(previousSection);
    if (previousPassages.isEmpty) {
      return null;
    }
    final previousPassage = previousPassages.last;
    final questionId = _firstQuestionIdForPassage(
      previousSection,
      previousPassage.id,
    );
    return questionId == null
        ? null
        : _ReadingTarget(sectionId: previousSection.id, questionId: questionId);
  }

  if (activePassageIndex >= 0 &&
      activePassageIndex < activePassages.length - 1) {
    final nextPassage = activePassages[activePassageIndex + 1];
    final questionId = _firstQuestionIdForPassage(
      activeSection,
      nextPassage.id,
    );
    return questionId == null
        ? null
        : _ReadingTarget(sectionId: activeSection.id, questionId: questionId);
  }
  if (activeSectionIndex >= sectionOrder.length - 1) {
    return null;
  }
  final nextSection = sectionOrder[activeSectionIndex + 1];
  final nextPassages = _readingQuestionPassages(nextSection);
  if (nextPassages.isEmpty) {
    return null;
  }
  final nextPassage = nextPassages.first;
  final questionId = _firstQuestionIdForPassage(nextSection, nextPassage.id);
  return questionId == null
      ? null
      : _ReadingTarget(sectionId: nextSection.id, questionId: questionId);
}

class _ReadingTarget {
  const _ReadingTarget({required this.sectionId, required this.questionId});

  final String sectionId;
  final String questionId;
}

class _ReadingPassageNavigator extends StatelessWidget {
  const _ReadingPassageNavigator({
    required this.section,
    required this.passages,
    required this.activePassageId,
    required this.answers,
    required this.questions,
    required this.onPassagePressed,
  });

  final IeltsSessionSection section;
  final List<IeltsPassageContent> passages;
  final String activePassageId;
  final Map<String, List<String>> answers;
  final List<IeltsQuestion> questions;
  final ValueChanged<IeltsPassageContent> onPassagePressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Passages', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: passages
                .map((passage) {
                  final passageQuestions = questions
                      .where((question) => question.passageId == passage.id)
                      .toList(growable: false);
                  final answeredCount = passageQuestions.where((question) {
                    return (answers[question.questionId] ?? const <String>[])
                        .any((value) => value.trim().isNotEmpty);
                  }).length;
                  final selected = passage.id == activePassageId;
                  final complete =
                      passageQuestions.isNotEmpty &&
                      answeredCount == passageQuestions.length;
                  final color = selected
                      ? tokens.primary
                      : complete
                      ? tokens.success
                      : tokens.text.secondary;
                  return InkWell(
                    onTap: () => onPassagePressed(passage),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: selected ? 0.16 : 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: color.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        '${_compactReadingPassageTitle(section, passage)} · $answeredCount/${passageQuestions.length}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: color),
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _ReadingPassageCard extends StatelessWidget {
  const _ReadingPassageCard({
    required this.label,
    required this.badge,
    required this.title,
    required this.content,
  });

  final String label;
  final String badge;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.tokens.text.secondary),
        ),
        const SizedBox(height: 6),
        Text(
          badge,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: context.tokens.primary),
        ),
        if (title.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
        const SizedBox(height: 12),
        IeltsMarkdownBlock(data: _normalizePassageMarkdown(content)),
      ],
    );
  }
}

class _ReadingPassageSection extends StatelessWidget {
  const _ReadingPassageSection({
    required this.section,
    required this.passages,
    required this.label,
  });

  final IeltsSessionSection section;
  final List<IeltsPassageContent> passages;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (passages.isEmpty) {
      return const SizedBox.shrink();
    }
    return AppCard(
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in passages.asMap().entries) ...[
            _ReadingPassageCard(
              label: label,
              badge: _compactReadingPassageTitle(section, entry.value),
              title: _readingPassageHeading(entry.value),
              content: entry.value.content ?? '',
            ),
            if (entry.key != passages.length - 1) ...[
              const SizedBox(height: 12),
              Divider(color: context.tokens.border.subtle),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

String _compactReadingPassageTitle(
  IeltsSessionSection section,
  IeltsPassageContent passage,
) {
  final rawTitle = (passage.title ?? '').trim();
  if (_isQuestionGroupTitle(rawTitle)) {
    return rawTitle.replaceAll('–', '-');
  }
  return 'Passage ${passage.passageOrder}';
}

String _readingPassageHeading(IeltsPassageContent passage) {
  final title = (passage.title ?? '').trim();
  if (title.isEmpty || _isQuestionGroupTitle(title)) {
    return '';
  }
  return title;
}

bool _isQuestionGroupTitle(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized.startsWith('question ') ||
      normalized.startsWith('questions ');
}

String _normalizePassageMarkdown(String value) {
  final normalized = value.replaceAll('\r\n', '\n');
  return normalized.replaceAllMapped(
    RegExp(r'(?<!\n)\n(!\[)'),
    (match) => '\n\n${match.group(1)}',
  );
}

class _MarkdownContentCard extends StatelessWidget {
  const _MarkdownContentCard({required this.label, required this.data});

  final String label;
  final String data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.tokens.text.secondary,
            ),
          ),
          const SizedBox(height: 8),
          IeltsMarkdownBlock(data: _normalizePassageMarkdown(data)),
        ],
      ),
    );
  }
}

String _sectionDisplayTitle(IeltsSessionSection section) {
  final title = (section.title ?? '').trim();
  if (title.isNotEmpty) {
    return title;
  }
  return 'Section ${section.sectionOrder}';
}
