import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoRepairData = generateCategoryProviders(
  startId: 186,
  count: 33,
  category: 'Repair',
  specializations: const [
    'Appliance Repair',
    'Door & Lock Repair',
    'Furniture Repair',
    'Mobile Repair',
    'General Maintenance',
    'Emergency Repair',
  ],
  basePrice: 200,
);
