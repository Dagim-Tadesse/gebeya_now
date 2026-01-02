import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/contact_tab_widget.dart';
import './widgets/gallery_tab_widget.dart';
import './widgets/overview_tab_widget.dart';
import './widgets/provider_header_widget.dart';
import './widgets/reviews_tab_widget.dart';

/// Provider Detail Screen - Comprehensive provider information with tabbed interface
class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({super.key});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  // Mock provider data
  final Map<String, dynamic> _providerData = {
    "id": 1,
    "name": "Abebe Kebede",
    "category": "Plumber",
    "profilePhoto":
        "https://img.rocket.new/generatedImages/rocket_gen_img_104e29039-1764692414441.png",
    "profilePhotoLabel":
        "Professional headshot of Ethiopian man with short black hair wearing blue work shirt",
    "rating": 4.8,
    "reviewCount": 127,
    "isAvailable": true,
    "description":
        "Experienced plumber with over 10 years of expertise in residential and commercial plumbing services. Specializing in pipe installation, leak repairs, water heater maintenance, and emergency plumbing solutions. Committed to providing reliable and affordable services across Addis Ababa.",
    "specializations": [
      "Pipe Installation",
      "Leak Repair",
      "Water Heater",
      "Emergency Service",
    ],
    "yearsOfExperience": 10,
    "startingPrice": "ETB 500",
    "workingHours": "Mon-Sat: 8:00 AM - 6:00 PM",
    "nextAvailable": "Tomorrow 9:00 AM",
    "verificationBadges": [
      {"label": "ID Verified", "icon": "verified_user", "verified": true},
      {"label": "Business License", "icon": "business", "verified": true},
      {"label": "Customer Reviews", "icon": "star", "verified": true},
    ],
    "phoneNumber": "+251 911 234567",
    "location": "Bole, Addis Ababa",
    "responseTime": "Within 2 hours",
    "isEmergency": true,
  };

  final List<Map<String, dynamic>> _galleryImages = [
    {
      "url":
          "https://img.rocket.new/generatedImages/rocket_gen_img_196d68a43-1767243752716.png",
      "semanticLabel":
          "Close-up of hands installing copper pipes with wrench in residential plumbing system",
    },
    {
      "url":
          "https://img.rocket.new/generatedImages/rocket_gen_img_160b7e1b9-1766470487118.png",
      "semanticLabel":
          "Modern bathroom with white fixtures showing completed plumbing installation work",
    },
    {
      "url":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1b4ddf275-1765034674882.png",
      "semanticLabel":
          "Professional plumber repairing water heater with tools in utility room",
    },
    {
      "url": "https://images.unsplash.com/photo-1589173956745-70a6c22b1b09",
      "semanticLabel":
          "Kitchen sink installation showing chrome faucet and drainage pipes underneath",
    },
  ];

  final List<Map<String, dynamic>> _reviews = [
    {
      "customerName": "Marta Tesfaye",
      "customerPhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1b0d0b9cd-1763296099864.png",
      "customerPhotoLabel":
          "Profile photo of Ethiopian woman with long dark hair wearing white blouse",
      "rating": 5.0,
      "date": "2 days ago",
      "comment":
          "Excellent service! Abebe fixed our leaking pipes quickly and professionally. Very reasonable prices and arrived on time. Highly recommended!",
    },
    {
      "customerName": "Daniel Haile",
      "customerPhoto":
          "https://img.rocket.new/generatedImages/rocket_gen_img_16312bea3-1763294026379.png",
      "customerPhotoLabel":
          "Profile photo of Ethiopian man with short hair wearing casual blue shirt",
      "rating": 4.5,
      "date": "1 week ago",
      "comment":
          "Good work on installing our new water heater. Professional and knowledgeable. Would hire again for future plumbing needs.",
    },
    {
      "customerName": "Sara Bekele",
      "customerPhoto":
          "https://images.unsplash.com/photo-1535046757974-7a9b8c1ae42c",
      "customerPhotoLabel":
          "Profile photo of young Ethiopian woman with curly hair wearing red top",
      "rating": 5.0,
      "date": "2 weeks ago",
      "comment":
          "Emergency service was fantastic! Called late at night for a burst pipe and Abebe came within an hour. Saved us from major water damage. Thank you!",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _shareProvider,
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            icon: CustomIconWidget(
              iconName: _isFavorite ? 'favorite' : 'favorite_border',
              color: _isFavorite
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          // Provider header
          ProviderHeaderWidget(provider: _providerData),
          SizedBox(height: 2.h),
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 2,
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: "Overview"),
                Tab(text: "Gallery"),
                Tab(text: "Reviews"),
                Tab(text: "Contact"),
              ],
            ),
          ),
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTabWidget(provider: _providerData),
                GalleryTabWidget(galleryImages: _galleryImages),
                ReviewsTabWidget(reviews: _reviews),
                ContactTabWidget(provider: _providerData),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _makePhoneCall(_providerData["phoneNumber"] as String),
        backgroundColor: theme.colorScheme.primary,
        icon: CustomIconWidget(
          iconName: 'call',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          "Call Now",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _shareProvider() {
    Share.share(
      'Check out ${_providerData["name"]} - ${_providerData["category"]} on GebeyaNow!\n\nRating: ${_providerData["rating"]} ⭐ (${_providerData["reviewCount"]} reviews)\nPhone: ${_providerData["phoneNumber"]}',
      subject: 'Service Provider Recommendation',
    );
  }
}
