import 'package:flutter/material.dart';

import 'presentation/speaking_list_page.dart';

class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key, this.mode});

  final String? mode;

  @override
  Widget build(BuildContext context) {
    return SpeakingListPage(mode: mode);
  }
}
