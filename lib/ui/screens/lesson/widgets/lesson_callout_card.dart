import 'package:flutter/material.dart';

enum CalloutType {
  warning,
  tip,
  note,
  goldenRule;

  static CalloutType fromDirective(String directive) {
    return switch (directive.toUpperCase()) {
      'WARNING' => CalloutType.warning,
      'TIP' => CalloutType.tip,
      'NOTE' => CalloutType.note,
      _ => CalloutType.note,
    };
  }
}

class LessonCalloutCard extends StatelessWidget {
  const LessonCalloutCard({
    super.key,
    required this.type,
    this.title,
    this.content,
    this.contentSpans,
    this.icon,
  });

  final CalloutType type;
  final String? title;
  final String? content;
  final List<InlineSpan>? contentSpans;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    final (
      Color accentColor,
      Color backgroundColor,
      Color borderColor,
      IconData defaultIcon,
      String defaultTitle,
    ) = _getVisuals(colorScheme, isDark, isEnglish);

    final resolvedTitle = title ?? defaultTitle;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4.5,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(
                                alpha: isDark ? 0.22 : 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon ?? defaultIcon,
                              size: 18,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              resolvedTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (contentSpans != null &&
                          contentSpans!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SelectableText.rich(
                          TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.65,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(
                                alpha: isDark ? 0.95 : 0.90,
                              ),
                            ),
                            children: contentSpans,
                          ),
                        ),
                      ] else if (content != null &&
                          content!.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SelectableText(
                          content!.trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.65,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(
                              alpha: isDark ? 0.95 : 0.90,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color, Color, IconData, String) _getVisuals(
    ColorScheme colorScheme,
    bool isDark,
    bool isEnglish,
  ) {
    switch (type) {
      case CalloutType.warning:
        final accent = isDark
            ? const Color(0xFFFF6B6B)
            : const Color(0xFFC92A2A);
        final bg = accent.withValues(alpha: isDark ? 0.12 : 0.08);
        final border = accent.withValues(alpha: isDark ? 0.35 : 0.25);
        final title = isEnglish ? 'Official Warning' : 'تحذير رسمي';
        return (accent, bg, border, Icons.warning_amber_rounded, title);

      case CalloutType.tip:
        final accent = isDark
            ? const Color(0xFF40C057)
            : const Color(0xFF1E824C);
        final bg = accent.withValues(alpha: isDark ? 0.12 : 0.08);
        final border = accent.withValues(alpha: isDark ? 0.35 : 0.25);
        final title = isEnglish ? 'Best Practice' : 'توصية وممارسة فضلى';
        return (accent, bg, border, Icons.lightbulb_outline_rounded, title);

      case CalloutType.note:
        final accent = isDark
            ? const Color(0xFF478CBF)
            : const Color(0xFF176B9A);
        final bg = accent.withValues(alpha: isDark ? 0.14 : 0.08);
        final border = accent.withValues(alpha: isDark ? 0.35 : 0.25);
        final title = isEnglish ? 'Technical Note' : 'معلومة هندسية';
        return (accent, bg, border, Icons.info_outline_rounded, title);

      case CalloutType.goldenRule:
        final accent = isDark
            ? const Color(0xFFFFD43B)
            : const Color(0xFFB58900);
        final bg = accent.withValues(alpha: isDark ? 0.14 : 0.09);
        final border = accent.withValues(alpha: isDark ? 0.40 : 0.30);
        final title = isEnglish ? 'Golden Rule' : 'القاعدة الذهبية';
        return (accent, bg, border, Icons.auto_awesome_rounded, title);
    }
  }
}
