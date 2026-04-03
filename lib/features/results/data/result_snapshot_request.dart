enum ResultSnapshotModule {
  ielts,
  writing,
  speaking,
  customSpeaking,
  vocabulary,
}

class ResultSnapshotRequest {
  const ResultSnapshotRequest({
    required this.module,
    required this.referenceId,
  });

  final ResultSnapshotModule module;
  final String referenceId;

  String get routeModuleName {
    return switch (module) {
      ResultSnapshotModule.ielts => 'IELTS',
      ResultSnapshotModule.writing => 'WRITING',
      ResultSnapshotModule.speaking => 'SPEAKING',
      ResultSnapshotModule.customSpeaking => 'CUSTOM_SPEAKING',
      ResultSnapshotModule.vocabulary => 'VOCABULARY',
    };
  }

  String get referenceType {
    return switch (module) {
      ResultSnapshotModule.ielts => 'IELTS_ATTEMPT',
      ResultSnapshotModule.writing => 'WRITING_SUBMISSION',
      ResultSnapshotModule.speaking => 'SPEAKING_ATTEMPT',
      ResultSnapshotModule.customSpeaking => 'CUSTOM_SPEAKING_CONVERSATION',
      ResultSnapshotModule.vocabulary => 'VOCAB_REVIEW_SESSION',
    };
  }

  String get endpointPath {
    return switch (module) {
      ResultSnapshotModule.ielts =>
        '/user/results/ielts/$referenceId/completion-snapshot',
      ResultSnapshotModule.writing =>
        '/user/results/writing/$referenceId/completion-snapshot',
      ResultSnapshotModule.speaking =>
        '/user/results/speaking/$referenceId/completion-snapshot',
      ResultSnapshotModule.customSpeaking =>
        '/user/results/custom-conversations/$referenceId/completion-snapshot',
      ResultSnapshotModule.vocabulary =>
        '/user/results/vocabulary/review-sessions/$referenceId/completion-snapshot',
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ResultSnapshotRequest &&
        other.module == module &&
        other.referenceId == referenceId;
  }

  @override
  int get hashCode => Object.hash(module, referenceId);
}
