import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../widgets/gamification/badges_grid_widget.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.badgesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [BadgesGridWidget()],
      ),
    );
  }
}
