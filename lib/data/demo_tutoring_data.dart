import 'demo_provider_generator.dart';

final List<Map<String, dynamic>> demoTutoringData = generateCategoryProviders(
  startId: 115,
  count: 41,
  category: 'Tutoring',
  specializations: const [
    'Math Tutoring',
    'English Tutoring',
    'Science Tutoring',
    'Exam Preparation',
    'Computer Basics',
    'Homework Help',
  ],
  basePrice: 120,
);
