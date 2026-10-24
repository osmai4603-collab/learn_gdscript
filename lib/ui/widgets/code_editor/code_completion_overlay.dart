import 'package:flutter/material.dart';

class CodeCompletionOverlay extends StatelessWidget {
  const CodeCompletionOverlay({
    super.key,
    required this.items,
    required this.onSelected,
  });

  final List<String> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Card(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) => ListTile(
          dense: true,
          leading: const Icon(Icons.code, size: 18),
          title: Text(
            items[index],
            style: const TextStyle(fontFamily: 'JetBrains Mono'),
          ),
          onTap: () => onSelected(items[index]),
        ),
      ),
    ),
  );
}
