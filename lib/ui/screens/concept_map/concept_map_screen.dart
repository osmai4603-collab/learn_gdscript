import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routers/app_routes.dart';
class ConceptMapNode {
  const ConceptMapNode({
    required this.id,
    required this.title,
    this.lessonId,
    this.completed = false,
    this.related = const [],
  });

  final String id;
  final String title;
  final String? lessonId;
  final bool completed;
  final List<String> related;
}

class ConceptMapScreen extends StatelessWidget {
  const ConceptMapScreen({super.key, this.nodes = const []});

  final List<ConceptMapNode> nodes;

  static const defaultNodes = [
    ConceptMapNode(
      id: 'hello',
      title: 'الطباعة',
      lessonId: 'lesson_01_hello',
      completed: true,
      related: ['comments'],
    ),
    ConceptMapNode(
      id: 'variables',
      title: 'المتغيرات',
      lessonId: 'lesson_03_variables',
      completed: true,
      related: ['types'],
    ),
    ConceptMapNode(
      id: 'types',
      title: 'الأنواع',
      lessonId: 'lesson_04_types',
      related: ['variables'],
    ),
    ConceptMapNode(
      id: 'conditions',
      title: 'الشروط',
      lessonId: 'lesson_06_if_else',
      related: ['loops'],
    ),
    ConceptMapNode(
      id: 'loops',
      title: 'الحلقات',
      lessonId: 'lesson_09_for',
      related: ['functions'],
    ),
    ConceptMapNode(
      id: 'functions',
      title: 'الدوال',
      lessonId: 'lesson_12_func_basics',
      related: ['variables'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = nodes.isEmpty ? defaultNodes : nodes;
    return Scaffold(
      appBar: AppBar(title: const Text('خريطة المفاهيم')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'خريطة المفاهيم',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final node in items)
            Card(
              color: node.completed ? Colors.green.shade50 : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: node.completed
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  child: Text(
                    node.completed ? '✓' : '•',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(node.title),
                subtitle: node.related.isEmpty
                    ? const Text('مفهوم أساسي')
                    : Text('متصل بـ ${node.related.join(', ')}'),
                trailing: node.lessonId == null
                    ? null
                    : const Icon(Icons.arrow_forward_ios),
                onTap: node.lessonId == null
                    ? null
                    : () => context.push(
                        AppRoutes.lessonPath(node.lessonId!),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
