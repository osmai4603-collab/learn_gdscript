import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(label ?? context.l10n.loading),
      ],
    ),
  );
}
