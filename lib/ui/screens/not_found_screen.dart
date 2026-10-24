import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../routers/app_routes.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.notFoundTitle)),
    body: Center(
      child: FilledButton(
        onPressed: () => context.go(AppRoutes.root),
        child: Text(context.l10n.backHome),
      ),
    ),
  );
}
