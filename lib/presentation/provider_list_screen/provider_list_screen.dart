import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/provider_card_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentBottomNavIndex = 1; // Search tab active
  // ignore: unused_field
  bool _isRefreshing = false;
  String _selectedCategory = "Plumbing";
  int _activeFilterCount = 0;
  String _currentSortOption = "Distance";

  // Filter state
  double _locationRadius = 5.0;
  String _availabilityFilter = "All";
  double _ratingThreshold = 0.0;
  RangeValues _priceRange = const RangeValues(0, 1000);

  // Mock provider data with Ethiopian context
  final List<Map<String, dynamic>> _allProviders = [
    {
      "id": "1",
      "name": "Abebe Kebede",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1743d8131-1763301116185.png",
      "semanticLabel":
          "Professional headshot of Ethiopian man with short black hair wearing blue work shirt",
      "specialization": "Emergency Plumbing",
      "rating": 4.8,
      "reviewCount": 127,
      "location": "Bole, Addis Ababa",
      "distance": 1.2,
      "availability": "Available",
      "phone": "+251911234567",
      "isFeatured": true,
      "isEmergency": true,
      "price": 250,
      "joinedDate": DateTime(2024, 3, 15),
    },
    {
      "id": "2",
      "name": "Tigist Haile",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1b0d0b9cd-1763296099864.png",
      "semanticLabel":
          "Professional photo of Ethiopian woman with braided hair wearing yellow work uniform",
      "specialization": "Residential Plumbing",
      "rating": 4.6,
      "reviewCount": 89,
      "location": "Megenagna, Addis Ababa",
      "distance": 2.5,
      "availability": "Available",
      "phone": "+251922345678",
      "isFeatured": false,
      "isEmergency": false,
      "price": 180,
      "joinedDate": DateTime(2024, 6, 20),
    },
    {
      "id": "3",
      "name": "Dawit Tesfaye",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a0942522-1763292717812.png",
      "semanticLabel":
          "Portrait of Ethiopian man with mustache wearing red plumber work shirt",
      "specialization": "Commercial Plumbing",
      "rating": 4.9,
      "reviewCount": 203,
      "location": "Piassa, Addis Ababa",
      "distance": 3.8,
      "availability": "Busy",
      "phone": "+251933456789",
      "isFeatured": true,
      "isEmergency": false,
      "price": 320,
      "joinedDate": DateTime(2023, 11, 10),
    },
    {
      "id": "4",
      "name": "Meron Alemayehu",
      "avatar": "https://images.unsplash.com/photo-1634141505621-3e8ea76182d2",
      "semanticLabel":
          "Photo of young Ethiopian woman with curly hair wearing green work vest",
      "specialization": "Pipe Installation",
      "rating": 4.5,
      "reviewCount": 64,
      "location": "Kazanchis, Addis Ababa",
      "distance": 4.2,
      "availability": "Available",
      "phone": "+251944567890",
      "isFeatured": false,
      "isEmergency": false,
      "price": 200,
      "joinedDate": DateTime(2025, 1, 5),
    },
    {
      "id": "5",
      "name": "Solomon Girma",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_153951ed6-1763294769986.png",
      "semanticLabel":
          "Professional photo of Ethiopian man with glasses wearing blue work uniform",
      "specialization": "Drain Cleaning",
      "rating": 4.7,
      "reviewCount": 145,
      "location": "Gerji, Addis Ababa",
      "distance": 5.1,
      "availability": "Offline",
      "phone": "+251955678901",
      "isFeatured": false,
      "isEmergency": true,
      "price": 150,
      "joinedDate": DateTime(2024, 8, 12),
    },
  ];

  List<Map<String, dynamic>> _filteredProviders = [];
  Set<String> _favoriteProviderIds = {};

  @override
  void initState() {
    super.initState();
    _filteredProviders = List.from(_allProviders);
    _applySort();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredProviders = _allProviders.where((provider) {
        // Distance filter
        if ((provider["distance"] as double) > _locationRadius) return false;

        // Availability filter
        if (_availabilityFilter != "All" &&
            provider["availability"] != _availabilityFilter)
          return false;

        // Rating filter
        if ((provider["rating"] as double) < _ratingThreshold) return false;

        // Price filter
        final price = provider["price"] as int;
        if (price < _priceRange.start || price > _priceRange.end) return false;

        // Search filter
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          final nameLower = (provider["name"] as String).toLowerCase();
          if (!nameLower.contains(searchLower)) return false;
        }

        return true;
      }).toList();

      _applySort();
      _updateFilterCount();
    });
  }

  void _applySort() {
    setState(() {
      switch (_currentSortOption) {
        case "Distance":
          _filteredProviders.sort(
            (a, b) =>
                (a["distance"] as double).compareTo(b["distance"] as double),
          );
          break;
        case "Rating":
          _filteredProviders.sort(
            (a, b) => (b["rating"] as double).compareTo(a["rating"] as double),
          );
          break;
        case "Availability":
          _filteredProviders.sort((a, b) {
            const order = {"Available": 0, "Busy": 1, "Offline": 2};
            return (order[a["availability"]] ?? 3).compareTo(
              order[b["availability"]] ?? 3,
            );
          });
          break;
        case "Recently Joined":
          _filteredProviders.sort(
            (a, b) => (b["joinedDate"] as DateTime).compareTo(
              a["joinedDate"] as DateTime,
            ),
          );
          break;
      }

      // Featured providers always on top
      _filteredProviders.sort((a, b) {
        if (a["isFeatured"] == b["isFeatured"]) return 0;
        return (a["isFeatured"] as bool) ? -1 : 1;
      });
    });
  }

  void _updateFilterCount() {
    int count = 0;
    if (_locationRadius < 10.0) count++;
    if (_availabilityFilter != "All") count++;
    if (_ratingThreshold > 0.0) count++;
    if (_priceRange.start > 0 || _priceRange.end < 1000) count++;
    setState(() => _activeFilterCount = count);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  void _toggleFavorite(String providerId) {
    setState(() {
      if (_favoriteProviderIds.contains(providerId)) {
        _favoriteProviderIds.remove(providerId);
      } else {
        _favoriteProviderIds.add(providerId);
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        locationRadius: _locationRadius,
        availabilityFilter: _availabilityFilter,
        ratingThreshold: _ratingThreshold,
        priceRange: _priceRange,
        onApply: (radius, availability, rating, price) {
          setState(() {
            _locationRadius = radius;
            _availabilityFilter = availability;
            _ratingThreshold = rating;
            _priceRange = price;
          });
          _applyFilters();
          Navigator.pop(context);
        },
        onReset: () {
          setState(() {
            _locationRadius = 10.0;
            _availabilityFilter = "All";
            _ratingThreshold = 0.0;
            _priceRange = const RangeValues(0, 1000);
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        currentSort: _currentSortOption,
        onSelect: (option) {
          setState(() => _currentSortOption = option);
          _applySort();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showProviderContextMenu(Map<String, dynamic> provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'phone',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text('Call', style: theme.textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    // Phone dialer integration would go here
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'message',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text('Message', style: theme.textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: _favoriteProviderIds.contains(provider["id"])
                        ? 'favorite'
                        : 'favorite_border',
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                  title: Text(
                    _favoriteProviderIds.contains(provider["id"])
                        ? 'Remove from Favorites'
                        : 'Add to Favorites',
                    style: theme.textTheme.bodyLarge,
                  ),
                  onTap: () {
                    _toggleFavorite(provider["id"] as String);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'share',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text('Share', style: theme.textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'report',
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                  title: Text('Report', style: theme.textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBarWithFilter(
        title: _selectedCategory,
        onFilterTap: _showFilterSheet,
        activeFilterCount: _activeFilterCount > 0 ? _activeFilterCount : null,
        additionalActions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'sort',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showSortSheet,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            color: theme.colorScheme.surface,
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _applyFilters(),
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ),
          ),

          // Provider list
          Expanded(
            child: _filteredProviders.isEmpty
                ? _buildEmptyState(theme)
                : RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: theme.colorScheme.primary,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      itemCount: _filteredProviders.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        final provider = _filteredProviders[index];
                        return ProviderCardWidget(
                          provider: provider,
                          isFavorite: _favoriteProviderIds.contains(
                            provider["id"],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/provider-detail-screen',
                              arguments: provider,
                            );
                          },
                          onCallTap: () {
                            // Phone dialer integration
                          },
                          onFavoriteTap: () =>
                              _toggleFavorite(provider["id"] as String),
                          onLongPress: () => _showProviderContextMenu(provider),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: theme.colorScheme.onSurfaceVariant,
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'No providers found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Try expanding your search radius or adjusting filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _locationRadius = 10.0;
                  _availabilityFilter = "All";
                  _ratingThreshold = 0.0;
                  _priceRange = const RangeValues(0, 1000);
                  _searchController.clear();
                });
                _applyFilters();
              },
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Reset Filters'),
            ),
            SizedBox(height: 2.h),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/provider-registration-screen');
              },
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: const Text('Invite Provider'),
            ),
          ],
        ),
      ),
    );
  }
}
