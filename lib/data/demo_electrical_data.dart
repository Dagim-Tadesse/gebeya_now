import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoElectricalData = generateCategoryProviders(
  startId: 46,
  count: 38,
  category: 'Electrical',
  specializations: const [
    'Wiring & Installation',
    'Circuit Breaker Repair',
    'Lighting Installation',
    'Outlet & Switch Repair',
    'Generator Setup',
    'Emergency Electrical',
  ],
  basePrice: 260,
  emergencyDefault: true,
);
