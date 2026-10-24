import 'package:flutter/material.dart';

class CapstoneProjectScreen extends StatefulWidget {
  const CapstoneProjectScreen({super.key});

  @override
  State<CapstoneProjectScreen> createState() => _CapstoneProjectScreenState();
}

class _CapstoneProjectScreenState extends State<CapstoneProjectScreen> {
  final List<_CapstoneStage> _stages = const [
    _CapstoneStage('مرحلة 1', 'طباعة رسالة الترحيب', false),
    _CapstoneStage('مرحلة 2', 'توليد رقم عشوائي', false),
    _CapstoneStage('مرحلة 3', 'مقارنة التخمين', false),
    _CapstoneStage('مرحلة 4', 'تكرار حتى الحصول على الإجابة', false),
    _CapstoneStage('مرحلة 5', 'تغليف المنطق في دالة', false),
    _CapstoneStage('مرحلة 6', 'عداد المحاولات والنتيجة النهائية', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مشروع التطوير التكاملي')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _stages.length,
        itemBuilder: (context, index) {
          final stage = _stages[index];
          return Card(
            child: CheckboxListTile(
              value: stage.done,
              title: Text(stage.title),
              subtitle: Text(stage.description),
              onChanged: (value) {
                setState(() {
                  _stages[index] = _CapstoneStage(
                    stage.title,
                    stage.description,
                    value ?? false,
                  );
                });
              },
            ),
          );
        },
      ),
    );
  }
}

@immutable
class _CapstoneStage {
  const _CapstoneStage(this.title, this.description, this.done);

  final String title;
  final String description;
  final bool done;
}
