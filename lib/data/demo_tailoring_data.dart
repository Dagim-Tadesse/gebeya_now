import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoTailoringData = generateCategoryProviders(
  startId: 84,
  count: 31,
  category: 'Tailoring',
  specializations: const [
    'Custom Suits',
    'Dress Making',
    'Traditional Wear',
    'Alterations',
    'Uniform Stitching',
  ],
  basePrice: 180,
);
