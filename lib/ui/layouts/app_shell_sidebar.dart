import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../routers/app_routes.dart';

class AppShellSidebar extends StatelessWidget {
  const AppShellSidebar({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  final String activeRoute;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerLow,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 12, 20),
            child: Row(
              children: [
                Icon(Icons.gamepad_rounded, color: colors.primary, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.appTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                SidebarItem(
                  icon: Icons.dashboard_rounded,
                  title: l10n.navigateHome,
                  route: AppRoutes.root,
                  isActive: activeRoute == AppRoutes.root,
                  onTap: () => onNavigate(AppRoutes.root),
                ),
                SidebarItem(
                  icon: Icons.map_rounded,
                  title: l10n.navigatePath,
                  route: AppRoutes.learningPath,
                  isActive: activeRoute == AppRoutes.learningPath,
                  onTap: () => onNavigate(AppRoutes.learningPath),
                ),
                SidebarItem(
                  icon: Icons.code_rounded,
                  title: l10n.navigateCodeEditor,
                  route: AppRoutes.workspace,
                  isActive: activeRoute == AppRoutes.workspace,
                  onTap: () => onNavigate(AppRoutes.workspace),
                ),
                SidebarItem(
                  icon: Icons.explore_rounded,
                  title: l10n.syntaxExplorerTitle,
                  route: AppRoutes.syntaxReference,
                  isActive: activeRoute == AppRoutes.syntaxReference,
                  onTap: () => onNavigate(AppRoutes.syntaxReference),
                ),
                SidebarItem(
                  icon: Icons.folder_open_rounded,
                  title: l10n.navigateWorkspace,
                  route: AppRoutes.workspaceSearch,
                  isActive: activeRoute == AppRoutes.workspaceSearch,
                  onTap: () => onNavigate(AppRoutes.workspaceSearch),
                ),
                SidebarItem(
                  icon: Icons.military_tech_rounded,
                  title: l10n.badgesTitle,
                  route: AppRoutes.badges,
                  isActive: activeRoute == AppRoutes.badges,
                  onTap: () => onNavigate(AppRoutes.badges),
                ),
                SidebarItem(
                  icon: Icons.settings_rounded,
                  title: l10n.navigateSettings,
                  route: AppRoutes.settings,
                  isActive: activeRoute == AppRoutes.settings,
                  onTap: () => onNavigate(AppRoutes.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({super.key, 
    required this.icon,
    required this.title,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1F2630) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(
                    color: colors.primary.withValues(alpha: 0.4),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? colors.primary
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: isActive ? 12 : 11.5,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
