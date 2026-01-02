import 'package:flutter/material.dart';

/// Navigation item configuration for bottom bar
class CustomBottomBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const CustomBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom bottom navigation bar widget for Ethiopian service marketplace
/// Implements bottom-heavy interaction design with thumb-friendly navigation
/// Supports 4 primary navigation items: Categories, Search, Favorites, Profile
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Primary navigation items mapped to app routes
  static const List<CustomBottomBarItem> _navigationItems = [
    CustomBottomBarItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
      label: 'Categories',
      route: '/service-categories-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Search',
      route: '/provider-list-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favorites',
      route: '/provider-list-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/authentication-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) =>
                  _buildNavigationItem(context, _navigationItems[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    CustomBottomBarItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          onTap(index);
          // Navigate to the corresponding route
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, item.route);
          }
        },
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with minimum 48dp touch target
              SizedBox(
                height: 28,
                width: 28,
                child: Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 24,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              // Label text
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alternative variant with Material 3 NavigationBar
/// Provides more modern appearance with indicator animations
class CustomBottomBarMaterial3 extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBarMaterial3({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<CustomBottomBarItem> _navigationItems = [
    CustomBottomBarItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
      label: 'Categories',
      route: '/service-categories-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Search',
      route: '/provider-list-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favorites',
      route: '/provider-list-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/authentication-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        onTap(index);
        // Navigate to the corresponding route
        if (currentIndex != index) {
          Navigator.pushReplacementNamed(
            context,
            _navigationItems[index].route,
          );
        }
      },
      elevation: 8.0,
      height: 64,
      destinations: _navigationItems.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon ?? item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}

/// Compact variant for smaller screens
/// Reduces vertical space while maintaining touch targets
class CustomBottomBarCompact extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBarCompact({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<CustomBottomBarItem> _navigationItems = [
    CustomBottomBarItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
      label: 'Categories',
      route: '/service-categories-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Search',
      route: '/provider-list-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favorites',
      route: '/provider-list-screen',
    ),
    CustomBottomBarItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/authentication-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) =>
                  _buildCompactItem(context, _navigationItems[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactItem(
    BuildContext context,
    CustomBottomBarItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          onTap(index);
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, item.route);
          }
        },
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                size: 24,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
