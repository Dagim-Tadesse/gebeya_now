import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoPaintingData = generateCategoryProviders(
  startId: 272,
  count: 31,
  category: 'Painting',
  specializations: const [
    'Interior Painting',
    'Exterior Painting',
    'Wall Finishing',
    'Color Consultation',
    'Fence Painting',
  ],
  basePrice: 220,
);
