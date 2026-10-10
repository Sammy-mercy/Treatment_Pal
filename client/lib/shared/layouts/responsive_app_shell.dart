import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/brand_logo.dart';

class ResponsiveNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const ResponsiveNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class ResponsiveAppShell extends StatelessWidget {
  final Widget child;
  final String sectionLabel;
  final List<ResponsiveNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ResponsiveAppShell({
    super.key,
    required this.child,
    required this.sectionLabel,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1100;
        final isTablet = width >= 700;

        if (!isTablet) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: onSelected,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.muted,
              type: BottomNavigationBarType.fixed,
              items: [
                for (final item in items)
                  BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              if (isDesktop)
                _DesktopSidebar(
                  sectionLabel: sectionLabel,
                  items: items,
                  selectedIndex: selectedIndex,
                  onSelected: onSelected,
                )
              else
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onSelected,
                  backgroundColor: AppColors.surface,
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.primary),
                  unselectedIconTheme:
                      const IconThemeData(color: AppColors.muted),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              const VerticalDivider(
                  width: 1, thickness: 1, color: AppColors.line),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final String sectionLabel;
  final List<ResponsiveNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _DesktopSidebar({
    required this.sectionLabel,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SizedBox(
        width: 256,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  BrandLogo(width: 32, height: 32),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Therapy Pal',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  sectionLabel.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              for (var index = 0; index < items.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _SidebarDestination(
                    item: items[index],
                    selected: selectedIndex == index,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  final ResponsiveNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: Icon(selected ? item.selectedIcon : item.icon),
      title: Text(item.label),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      selectedTileColor: AppColors.primaryLight,
      selectedColor: AppColors.primary,
      textColor: AppColors.muted,
      iconColor: selected ? AppColors.primary : AppColors.muted,
    );
  }
}
