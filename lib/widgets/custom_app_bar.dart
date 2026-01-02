import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar variant types for different screen contexts
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// Search-focused app bar with search field
  search,

  /// Minimal app bar with back button only
  minimal,

  /// App bar with large title for main screens
  large,
}

/// Custom app bar widget for Ethiopian service marketplace
/// Implements clean, minimal design with clear hierarchy
/// Optimized for mobile-first service discovery workflows
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final CustomAppBarVariant variant;
  final VoidCallback? onSearchTap;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.variant = CustomAppBarVariant.standard,
    this.onSearchTap,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  });

  @override
  Size get preferredSize {
    switch (variant) {
      case CustomAppBarVariant.large:
        return const Size.fromHeight(112);
      case CustomAppBarVariant.search:
        return const Size.fromHeight(64);
      default:
        return const Size.fromHeight(56);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.minimal:
        return _buildMinimalAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.large:
        return _buildLargeAppBar(context, theme, colorScheme);
      default:
        return _buildStandardAppBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            )
          : null,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  Widget _buildSearchAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      leading:
          leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                )
              : null),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outline, width: 1),
        ),
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          onSubmitted: (value) => onSearchSubmitted?.call(),
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search providers...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: searchController?.text.isNotEmpty ?? false
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () {
                      searchController?.clear();
                      onSearchChanged?.call('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        ),
      ),
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  Widget _buildMinimalAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      leading:
          leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                )
              : null),
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  Widget _buildLargeAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      toolbarHeight: 112,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title != null
          ? Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  title!,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: foregroundColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
      actions: actions != null
          ? [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(children: actions!),
              ),
            ]
          : null,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }
}

/// Sliver variant of custom app bar for scrollable screens
class CustomSliverAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool pinned;
  final bool floating;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomSliverAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight = 120,
    this.flexibleSpace,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      title: title != null
          ? Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            )
          : null,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }
}

/// App bar with integrated filter button for provider lists
class CustomAppBarWithFilter extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback onFilterTap;
  final int? activeFilterCount;
  final List<Widget>? additionalActions;

  const CustomAppBarWithFilter({
    super.key,
    required this.title,
    required this.onFilterTap,
    this.activeFilterCount,
    this.additionalActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: onFilterTap,
              tooltip: 'Filter',
            ),
            if (activeFilterCount != null && activeFilterCount! > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    activeFilterCount.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        if (additionalActions != null) ...additionalActions!,
        const SizedBox(width: 8),
      ],
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }
}
