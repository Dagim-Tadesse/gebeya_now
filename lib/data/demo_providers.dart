import 'demo_beauty_data.dart';
import 'demo_carpentry_data.dart';
import 'demo_cleaning_data.dart';
import 'demo_electrical_data.dart';
import 'demo_gardening_data.dart';
import 'demo_painting_data.dart';
import 'demo_plumber_data.dart';
import 'demo_repair_data.dart';
import 'demo_tailoring_data.dart';
import 'demo_tutoring_data.dart';

/// Aggregated demo providers across categories.
///
/// Keep plumbers in [demoPlumberData] and add other categories later by
/// importing their lists and spreading them into this list.
final List<Map<String, dynamic>> demoProviders = [
  ...demoPlumberData,
  ...demoElectricalData,
  ...demoTailoringData,
  ...demoTutoringData,
  ...demoCleaningData,
  ...demoRepairData,
  ...demoBeautyData,
  ...demoCarpentryData,
  ...demoPaintingData,
  ...demoGardeningData,
];
