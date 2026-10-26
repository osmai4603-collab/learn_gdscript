import 'package:flutter/material.dart';
import 'package:learn_gdscript/core/theme/editor_theme_extension.dart';
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
              style: CodeTextTheme.of(context).bodyMedium.copyWith(
                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
              ),
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
