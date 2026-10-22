import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.notFoundTitle)),
    body: Center(
      child: FilledButton(
        onPressed: () =>
            Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
        child: Text(context.l10n.backHome),
      ),
    ),
  );
}
