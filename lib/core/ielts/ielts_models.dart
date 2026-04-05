import '../learning_journey/completion_snapshot_models.dart';

enum IeltsSkill {
  reading('READING', 'Reading'),
  listening('LISTENING', 'Listening'),
  unknown('UNKNOWN', 'IELTS');

  const IeltsSkill(this.apiValue, this.label);

  final String apiValue;
  final String label;

  bool get isListening => this == IeltsSkill.listening;
}

enum IeltsAttemptMode {
  full('FULL', 'Full test'),
  quick('QUICK', 'Quick practice'),
  unknown('UNKNOWN', 'Practice');

  const IeltsAttemptMode(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum IeltsScopeType {
  fullTest('TEST', 'Full test'),
  section('SECTION', 'Section'),
  passage('PASSAGE', 'Passage'),
  unknown('UNKNOWN', 'Scope');

  const IeltsScopeType(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum IeltsAttemptStatus {
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  unknown('UNKNOWN');

  const IeltsAttemptStatus(this.apiValue);

  final String apiValue;

  bool get isFinished => this == IeltsAttemptStatus.completed;
}

enum IeltsQuestionType {
  singleChoice('SINGLE_CHOICE'),
  multipleChoice('MULTIPLE_CHOICE'),
  trueFalseNotGiven('TRUE_FALSE_NOT_GIVEN'),
  yesNoNotGiven('YES_NO_NOT_GIVEN'),
  formCompletion('FORM_COMPLETION'),
  sentenceCompletion('SENTENCE_COMPLETION'),
  summaryCompletion('SUMMARY_COMPLETION'),
  matching('MATCHING'),
  matchingHeadings('MATCHING_HEADINGS'),
  mapLabeling('MAP_LABELING'),
  passageCompletion('PASSAGE_COMPLETION'),
  unknown('UNKNOWN');

  const IeltsQuestionType(this.apiValue);

  final String apiValue;

  bool get isSingleSelection =>
      this == IeltsQuestionType.singleChoice ||
      this == IeltsQuestionType.trueFalseNotGiven ||
      this == IeltsQuestionType.yesNoNotGiven;

  bool get isMultiSelection => this == IeltsQuestionType.multipleChoice;

  bool get usesTextInputs =>
      this == IeltsQuestionType.formCompletion ||
      this == IeltsQuestionType.sentenceCompletion ||
      this == IeltsQuestionType.summaryCompletion ||
      this == IeltsQuestionType.passageCompletion;

  bool get usesSlotSelection =>
      this == IeltsQuestionType.matching ||
      this == IeltsQuestionType.matchingHeadings ||
      this == IeltsQuestionType.mapLabeling;
}

class IeltsLaunchIntent {
  const IeltsLaunchIntent({
    this.mode,
    this.skill,
    this.testId,
    this.attemptMode,
    this.scopeType,
    this.scopeId,
  });

  final String? mode;
  final IeltsSkill? skill;
  final String? testId;
  final IeltsAttemptMode? attemptMode;
  final IeltsScopeType? scopeType;
  final String? scopeId;

  bool get hasDirectStart =>
      (testId ?? '').isNotEmpty &&
      attemptMode != null &&
      scopeType != null &&
      (scopeType == IeltsScopeType.fullTest || (scopeId ?? '').isNotEmpty);

  factory IeltsLaunchIntent.fromUri(Uri uri) {
    return IeltsLaunchIntent(
      mode: _readNullableString(uri.queryParameters['mode']),
      skill: _skillFromString(uri.queryParameters['skill']),
      testId: _readNullableString(uri.queryParameters['testId']),
      attemptMode: _attemptModeFromString(uri.queryParameters['attemptMode']),
      scopeType: _scopeTypeFromString(uri.queryParameters['scopeType']),
      scopeId: _readNullableString(uri.queryParameters['scopeId']),
    );
  }
}

class IeltsHighestScore {
  const IeltsHighestScore({
    required this.testId,
    this.bandScore,
    this.accuracyPercent,
    this.attemptId,
    this.attemptCount = 0,
  });

  final String testId;
  final double? bandScore;
  final double? accuracyPercent;
  final String? attemptId;
  final int attemptCount;

  bool get hasScore => bandScore != null || accuracyPercent != null;

  factory IeltsHighestScore.fromJson(Map<String, dynamic> json) {
    return IeltsHighestScore(
      testId:
          _readNullableString(
            json['testId'] ?? json['id'] ?? json['test_id'],
          ) ??
          '',
      bandScore: _readDouble(
        json['bandScore'] ?? json['highestBandScore'] ?? json['score'],
      ),
      accuracyPercent: _readDouble(
        json['accuracyPercent'] ??
            json['highestAccuracyPercent'] ??
            json['accuracy'],
      ),
      attemptId: _readNullableString(
        json['attemptId'] ?? json['bestAttemptId'] ?? json['latestAttemptId'],
      ),
      attemptCount: _readInt(json['attemptCount'] ?? json['completedAttempts']),
    );
  }
}

class IeltsTestSummary {
  const IeltsTestSummary({
    required this.testId,
    required this.title,
    required this.skill,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.sectionCount,
    required this.tags,
    this.description,
    this.difficulty,
    this.latestAttemptId,
    this.highestScore,
  });

  final String testId;
  final String title;
  final IeltsSkill skill;
  final int questionCount;
  final int estimatedMinutes;
  final int sectionCount;
  final List<String> tags;
  final String? description;
  final String? difficulty;
  final String? latestAttemptId;
  final IeltsHighestScore? highestScore;

  IeltsTestSummary copyWith({IeltsHighestScore? highestScore}) {
    return IeltsTestSummary(
      testId: testId,
      title: title,
      skill: skill,
      questionCount: questionCount,
      estimatedMinutes: estimatedMinutes,
      sectionCount: sectionCount,
      tags: tags,
      description: description,
      difficulty: difficulty,
      latestAttemptId: latestAttemptId,
      highestScore: highestScore ?? this.highestScore,
    );
  }

  factory IeltsTestSummary.fromJson(Map<String, dynamic> json) {
    final sections = _readList(json['sections']);
    final rawTags = _readStringList(json['tags']);
    final difficulty = _readNullableString(json['difficulty']);
    return IeltsTestSummary(
      testId:
          _readNullableString(
            json['testId'] ?? json['id'] ?? json['test_id'],
          ) ??
          '',
      title:
          _readNullableString(json['title'] ?? json['name']) ??
          'IELTS practice',
      skill: _skillFromString(json['skill'] ?? json['module']),
      questionCount: _readInt(
        json['questionCount'] ??
            json['totalQuestions'] ??
            json['questionsCount'],
      ),
      estimatedMinutes: _readInt(
        json['estimatedMinutes'] ??
            json['durationMinutes'] ??
            json['timeLimitMinutes'],
      ),
      sectionCount: sections.length,
      tags: [
        if (difficulty != null && difficulty.isNotEmpty) difficulty,
        ...rawTags,
      ],
      description: _readNullableString(
        json['description'] ?? json['subtitle'] ?? json['overview'],
      ),
      difficulty: difficulty,
      latestAttemptId: _readNullableString(
        json['latestAttemptId'] ?? json['resumeAttemptId'],
      ),
      highestScore: json['highestScore'] is Map
          ? IeltsHighestScore.fromJson(jsonMap(json['highestScore']))
          : null,
    );
  }
}

class IeltsPassageSummary {
  const IeltsPassageSummary({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.isSelectable,
    this.description,
    this.sharedContextOnly = false,
  });

  final String id;
  final String title;
  final int questionCount;
  final bool isSelectable;
  final String? description;
  final bool sharedContextOnly;

  factory IeltsPassageSummary.fromJson(Map<String, dynamic> json) {
    return IeltsPassageSummary(
      id: _readNullableString(json['id'] ?? json['passageId']) ?? '',
      title: _readNullableString(json['title'] ?? json['name']) ?? 'Passage',
      questionCount: _readInt(
        json['questionCount'] ??
            json['totalQuestions'] ??
            _readList(json['questions']).length,
      ),
      isSelectable:
          json['isSelectable'] != false &&
          json['sharedContentOnly'] != true &&
          json['sharedContextOnly'] != true &&
          json['contextOnly'] != true,
      description: _readNullableString(
        json['description'] ?? json['summary'] ?? json['instruction'],
      ),
      sharedContextOnly:
          json['sharedContentOnly'] == true ||
          json['sharedContextOnly'] == true ||
          json['contextOnly'] == true,
    );
  }
}

class IeltsSectionSummary {
  const IeltsSectionSummary({
    required this.id,
    required this.title,
    required this.skill,
    required this.questionCount,
    required this.passages,
    this.description,
    this.audioUrl,
  });

  final String id;
  final String title;
  final IeltsSkill skill;
  final int questionCount;
  final List<IeltsPassageSummary> passages;
  final String? description;
  final String? audioUrl;

  factory IeltsSectionSummary.fromJson(Map<String, dynamic> json) {
    final passages = _readList(
      json['passages'],
    ).map(IeltsPassageSummary.fromJson).toList(growable: false);
    return IeltsSectionSummary(
      id: _readNullableString(json['id'] ?? json['sectionId']) ?? '',
      title: _readNullableString(json['title'] ?? json['name']) ?? 'Section',
      skill: _skillFromString(json['skill']),
      questionCount: _readInt(
        json['questionCount'] ??
            json['totalQuestions'] ??
            _readList(json['questions']).length,
      ),
      passages: passages,
      description: _readNullableString(
        json['description'] ?? json['instruction'] ?? json['overview'],
      ),
      audioUrl: _readNullableString(json['audioUrl']),
    );
  }
}

class IeltsTestDetail {
  const IeltsTestDetail({
    required this.testId,
    required this.title,
    required this.skill,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.sections,
    this.description,
    this.instructions,
  });

  final String testId;
  final String title;
  final IeltsSkill skill;
  final int questionCount;
  final int estimatedMinutes;
  final List<IeltsSectionSummary> sections;
  final String? description;
  final String? instructions;

  factory IeltsTestDetail.fromJson(Map<String, dynamic> json) {
    final sections = _readList(
      json['sections'],
    ).map(IeltsSectionSummary.fromJson).toList(growable: false);
    return IeltsTestDetail(
      testId:
          _readNullableString(
            json['testId'] ?? json['id'] ?? json['test_id'],
          ) ??
          '',
      title:
          _readNullableString(json['title'] ?? json['name']) ??
          'IELTS practice',
      skill: _skillFromString(json['skill']),
      questionCount: _readInt(
        json['questionCount'] ??
            json['totalQuestions'] ??
            _countSectionQuestions(sections),
      ),
      estimatedMinutes: _readInt(
        json['estimatedMinutes'] ??
            json['durationMinutes'] ??
            json['timeLimitMinutes'],
      ),
      sections: sections,
      description: _readNullableString(
        json['description'] ?? json['subtitle'] ?? json['overview'],
      ),
      instructions: _readNullableString(
        json['instructions'] ?? json['instruction'] ?? json['guidance'],
      ),
    );
  }
}

class IeltsPracticePassageOption {
  const IeltsPracticePassageOption({
    required this.id,
    required this.title,
    required this.questionCount,
    this.description,
    this.audioSeekHint,
    this.audioSeekStartRatio,
    this.sharedContextOnly = false,
  });

  final String id;
  final String title;
  final int questionCount;
  final String? description;
  final String? audioSeekHint;
  final double? audioSeekStartRatio;
  final bool sharedContextOnly;

  factory IeltsPracticePassageOption.fromJson(Map<String, dynamic> json) {
    return IeltsPracticePassageOption(
      id: _readNullableString(json['id'] ?? json['passageId']) ?? '',
      title: _readNullableString(json['title'] ?? json['name']) ?? 'Passage',
      questionCount: _readInt(
        json['questionCount'] ??
            json['totalQuestions'] ??
            _readList(json['questions']).length,
      ),
      description: _readNullableString(
        json['description'] ?? json['summary'] ?? json['instruction'],
      ),
      audioSeekHint: _readNullableString(json['audioSeekHint']),
      audioSeekStartRatio: _readDouble(json['audioSeekStartRatio']),
      sharedContextOnly:
          json['sharedContentOnly'] == true ||
          json['sharedContextOnly'] == true ||
          json['contextOnly'] == true,
    );
  }
}

class IeltsPracticeSectionOption {
  const IeltsPracticeSectionOption({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.passages,
    this.description,
    this.audioUrl,
  });

  final String id;
  final String title;
  final int questionCount;
  final List<IeltsPracticePassageOption> passages;
  final String? description;
  final String? audioUrl;

  factory IeltsPracticeSectionOption.fromJson(Map<String, dynamic> json) {
    return IeltsPracticeSectionOption(
      id: _readNullableString(json['id'] ?? json['sectionId']) ?? '',
      title: _readNullableString(json['title'] ?? json['name']) ?? 'Section',
      questionCount: _readInt(
        json['questionCount'] ??
            json['totalQuestions'] ??
            _readList(json['questions']).length,
      ),
      passages: _readList(
        json['passages'],
      ).map(IeltsPracticePassageOption.fromJson).toList(growable: false),
      description: _readNullableString(
        json['description'] ?? json['instruction'] ?? json['overview'],
      ),
      audioUrl: _readNullableString(json['audioUrl']),
    );
  }
}

class IeltsPracticeOptions {
  const IeltsPracticeOptions({
    required this.testId,
    required this.skill,
    required this.sections,
    this.instructions,
  });

  final String testId;
  final IeltsSkill skill;
  final List<IeltsPracticeSectionOption> sections;
  final String? instructions;

  factory IeltsPracticeOptions.fromJson(
    Map<String, dynamic> json, {
    required String testId,
    required IeltsSkill fallbackSkill,
  }) {
    return IeltsPracticeOptions(
      testId: _readNullableString(json['testId'] ?? json['id']) ?? testId,
      skill: _skillFromString(json['skill']) == IeltsSkill.unknown
          ? fallbackSkill
          : _skillFromString(json['skill']),
      sections: _readList(
        json['sections'],
      ).map(IeltsPracticeSectionOption.fromJson).toList(growable: false),
      instructions: _readNullableString(
        json['instructions'] ?? json['instruction'] ?? json['overview'],
      ),
    );
  }
}

class IeltsStartSessionPayload {
  const IeltsStartSessionPayload({
    required this.testId,
    required this.attemptMode,
    required this.scopeType,
    this.scopeId,
    this.sourceRecommendationKey,
    this.sourceSurface,
  });

  final String testId;
  final IeltsAttemptMode attemptMode;
  final IeltsScopeType scopeType;
  final String? scopeId;
  final String? sourceRecommendationKey;
  final String? sourceSurface;

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'attemptMode': attemptMode.apiValue,
      'scopeType': scopeType.apiValue,
      if ((scopeId ?? '').isNotEmpty) 'scopeId': scopeId,
      if ((sourceRecommendationKey ?? '').isNotEmpty)
        'sourceRecommendationKey': sourceRecommendationKey,
      if ((sourceSurface ?? '').isNotEmpty) 'sourceSurface': sourceSurface,
    };
  }
}

class IeltsAnswerOption {
  const IeltsAnswerOption({required this.value, required this.label});

  final String value;
  final String label;

  factory IeltsAnswerOption.fromDynamic(Object? value) {
    if (value is Map) {
      final map = jsonMap(value);
      return IeltsAnswerOption(
        value:
            _readNullableString(
              map['value'] ?? map['id'] ?? map['key'] ?? map['code'],
            ) ??
            _readNullableString(map['label'] ?? map['text']) ??
            '',
        label:
            _readNullableString(
              map['label'] ?? map['text'] ?? map['title'] ?? map['value'],
            ) ??
            '',
      );
    }

    final label = value?.toString() ?? '';
    return IeltsAnswerOption(value: label, label: label);
  }
}

class IeltsAnswerSlot {
  const IeltsAnswerSlot({
    required this.id,
    required this.label,
    required this.placeholder,
    required this.options,
  });

  final String id;
  final String label;
  final String placeholder;
  final List<IeltsAnswerOption> options;

  factory IeltsAnswerSlot.fromDynamic(
    Object? value, {
    required int index,
    List<IeltsAnswerOption> fallbackOptions = const <IeltsAnswerOption>[],
  }) {
    if (value is Map) {
      final map = jsonMap(value);
      final slotOptions = _readDynamicList(
        map['options'] ?? map['choices'] ?? map['answerOptions'],
      ).map(IeltsAnswerOption.fromDynamic).toList(growable: false);
      return IeltsAnswerSlot(
        id:
            _readNullableString(map['id'] ?? map['slotId'] ?? map['blankId']) ??
            'slot_$index',
        label:
            _readNullableString(
              map['label'] ?? map['prompt'] ?? map['text'] ?? map['title'],
            ) ??
            'Blank ${index + 1}',
        placeholder:
            _readNullableString(
              map['placeholder'] ?? map['hint'] ?? map['answerHint'],
            ) ??
            'Your answer',
        options: slotOptions.isNotEmpty ? slotOptions : fallbackOptions,
      );
    }

    final label = value?.toString() ?? 'Blank ${index + 1}';
    return IeltsAnswerSlot(
      id: 'slot_$index',
      label: label,
      placeholder: 'Your answer',
      options: fallbackOptions,
    );
  }
}

class IeltsQuestion {
  const IeltsQuestion({
    required this.questionId,
    required this.order,
    required this.navigatorLabel,
    required this.type,
    required this.prompt,
    required this.options,
    required this.answerSlots,
    required this.submittedAnswers,
    required this.correctAnswers,
    required this.metadata,
    this.instruction,
    this.explanation,
    this.sectionId,
    this.sectionTitle,
    this.passageId,
    this.passageTitle,
    this.contextText,
  });

  final String questionId;
  final int order;
  final String navigatorLabel;
  final IeltsQuestionType type;
  final String prompt;
  final String? instruction;
  final List<IeltsAnswerOption> options;
  final List<IeltsAnswerSlot> answerSlots;
  final List<String> submittedAnswers;
  final List<String> correctAnswers;
  final String? explanation;
  final String? sectionId;
  final String? sectionTitle;
  final String? passageId;
  final String? passageTitle;
  final String? contextText;
  final Map<String, dynamic> metadata;

  bool get isAnswered =>
      submittedAnswers.any((value) => value.trim().isNotEmpty);

  factory IeltsQuestion.fromJson(
    Map<String, dynamic> json, {
    String? sectionId,
    String? sectionTitle,
    String? passageId,
    String? passageTitle,
    String? contextText,
    int index = 0,
  }) {
    final type = _questionTypeFromString(json['type'] ?? json['questionType']);
    final options = _readDynamicList(
      json['options'] ?? json['choices'] ?? json['answerOptions'],
    ).map(IeltsAnswerOption.fromDynamic).toList(growable: false);
    final slots = _parseAnswerSlots(json, type, options);

    return IeltsQuestion(
      questionId:
          _readNullableString(
            json['questionId'] ?? json['id'] ?? json['itemId'],
          ) ??
          'question_$index',
      order: _readInt(
        json['order'] ??
            json['questionOrder'] ??
            json['questionNumber'] ??
            json['index'] ??
            index + 1,
      ),
      navigatorLabel:
          _readNullableString(
            json['navigatorLabel'] ??
                json['questionOrder'] ??
                json['displayNumber'] ??
                json['questionNumberLabel'],
          ) ??
          '${_readInt(json['order'] ?? json['questionOrder'] ?? json['questionNumber'] ?? index + 1)}',
      type: type,
      prompt:
          _readNullableString(
            json['prompt'] ??
                json['questionText'] ??
                json['title'] ??
                json['text'] ??
                json['stem'] ??
                json['content'],
          ) ??
          'Question ${index + 1}',
      instruction: _readNullableString(
        json['instruction'] ?? json['instructions'] ?? json['hint'],
      ),
      options: options,
      answerSlots: slots,
      submittedAnswers: _parseAnswerValues(
        json,
        keys: const [
          'submittedAnswers',
          'selectedAnswers',
          'userAnswers',
          'userAnswer',
          'responses',
          'response',
          'submittedAnswer',
          'selectedAnswer',
          'answer',
        ],
      ),
      correctAnswers: _parseAnswerValues(
        json,
        keys: const [
          'correctAnswers',
          'answerKey',
          'correctAnswer',
          'expectedAnswers',
        ],
      ),
      explanation: _readNullableString(json['explanation'] ?? json['feedback']),
      sectionId: sectionId,
      sectionTitle: sectionTitle,
      passageId: passageId,
      passageTitle: passageTitle,
      contextText: contextText,
      metadata: json,
    );
  }
}

class IeltsPassageContent {
  const IeltsPassageContent({
    required this.id,
    required this.passageOrder,
    required this.questions,
    this.title,
    this.content,
    this.sharedContentOnly = false,
  });

  final String id;
  final int passageOrder;
  final String? title;
  final String? content;
  final List<IeltsQuestion> questions;
  final bool sharedContentOnly;

  bool get hasQuestions => questions.isNotEmpty;

  factory IeltsPassageContent.fromJson(
    Map<String, dynamic> json, {
    required int passageIndex,
    required String sectionId,
    required String? sectionTitle,
  }) {
    final passageId =
        _readNullableString(json['id'] ?? json['passageId']) ??
        '$sectionId-passage-${passageIndex + 1}';
    final passageTitle = _readNullableString(json['title']);
    return IeltsPassageContent(
      id: passageId,
      passageOrder: _readInt(json['passageOrder'] ?? passageIndex + 1),
      title: passageTitle,
      content: _readNullableString(json['content']),
      questions: _readList(
        json['questions'],
      ).asMap().entries.map((entry) {
        return IeltsQuestion.fromJson(
          entry.value,
          index: entry.key,
          sectionId: sectionId,
          sectionTitle: sectionTitle,
          passageId: passageId,
          passageTitle: passageTitle,
        );
      }).toList(growable: false),
      sharedContentOnly: json['sharedContentOnly'] == true,
    );
  }
}

class IeltsSessionSection {
  const IeltsSessionSection({
    required this.id,
    required this.sectionOrder,
    required this.passages,
    this.title,
    this.instructions,
    this.audioUrl,
  });

  final String id;
  final int sectionOrder;
  final String? title;
  final List<IeltsPassageContent> passages;
  final String? instructions;
  final String? audioUrl;

  List<IeltsQuestion> get questions =>
      passages.expand((passage) => passage.questions).toList(growable: false);

  factory IeltsSessionSection.fromJson(
    Map<String, dynamic> json, {
    required int sectionIndex,
  }) {
    final sectionId =
        _readNullableString(json['id'] ?? json['sectionId']) ??
        'section_${sectionIndex + 1}';
    final sectionOrder = _readInt(json['sectionOrder'] ?? sectionIndex + 1);
    final sectionTitle = _readNullableString(json['title']);
    final parsedPassages = _readList(
      json['passages'],
    ).asMap().entries.map((entry) {
      return IeltsPassageContent.fromJson(
        entry.value,
        passageIndex: entry.key,
        sectionId: sectionId,
        sectionTitle: sectionTitle,
      );
    }).toList(growable: false);

    return IeltsSessionSection(
      id: sectionId,
      sectionOrder: sectionOrder,
      title: sectionTitle,
      passages: parsedPassages,
      instructions: _readNullableString(json['instructions']),
      audioUrl: _readNullableString(json['audioUrl']),
    );
  }
}

class IeltsSessionDetail {
  const IeltsSessionDetail({
    required this.attemptId,
    required this.testId,
    required this.testTitle,
    required this.skill,
    required this.attemptMode,
    required this.scopeType,
    required this.status,
    required this.sections,
    required this.questionCount,
    required this.answeredCount,
    this.scopeId,
    this.timeLimitSeconds,
    this.remainingSeconds,
    this.startedAt,
    this.submittedAt,
  });

  final String attemptId;
  final String testId;
  final String testTitle;
  final IeltsSkill skill;
  final IeltsAttemptMode attemptMode;
  final IeltsScopeType scopeType;
  final String? scopeId;
  final IeltsAttemptStatus status;
  final int questionCount;
  final int answeredCount;
  final int? timeLimitSeconds;
  final int? remainingSeconds;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final List<IeltsSessionSection> sections;

  List<IeltsQuestion> get allQuestions =>
      sections.expand((section) => section.questions).toList(growable: false);

  bool get isListening => skill.isListening;

  factory IeltsSessionDetail.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? jsonMap(json['data'])
        : json;
    final testDetail = jsonMap(payload['testDetail']);
    final sections = _readList(
          testDetail['sections'],
        )
        .asMap()
        .entries
        .map(
          (entry) => IeltsSessionSection.fromJson(
            entry.value,
            sectionIndex: entry.key,
          ),
        )
        .toList(growable: false);
    final allQuestions = sections
        .expand((section) => section.questions)
        .toList();
    final skill = _skillFromString(
      testDetail['skill'] ?? payload['skill'],
    );
    final timeLimitMinutes = _readNullableInt(
      payload['timeLimitMinutes'] ??
          payload['estimatedMinutes'] ??
          testDetail['timeLimitMinutes'] ??
          testDetail['estimatedMinutes'],
    );
    return IeltsSessionDetail(
      attemptId:
          _readNullableString(
            payload['attemptId'] ?? payload['id'] ?? payload['sessionId'],
          ) ??
          '',
      testId:
          _readNullableString(
            payload['testId'] ??
                testDetail['id'] ??
                payload['scopeId'] ??
                jsonMap(payload['test'])['id'],
          ) ??
          '',
      testTitle:
          _readNullableString(
            payload['testTitle'] ??
                payload['title'] ??
                testDetail['title'] ??
                payload['scopeTitle'] ??
                jsonMap(payload['test'])['title'],
          ) ??
          'IELTS practice',
      skill: skill,
      attemptMode: _attemptModeFromString(payload['attemptMode']),
      scopeType: _scopeTypeFromString(payload['scopeType']),
      scopeId: _readNullableString(payload['scopeId']),
      status: _attemptStatusFromString(payload['status']),
      sections: sections,
      questionCount: _readInt(
        payload['questionCount'] ??
            payload['totalQuestions'] ??
            testDetail['questionCount'] ??
            testDetail['totalQuestions'] ??
            allQuestions.length,
      ),
      answeredCount: _readInt(
        payload['answeredCount'] ??
            allQuestions.where((question) => question.isAnswered).length,
      ),
      timeLimitSeconds:
          _readNullableInt(
            payload['timeLimitSeconds'] ??
                payload['durationSeconds'] ??
                testDetail['timeLimitSeconds'] ??
                testDetail['durationSeconds'],
          ) ??
          (timeLimitMinutes == null ? null : timeLimitMinutes * 60),
      remainingSeconds: _readNullableInt(payload['remainingSeconds']),
      startedAt: _readDateTime(payload['startedAt']),
      submittedAt: _readDateTime(
        payload['submittedAt'] ?? payload['completedAt'],
      ),
    );
  }
}

class IeltsAttemptHistoryItem {
  const IeltsAttemptHistoryItem({
    required this.attemptId,
    required this.testId,
    required this.testTitle,
    required this.skill,
    required this.attemptMode,
    required this.scopeType,
    required this.status,
    required this.questionCount,
    this.scopeId,
    this.scopeTitle,
    this.bandScore,
    this.accuracyPercent,
    this.correctCount,
    this.timeSpentSeconds,
    this.startedAt,
    this.completedAt,
  });

  final String attemptId;
  final String testId;
  final String testTitle;
  final IeltsSkill skill;
  final IeltsAttemptMode attemptMode;
  final IeltsScopeType scopeType;
  final IeltsAttemptStatus status;
  final int questionCount;
  final String? scopeId;
  final String? scopeTitle;
  final double? bandScore;
  final double? accuracyPercent;
  final int? correctCount;
  final int? timeSpentSeconds;
  final DateTime? startedAt;
  final DateTime? completedAt;

  String get primaryScoreDisplay {
    if (attemptMode == IeltsAttemptMode.full && bandScore != null) {
      return 'Band ${bandScore!.toStringAsFixed(1)}';
    }
    if (accuracyPercent != null) {
      return '${accuracyPercent!.toStringAsFixed(0)}%';
    }
    return status.isFinished ? 'Completed' : 'In progress';
  }

  factory IeltsAttemptHistoryItem.fromJson(Map<String, dynamic> json) {
    return IeltsAttemptHistoryItem(
      attemptId:
          _readNullableString(
            json['attemptId'] ?? json['id'] ?? json['sessionId'],
          ) ??
          '',
      testId:
          _readNullableString(json['testId'] ?? jsonMap(json['test'])['id']) ??
          '',
      testTitle:
          _readNullableString(
            json['testTitle'] ??
                json['title'] ??
                jsonMap(json['test'])['title'],
          ) ??
          'IELTS practice',
      skill: _skillFromString(json['skill'] ?? json['module']),
      attemptMode: _attemptModeFromString(json['attemptMode']),
      scopeType: _scopeTypeFromString(json['scopeType']),
      status: _attemptStatusFromString(json['status']),
      questionCount: _readInt(
        json['questionCount'] ??
            json['totalQuestions'] ??
            json['answeredQuestions'],
      ),
      scopeId: _readNullableString(json['scopeId']),
      scopeTitle: _readNullableString(json['scopeTitle']),
      bandScore: _readDouble(json['bandScore'] ?? json['score']),
      accuracyPercent: _readDouble(json['accuracyPercent'] ?? json['accuracy']),
      correctCount: _readNullableInt(json['correctCount']),
      timeSpentSeconds: _readNullableInt(json['timeSpentSeconds']),
      startedAt: _readDateTime(json['startedAt']),
      completedAt: _readDateTime(json['completedAt'] ?? json['submittedAt']),
    );
  }
}

class IeltsScoreMetric {
  const IeltsScoreMetric({
    required this.label,
    required this.displayValue,
    this.description,
  });

  final String label;
  final String displayValue;
  final String? description;

  factory IeltsScoreMetric.fromDynamic(Object? value) {
    final map = jsonMap(value);
    return IeltsScoreMetric(
      label: _readNullableString(map['label'] ?? map['title']) ?? '',
      displayValue:
          _readNullableString(map['displayValue'] ?? map['value']) ?? '-',
      description: _readNullableString(map['description']),
    );
  }
}

class IeltsAttemptDetail {
  const IeltsAttemptDetail({
    required this.attemptId,
    required this.testId,
    required this.testTitle,
    required this.skill,
    required this.attemptMode,
    required this.scopeType,
    required this.status,
    required this.questionCount,
    required this.correctCount,
    required this.questions,
    required this.metrics,
    this.bandScore,
    this.accuracyPercent,
    this.timeSpentSeconds,
    this.startedAt,
    this.completedAt,
    this.completionSnapshot,
  });

  final String attemptId;
  final String testId;
  final String testTitle;
  final IeltsSkill skill;
  final IeltsAttemptMode attemptMode;
  final IeltsScopeType scopeType;
  final IeltsAttemptStatus status;
  final int questionCount;
  final int correctCount;
  final double? bandScore;
  final double? accuracyPercent;
  final int? timeSpentSeconds;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<IeltsQuestion> questions;
  final List<IeltsScoreMetric> metrics;
  final CompletionSnapshot? completionSnapshot;

  bool get isListening => skill.isListening;

  String get primaryScoreLabel =>
      attemptMode == IeltsAttemptMode.full ? 'Band score' : 'Accuracy';

  String get primaryScoreDisplay {
    if (attemptMode == IeltsAttemptMode.full && bandScore != null) {
      return bandScore!.toStringAsFixed(1);
    }
    if (accuracyPercent != null) {
      return '${accuracyPercent!.toStringAsFixed(0)}%';
    }
    return '-';
  }

  factory IeltsAttemptDetail.fromJson(
    Map<String, dynamic> json, {
    CompletionSnapshot? completionSnapshot,
  }) {
    final payload = json['data'] is Map<String, dynamic>
        ? jsonMap(json['data'])
        : json;
    final session = IeltsSessionDetail.fromJson(payload);
    final resultQuestions = _readList(payload['results'])
        .asMap()
        .entries
        .map((entry) => IeltsQuestion.fromJson(entry.value, index: entry.key))
        .toList(growable: false);
    final questions = resultQuestions.isNotEmpty
        ? resultQuestions
        : session.allQuestions;
    final resolvedSkill = _skillFromString(
      payload['skill'] ?? jsonMap(payload['testDetail'])['skill'],
    );
    return IeltsAttemptDetail(
      attemptId:
          _readNullableString(
            payload['attemptId'] ?? payload['id'] ?? session.attemptId,
          ) ??
          session.attemptId,
      testId:
          _readNullableString(payload['testId'] ?? session.testId) ??
          session.testId,
      testTitle:
          _readNullableString(
            payload['testTitle'] ??
                payload['scopeTitle'] ??
                jsonMap(payload['testDetail'])['title'] ??
                session.testTitle,
          ) ??
          session.testTitle,
      skill: resolvedSkill == IeltsSkill.unknown ? session.skill : resolvedSkill,
      attemptMode: _attemptModeFromString(payload['attemptMode']),
      scopeType: _scopeTypeFromString(payload['scopeType']),
      status: _attemptStatusFromString(payload['status']),
      questionCount: _readInt(
        payload['questionCount'] ?? payload['totalQuestions'] ?? questions.length,
      ),
      correctCount: _readInt(payload['correctCount']),
      bandScore: _readDouble(payload['bandScore'] ?? payload['score']),
      accuracyPercent: _readDouble(
        payload['accuracyPercent'] ?? payload['accuracy'],
      ),
      timeSpentSeconds: _readNullableInt(payload['timeSpentSeconds']),
      startedAt: session.startedAt,
      completedAt: session.submittedAt,
      questions: questions,
      metrics: _readList(
        payload['scoreSummary'] ?? payload['metrics'],
      ).map(IeltsScoreMetric.fromDynamic).toList(growable: false),
      completionSnapshot: completionSnapshot,
    );
  }
}

class IeltsTranscriptSegment {
  const IeltsTranscriptSegment({
    required this.speaker,
    required this.text,
    this.startSeconds,
    this.endSeconds,
  });

  final String speaker;
  final String text;
  final int? startSeconds;
  final int? endSeconds;

  factory IeltsTranscriptSegment.fromJson(Map<String, dynamic> json) {
    return IeltsTranscriptSegment(
      speaker:
          _readNullableString(json['speaker'] ?? json['label']) ?? 'Speaker',
      text:
          _readNullableString(
            json['text'] ?? json['content'] ?? json['body'],
          ) ??
          '',
      startSeconds: _readNullableInt(
        json['startSeconds'] ?? json['startTimeSeconds'],
      ),
      endSeconds: _readNullableInt(
        json['endSeconds'] ?? json['endTimeSeconds'],
      ),
    );
  }
}

class IeltsTranscript {
  const IeltsTranscript({
    required this.attemptId,
    required this.segments,
    this.title,
    this.summary,
  });

  final String attemptId;
  final String? title;
  final String? summary;
  final List<IeltsTranscriptSegment> segments;

  bool get hasContent => segments.isNotEmpty;

  factory IeltsTranscript.fromJson(
    Map<String, dynamic> json, {
    required String attemptId,
  }) {
    final payload = json['data'] is Map<String, dynamic>
        ? jsonMap(json['data'])
        : json;
    final sectionSegments = _readList(payload['sections'])
        .map((section) {
          return IeltsTranscriptSegment(
            speaker:
                _readNullableString(section['title'] ?? section['id']) ??
                'Section',
            text:
                _mergeMarkdownBlocks(
                  <String?>[
                    _readNullableString(section['instructions']),
                    _readNullableString(section['transcript']),
                  ],
                ) ??
                '',
          );
        })
        .where((segment) => segment.text.trim().isNotEmpty)
        .toList(growable: false);
    return IeltsTranscript(
      attemptId:
          _readNullableString(payload['attemptId'] ?? payload['id']) ??
          attemptId,
      title: _readNullableString(payload['title']),
      summary: _readNullableString(
        payload['summary'] ?? payload['description'],
      ),
      segments: sectionSegments.isNotEmpty
          ? sectionSegments
          : _readList(
              payload['segments'] ?? payload['items'] ?? payload['transcript'],
            ).map(IeltsTranscriptSegment.fromJson).toList(growable: false),
    );
  }
}

class IeltsSubmitAnswer {
  const IeltsSubmitAnswer({required this.questionId, required this.answers});

  final String questionId;
  final List<String> answers;

  Map<String, dynamic> toJson() {
    final sanitized = answers
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return {'questionId': questionId, 'userAnswer': sanitized};
  }
}

class IeltsSubmitPayload {
  const IeltsSubmitPayload({
    required this.timeSpentSeconds,
    required this.answers,
  });

  final int timeSpentSeconds;
  final List<IeltsSubmitAnswer> answers;

  Map<String, dynamic> toJson() {
    return {
      'timeSpentSeconds': timeSpentSeconds,
      'answers': answers.map((item) => item.toJson()).toList(growable: false),
    };
  }
}

List<IeltsAnswerSlot> _parseAnswerSlots(
  Map<String, dynamic> json,
  IeltsQuestionType type,
  List<IeltsAnswerOption> options,
) {
  final source = _readList(
    json['answerSlots'] ??
        json['blanks'] ??
        json['items'] ??
        json['subQuestions'],
  );
  if (source.isNotEmpty) {
    return source
        .asMap()
        .entries
        .map(
          (entry) => IeltsAnswerSlot.fromDynamic(
            entry.value,
            index: entry.key,
            fallbackOptions: options,
          ),
        )
        .toList(growable: false);
  }

  if (type.usesTextInputs || type.usesSlotSelection) {
    return [
      IeltsAnswerSlot(
        id: 'slot_0',
        label: 'Answer',
        placeholder: 'Your answer',
        options: options,
      ),
    ];
  }

  return const <IeltsAnswerSlot>[];
}

List<String> _parseAnswerValues(
  Map<String, dynamic> json, {
  required List<String> keys,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) {
      continue;
    }
    if (value is List) {
      final answers = value
          .map((item) => item?.toString() ?? '')
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false);
      if (answers.isNotEmpty) {
        return answers;
      }
    }
    final single = _readNullableString(value);
    if (single != null && single.isNotEmpty) {
      return [single];
    }
  }
  return const <String>[];
}

IeltsSkill _skillFromString(Object? value) {
  switch ((value?.toString() ?? '').toUpperCase()) {
    case 'READING':
      return IeltsSkill.reading;
    case 'LISTENING':
      return IeltsSkill.listening;
    default:
      return IeltsSkill.unknown;
  }
}

IeltsAttemptMode _attemptModeFromString(Object? value) {
  switch ((value?.toString() ?? '').toUpperCase()) {
    case 'FULL':
      return IeltsAttemptMode.full;
    case 'QUICK':
      return IeltsAttemptMode.quick;
    default:
      return IeltsAttemptMode.unknown;
  }
}

IeltsScopeType _scopeTypeFromString(Object? value) {
  switch ((value?.toString() ?? '').toUpperCase()) {
    case 'TEST':
    case 'FULL':
    case 'FULL_TEST':
      return IeltsScopeType.fullTest;
    case 'SECTION':
      return IeltsScopeType.section;
    case 'PASSAGE':
      return IeltsScopeType.passage;
    default:
      return IeltsScopeType.unknown;
  }
}

IeltsAttemptStatus _attemptStatusFromString(Object? value) {
  switch ((value?.toString() ?? '').toUpperCase()) {
    case 'READY':
    case 'IN_PROGRESS':
      return IeltsAttemptStatus.inProgress;
    case 'COMPLETED':
    case 'SUBMITTED':
    case 'EXPIRED':
    case 'FAILED':
      return IeltsAttemptStatus.completed;
    default:
      return IeltsAttemptStatus.unknown;
  }
}

IeltsQuestionType _questionTypeFromString(Object? value) {
  switch ((value?.toString() ?? '').toUpperCase()) {
    case 'SINGLE_CHOICE':
      return IeltsQuestionType.singleChoice;
    case 'MULTIPLE_CHOICE':
      return IeltsQuestionType.multipleChoice;
    case 'TRUE_FALSE_NOT_GIVEN':
      return IeltsQuestionType.trueFalseNotGiven;
    case 'YES_NO_NOT_GIVEN':
      return IeltsQuestionType.yesNoNotGiven;
    case 'FORM_COMPLETION':
      return IeltsQuestionType.formCompletion;
    case 'SENTENCE_COMPLETION':
      return IeltsQuestionType.sentenceCompletion;
    case 'SUMMARY_COMPLETION':
      return IeltsQuestionType.summaryCompletion;
    case 'MATCHING':
      return IeltsQuestionType.matching;
    case 'MATCHING_HEADINGS':
      return IeltsQuestionType.matchingHeadings;
    case 'MAP_LABELING':
      return IeltsQuestionType.mapLabeling;
    case 'PASSAGE_COMPLETION':
      return IeltsQuestionType.passageCompletion;
    default:
      return IeltsQuestionType.unknown;
  }
}

Map<String, dynamic> jsonMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, dynamic>{};
}

List<Object?> _readDynamicList(Object? value) {
  if (value is! List) {
    return const <Object?>[];
  }
  return value.whereType<Object?>().toList(growable: false);
}

List<Map<String, dynamic>> _readList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return value.map(jsonMap).toList(growable: false);
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .map((item) => item?.toString() ?? '')
      .where((item) => item.trim().isNotEmpty)
      .toList(growable: false);
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int _readInt(Object? value) {
  return _readNullableInt(value) ?? 0;
}

int? _readNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

double? _readDouble(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

DateTime? _readDateTime(Object? value) {
  final raw = _readNullableString(value);
  if (raw == null) {
    return null;
  }
  return DateTime.tryParse(raw);
}

int _countSectionQuestions(List<IeltsSectionSummary> sections) {
  return sections.fold<int>(0, (sum, section) => sum + section.questionCount);
}

String? _mergeMarkdownBlocks(List<String?> values) {
  final sanitized = values
      .map((value) => value?.trim() ?? '')
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (sanitized.isEmpty) {
    return null;
  }
  return sanitized.join('\n\n');
}
