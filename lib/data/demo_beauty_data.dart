import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoBeautyData = generateCategoryProviders(
  startId: 219,
  count: 29,
  category: 'Beauty',
  specializations: const [
    'Hair Styling',
    'Makeup',
    'Henna',
    'Braiding',
    'Skincare',
  ],
  basePrice: 140,
);
