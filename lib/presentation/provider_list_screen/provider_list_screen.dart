import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _providerSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _favoritesSubscription;
  StreamSubscription<User?>? _authSubscription;

  bool _didInitTabFromRouteArgs = false;

  String? _providersLoadError;

  int _currentBottomNavIndex = 1; // Search tab active
  // ignore: unused_field
  bool _isRefreshing = false;
  String _categoryFilter = 'All';
  int _activeFilterCount = 0;
  String _currentSortOption = "Distance";
  final bool _debugBypassFilters = false;

  List<Map<String, dynamic>> _providers = [];
  List<Map<String, dynamic>> _filteredProviders = [];
  final Set<String> _favoriteProviderIds = {};

  // Filter state
  double _locationRadius = 20.0; // Keep within filter slider range
  String _availabilityFilter = "All";
  double _ratingThreshold = 0.0;
  RangeValues _priceRange = const RangeValues(0, 1000);

  List<String> get _availableCategories {
    final categories =
        _providers
            .map((p) => (p['category'] as String?)?.trim() ?? '')
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (categories.isEmpty) return const ['All'];
    if (categories.any((c) => c.toLowerCase() == 'all')) {
      categories.removeWhere((c) => c.toLowerCase() == 'all');
    }

    return ['All', ...categories];
  }

  @override
  void initState() {
    super.initState();
    _listenToProviders();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _favoritesSubscription?.cancel();
      _favoritesSubscription = null;
      if (!mounted) return;
      setState(() {
        _favoriteProviderIds.clear();
      });
      if (user != null) {
        _listenToFavorites(user.uid);
      }
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) _listenToFavorites(user.uid);
    _updateFilterCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Allow bottom-nav taps (Favorites vs Search) to open this screen in a
    // specific tab via Navigator arguments.
    if (_didInitTabFromRouteArgs) return;
    _didInitTabFromRouteArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    int? initialTabIndex;
    String? initialCategory;
    if (args is Map) {
      final v = args['initialTabIndex'];
      if (v is int) initialTabIndex = v;

      final c = args['initialCategory'] ?? args['categoryName'];
      if (c is String) initialCategory = c;
    } else if (args is int) {
      initialTabIndex = args;
    }

    final trimmedInitialCategory = initialCategory?.trim();
    if ((initialTabIndex != null && initialTabIndex >= 0) ||
        (trimmedInitialCategory != null && trimmedInitialCategory.isNotEmpty)) {
      setState(() {
        final idx = initialTabIndex;
        if (idx != null && idx >= 0) {
          _currentBottomNavIndex = idx;
        }

        final cat = trimmedInitialCategory;
        if (cat != null && cat.isNotEmpty) {
          _categoryFilter = cat;
        }
      });
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _providerSubscription?.cancel();
    _favoritesSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToFavorites(String uid) {
    _favoritesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .listen(
          (snapshot) {
            final ids = snapshot.docs.map((d) => d.id).toSet();
            setState(() {
              _favoriteProviderIds
                ..clear()
                ..addAll(ids);
            });
          },
          onError: (error, stack) {
            // ignore: avoid_print
            print('favorites snapshot error: $error');
          },
        );
  }

  void _listenToProviders() {
    _providerSubscription = FirebaseFirestore.instance
        .collection('providers')
        .snapshots()
        .listen(
          (snapshot) {
            final fetched = snapshot.docs
                .map((doc) {
                  try {
                    final raw = {...doc.data()};
                    return _normalizeProviderData(raw, doc.id);
                  } catch (e) {
                    // ignore: avoid_print
                    print('Failed to normalize provider ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<Map<String, dynamic>>()
                .toList();

            // Debug: log incoming doc count
            // ignore: avoid_print
            print('providers snapshot docs: ${fetched.length}');

            setState(() {
              _providers = fetched;
              _providersLoadError = null;
            });
            _applyFilters();
          },
          onError: (error, stack) {
            // If Firestore errors (offline or permission), show the error.
            // ignore: avoid_print
            print('providers snapshot error: $error');
            setState(() {
              _providers = [];
              _providersLoadError = error.toString();
            });
            _applyFilters();
          },
        );
  }

  Map<String, dynamic> _normalizeProviderData(
    Map<String, dynamic> data,
    String id,
  ) {
    final joined = data['joinedDate'];
    final joinedDate = _extractDateTime(joined);

    String asString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      // Common Firestore pattern: {"url": "..."}
      if (value is Map && value['url'] is String) return value['url'] as String;
      return value.toString();
    }

    String normalizeString(dynamic value, {required String fallback}) {
      final s = asString(value).trim();
      return s.isEmpty ? fallback : s;
    }

    String normalizeLocation(dynamic value) {
      if (value == null) return 'Location not specified';
      if (value is String) {
        final s = value.trim();
        return s.isEmpty ? 'Location not specified' : s;
      }
      if (value is Map) {
        final parts = <String>[];
        for (final key in const [
          'name',
          'address',
          'city',
          'region',
          'subCity',
        ]) {
          final v = value[key];
          if (v is String && v.trim().isNotEmpty) parts.add(v.trim());
        }
        if (parts.isNotEmpty) return parts.join(', ');
      }
      final s = value.toString().trim();
      return s.isEmpty ? 'Location not specified' : s;
    }

    return {
      ...data,
      'id': id,
      'joinedDate': joinedDate,
      'isFeatured': (data['isFeatured'] as bool?) ?? false,
      'isEmergency': (data['isEmergency'] as bool?) ?? false,
      'availability': normalizeString(
        data['availability'],
        fallback: 'Offline',
      ),
      'distance': (data['distance'] as num?)?.toDouble() ?? 0.0,
      'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'price': (data['price'] as num?)?.toInt() ?? 0,
      'reviewCount': (data['reviewCount'] as num?)?.toInt() ?? 0,
      'name': normalizeString(data['name'], fallback: 'Unknown Provider'),
      'category': normalizeString(data['category'], fallback: 'General'),
      'specialization': normalizeString(
        data['specialization'],
        fallback: 'General Services',
      ),
      'location': normalizeLocation(data['location']),
      'avatar': asString(data['avatar']),
    };
  }

  DateTime _extractDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _applyFilters() {
    setState(() {
      if (_debugBypassFilters) {
        _filteredProviders = List<Map<String, dynamic>>.from(_providers);
        _applySort();
        _updateFilterCount();
        return;
      }

      _filteredProviders = _providers.where((provider) {
        // Category filter
        final selectedCategory = _categoryFilter.trim();
        if (selectedCategory.isNotEmpty && selectedCategory != 'All') {
          final providerCategory =
              (provider['category'] as String?)?.trim() ?? '';
          if (providerCategory.toLowerCase() !=
              selectedCategory.toLowerCase()) {
            return false;
          }
        }

        // Distance filter
        final distance = (provider["distance"] as num?)?.toDouble() ?? 0;
        if (distance > _locationRadius) return false;

        // Availability filter
        if (_availabilityFilter != "All" &&
            provider["availability"] != _availabilityFilter) {
          return false;
        }

        // Rating filter
        final rating = (provider["rating"] as num?)?.toDouble() ?? 0;
        if (rating < _ratingThreshold) return false;

        // Price filter
        final price = (provider["price"] as num?)?.toInt() ?? 0;
        if (price < _priceRange.start || price > _priceRange.end) return false;

        // Search filter
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          final nameLower = (provider["name"] as String? ?? '').toLowerCase();
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
            (a, b) => ((a["distance"] as num?)?.toDouble() ?? 0).compareTo(
              (b["distance"] as num?)?.toDouble() ?? 0,
            ),
          );
          break;
        case "Rating":
          _filteredProviders.sort(
            (a, b) => ((b["rating"] as num?)?.toDouble() ?? 0).compareTo(
              (a["rating"] as num?)?.toDouble() ?? 0,
            ),
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
          _filteredProviders.sort((a, b) {
            final joinedA = _extractDateTime(a["joinedDate"]);
            final joinedB = _extractDateTime(b["joinedDate"]);
            return joinedB.compareTo(joinedA);
          });
          break;
      }

      // Featured providers always on top
      _filteredProviders.sort((a, b) {
        final aFeatured = (a["isFeatured"] as bool?) ?? false;
        final bFeatured = (b["isFeatured"] as bool?) ?? false;
        if (aFeatured == bFeatured) return 0;
        return aFeatured ? -1 : 1;
      });
    });
  }

  void _updateFilterCount() {
    int count = 0;
    if (_categoryFilter.trim() != 'All') count++;
    if (_locationRadius < 20.0) count++;
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

  Future<void> _toggleFavorite(String providerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(providerId);

    final wasFavorite = _favoriteProviderIds.contains(providerId);

    // Optimistic UI update.
    setState(() {
      if (wasFavorite) {
        _favoriteProviderIds.remove(providerId);
      } else {
        _favoriteProviderIds.add(providerId);
      }
    });

    try {
      if (wasFavorite) {
        await favoritesRef.delete();
      } else {
        await favoritesRef.set({'createdAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      // Revert UI if write fails.
      // ignore: avoid_print
      print('Failed to toggle favorite for $providerId: $e');
      if (!mounted) return;
      setState(() {
        if (wasFavorite) {
          _favoriteProviderIds.add(providerId);
        } else {
          _favoriteProviderIds.remove(providerId);
        }
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        categories: _availableCategories,
        categoryFilter: _categoryFilter,
        locationRadius: _locationRadius,
        availabilityFilter: _availabilityFilter,
        ratingThreshold: _ratingThreshold,
        priceRange: _priceRange,
        onApply: (category, radius, availability, rating, price) {
          setState(() {
            _categoryFilter = category;
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
            _categoryFilter = 'All';
            _locationRadius = 20.0;
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
                    unawaited(_toggleFavorite(provider["id"] as String));
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

    // Check if user is authenticated
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Providers')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'login',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 80,
                ),
                SizedBox(height: 3.h),
                Text(
                  'Authentication Required',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Please log in to view available providers',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/authentication-screen');
                  },
                  icon: CustomIconWidget(
                    iconName: 'login',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() => _currentBottomNavIndex = index);
          },
        ),
      );
    }

    // Compute displayed providers based on current tab
    final displayedProviders = _currentBottomNavIndex == 2
        ? _filteredProviders
              .where((p) => _favoriteProviderIds.contains(p['id']))
              .toList()
        : _filteredProviders;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBarWithFilter(
        title: _currentBottomNavIndex == 2 ? 'Favorites' : 'Search',
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
            child: displayedProviders.isEmpty
                ? (_providersLoadError != null
                      ? _buildLoadErrorState(theme, _providersLoadError!)
                      : _buildEmptyState(theme, _currentBottomNavIndex == 2))
                : RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: theme.colorScheme.primary,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      itemCount: displayedProviders.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        final provider = displayedProviders[index];
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
                          onFavoriteTap: () => unawaited(
                            _toggleFavorite(provider["id"] as String),
                          ),
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

  Widget _buildEmptyState(ThemeData theme, bool isFavoritesTab) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: isFavoritesTab ? 'favorite_border' : 'search_off',
              color: theme.colorScheme.onSurfaceVariant,
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              isFavoritesTab
                  ? 'No favorite providers yet'
                  : 'No providers found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              isFavoritesTab
                  ? 'Add providers to favorites to see them here'
                  : 'Try expanding your search radius or adjusting filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: isFavoritesTab
                  ? () => setState(() => _currentBottomNavIndex = 1)
                  : () {
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
                iconName: isFavoritesTab ? 'search' : 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                isFavoritesTab ? 'Browse Providers' : 'Reset Filters',
              ),
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

  Widget _buildLoadErrorState(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'report',
              color: theme.colorScheme.error,
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'Failed to load providers',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () {
                _providerSubscription?.cancel();
                _listenToProviders();
              },
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
