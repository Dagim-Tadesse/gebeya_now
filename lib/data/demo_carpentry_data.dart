import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoCarpentryData = generateCategoryProviders(
  startId: 248,
  count: 24,
  category: 'Carpentry',
  specializations: const [
    'Custom Furniture',
    'Door Installation',
    'Cabinet Making',
    'Wood Repair',
    'Shelving & Storage',
  ],
  basePrice: 240,
);
