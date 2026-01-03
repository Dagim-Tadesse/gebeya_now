import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoGardeningData = generateCategoryProviders(
  startId: 303,
  count: 18,
  category: 'Gardening',
  specializations: const [
    'Garden Maintenance',
    'Landscaping',
    'Lawn Care',
    'Tree Trimming',
    'Planting & Setup',
  ],
  basePrice: 150,
);
