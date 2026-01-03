import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoCleaningData = generateCategoryProviders(
  startId: 156,
  count: 30,
  category: 'Cleaning',
  specializations: const [
    'Home Cleaning',
    'Office Cleaning',
    'Deep Cleaning',
    'Move-in/Move-out Cleaning',
    'Carpet Cleaning',
  ],
  basePrice: 160,
);
