import 'package:flutter/material.dart';
import 'package:gdscript_engine/gdscript_engine.dart';

class CodeCompletionOverlay extends StatelessWidget {
  const CodeCompletionOverlay({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    required this.onSelected,
  });

  final List<CompletionItem> items;
  final int selectedIndex;
  final ValueChanged<CompletionItem> onSelected;

  @override
  Widget build(BuildContext context) => Card(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return ListTile(
            dense: true,
            selected: selected,
            leading: const Icon(Icons.code, size: 18),
            title: Text(
              items[index].label,
              style: const TextStyle(fontFamily: 'JetBrains Mono'),
            ),
            subtitle: items[index].detail == null
                ? null
                : Text(items[index].detail!),
            trailing: Text(items[index].kind.name),
            onTap: () => onSelected(items[index]),
          );
        },
      ),
    ),
  );
}
