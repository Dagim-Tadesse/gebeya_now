import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/category_card_widget.dart';
import './widgets/featured_category_widget.dart';
import './widgets/location_header_widget.dart';

/// Service Categories Screen - Main browse interface for discovering local service providers
/// Implements Ethiopian Heritage Palette with Contemporary Functional Minimalism
class ServiceCategoriesScreen extends StatefulWidget {
  const ServiceCategoriesScreen({super.key});

  @override
  State<ServiceCategoriesScreen> createState() =>
      _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen>
    with SingleTickerProviderStateMixin {
  int _currentBottomNavIndex = 0;
  bool _isGridView = true;
  // ignore: unused_field
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  // Mock data for service categories with Ethiopian context
  final List<Map<String, dynamic>> _serviceCategories = [
    {
      "id": 1,
      "name": "Plumbing",
      "nameAmharic": "የቧንቧ ስራ",
      "icon": "plumbing",
      "providerCount": 45,
      "isEmergency": true,
      "isFeatured": true,
      "description": "Professional plumbing services for homes and businesses",
    },
    {
      "id": 2,
      "name": "Electrical",
      "nameAmharic": "የኤሌክትሪክ ስራ",
      "icon": "electrical_services",
      "providerCount": 38,
      "isEmergency": true,
      "isFeatured": true,
      "description": "Licensed electricians for all electrical needs",
    },
    {
      "id": 3,
      "name": "Tailoring",
      "nameAmharic": "የልብስ ስፌት",
      "icon": "checkroom",
      "providerCount": 52,
      "isEmergency": false,
      "isFeatured": true,
      "description": "Custom tailoring and clothing alterations",
    },
    {
      "id": 4,
      "name": "Tutoring",
      "nameAmharic": "የግል ትምህርት",
      "icon": "school",
      "providerCount": 67,
      "isEmergency": false,
      "isFeatured": false,
      "description": "Academic tutoring for all subjects and levels",
    },
    {
      "id": 5,
      "name": "Cleaning",
      "nameAmharic": "የጽዳት አገልግሎት",
      "icon": "cleaning_services",
      "providerCount": 41,
      "isEmergency": false,
      "isFeatured": false,
      "description": "Professional cleaning services for homes and offices",
    },
    {
      "id": 6,
      "name": "Repair",
      "nameAmharic": "የጥገና ስራ",
      "icon": "build",
      "providerCount": 33,
      "isEmergency": false,
      "isFeatured": false,
      "description": "General repair and maintenance services",
    },
    {
      "id": 7,
      "name": "Beauty",
      "nameAmharic": "የውበት አገልግሎት",
      "icon": "face_retouching_natural",
      "providerCount": 29,
      "isEmergency": false,
      "isFeatured": false,
      "description": "Beauty and personal care services",
    },
    {
      "id": 8,
      "name": "Carpentry",
      "nameAmharic": "የእንጨት ስራ",
      "icon": "carpenter",
      "providerCount": 24,
      "isEmergency": false,
      "isFeatured": false,
      "description": "Custom carpentry and woodworking services",
    },
    {
      "id": 9,
      "name": "Painting",
      "nameAmharic": "የቀለም ስራ",
      "icon": "format_paint",
      "providerCount": 31,
      "isEmergency": false,
      "isFeatured": false,
      "description":
          "Professional painting services for interiors and exteriors",
    },
    {
      "id": 10,
      "name": "Gardening",
      "nameAmharic": "የአትክልት ስራ",
      "icon": "yard",
      "providerCount": 18,
      "isEmergency": false,
      "isFeatured": false,
      "description": "Landscaping and garden maintenance services",
    },
  ];

  // Mock data for top providers preview
  final Map<int, List<Map<String, dynamic>>> _topProvidersByCategory = {
    1: [
      {
        "name": "Abebe Kebede",
        "rating": 4.8,
        "image":
            "https://img.rocket.new/generatedImages/rocket_gen_img_18480903d-1763296157675.png",
        "semanticLabel":
            "Profile photo of a man with short dark hair wearing a blue work shirt",
      },
      {
        "name": "Tigist Haile",
        "rating": 4.9,
        "image":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1f1d2e603-1763296333785.png",
        "semanticLabel":
            "Profile photo of a woman with curly hair wearing professional attire",
      },
      {
        "name": "Dawit Tesfaye",
        "rating": 4.7,
        "image":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1d2c03853-1763292579855.png",
        "semanticLabel":
            "Profile photo of a man with glasses wearing a work uniform",
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate API call to refresh data
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categories updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleViewMode() {
    setState(() => _isGridView = !_isGridView);
  }

  void _handleCategoryTap(Map<String, dynamic> category) {
    Navigator.pushNamed(
      context,
      '/provider-list-screen',
      arguments: {
        'categoryId': category['id'],
        'categoryName': category['name'],
      },
    );
  }

  void _handleCategoryLongPress(Map<String, dynamic> category) {
    final topProviders = _topProvidersByCategory[category['id']] ?? [];

    if (topProviders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No providers available in ${category['name']}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildTopProvidersSheet(category, topProviders),
    );
  }

  Widget _buildTopProvidersSheet(
    Map<String, dynamic> category,
    List<Map<String, dynamic>> providers,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top ${category['name']} Providers',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...providers.map(
            (provider) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CustomImageWidget(
                  imageUrl: provider['image'] as String,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  semanticLabel: provider['semanticLabel'] as String,
                ),
              ),
              title: Text(provider['name'] as String),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    provider['rating'].toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/provider-detail-screen');
              },
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleCategoryTap(category);
              },
              child: const Text('View All Providers'),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredCategories() {
    if (_searchQuery.isEmpty) {
      return _serviceCategories;
    }

    return _serviceCategories.where((category) {
      final name = (category['name'] as String).toLowerCase();
      final nameAmharic = category['nameAmharic'] as String;
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || nameAmharic.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _getFeaturedCategories() {
    return _serviceCategories
        .where((category) => category['isFeatured'] == true)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCategories = _getFilteredCategories();
    final featuredCategories = _getFeaturedCategories();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'GebeyaNow',
        variant: CustomAppBarVariant.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'notifications_outlined',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Notifications',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              // Location header
              SliverToBoxAdapter(
                child: LocationHeaderWidget(
                  currentCity: 'Addis Ababa',
                  onLocationTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location selection coming soon'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),

              // Search bar and view toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            style: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Search categories...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(2.w),
                                child: CustomIconWidget(
                                  iconName: 'search',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: CustomIconWidget(
                                        iconName: 'clear',
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
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
                      SizedBox(width: 2.w),
                      Container(
                        height: 6.h,
                        width: 6.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: CustomIconWidget(
                            iconName: _isGridView ? 'view_list' : 'grid_view',
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          onPressed: _toggleViewMode,
                          tooltip: _isGridView ? 'List view' : 'Grid view',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Featured categories section
              if (featuredCategories.isNotEmpty && _searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'Featured Services',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      SizedBox(
                        height: 18.h,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredCategories.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 3.w),
                          itemBuilder: (context, index) {
                            return FeaturedCategoryWidget(
                              category: featuredCategories[index],
                              onTap: () =>
                                  _handleCategoryTap(featuredCategories[index]),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),

              // All categories section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    _searchQuery.isEmpty ? 'All Categories' : 'Search Results',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 1.h)),

              // Categories grid/list
              if (filteredCategories.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'search_off',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 64,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No categories found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Try a different search term',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isGridView)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return CategoryCardWidget(
                        category: filteredCategories[index],
                        onTap: () =>
                            _handleCategoryTap(filteredCategories[index]),
                        onLongPress: () =>
                            _handleCategoryLongPress(filteredCategories[index]),
                      );
                    }, childCount: filteredCategories.length),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      child: CategoryCardWidget(
                        category: filteredCategories[index],
                        isListView: true,
                        onTap: () =>
                            _handleCategoryTap(filteredCategories[index]),
                        onLongPress: () =>
                            _handleCategoryLongPress(filteredCategories[index]),
                      ),
                    );
                  }, childCount: filteredCategories.length),
                ),

              // Bottom padding
              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              // Empty state for no providers
              if (filteredCategories.isEmpty && _searchQuery.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'category',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 64,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No categories available',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Be the first to offer services in your area',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 3.h),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/provider-registration-screen',
                              );
                            },
                            icon: CustomIconWidget(
                              iconName: 'add_business',
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                            label: const Text('Become a Provider'),
                          ),
                        ],
                      ),
                    ),
                  ),
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
}
