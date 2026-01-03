import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'package:gebeyanow/data/demo_providers.dart';
import 'package:gebeyanow/firebase_options.dart';

/// One-off seeding script to import demo providers into Firestore.
/// Run with: flutter run -d emulator-5554 -t tool/seed_providers.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Print the active Firebase project so you can verify you're looking at the
  // same project in the Firebase Console.
  final app = Firebase.app();
  // ignore: avoid_print
  print(
    'Seeding providers into projectId=${app.options.projectId}, appId=${app.options.appId}',
  );

  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  String inferCategoryFromSpecialization(String specialization) {
    final s = specialization.toLowerCase();
    if (s.contains('plumb') || s.contains('drain') || s.contains('pipe')) {
      return 'Plumbing';
    }
    if (s.contains('electric') || s.contains('wiring')) {
      return 'Electrical';
    }
    if (s.contains('clean')) {
      return 'Cleaning';
    }
    if (s.contains('paint')) {
      return 'Painting';
    }
    return 'General';
  }

  for (final raw in demoProviders) {
    final data = Map<String, dynamic>.from(raw);
    final docId = (data.remove('id') as String?)?.trim();

    if (docId == null || docId.isEmpty) {
      throw StateError(
        'Provider is missing a non-empty id. Provider data: $data',
      );
    }

    // Convert ISO date string to Timestamp if present.
    final joined = data['joinedDate'];
    if (joined is String && joined.isNotEmpty) {
      data['joinedDate'] = Timestamp.fromDate(DateTime.parse(joined));
    }

    // Ensure numeric fields are stored as num/double/int.
    data['rating'] = (data['rating'] as num).toDouble();
    data['distance'] = (data['distance'] as num).toDouble();
    data['price'] = (data['price'] as num).toInt();
    data['reviewCount'] = (data['reviewCount'] as num).toInt();

    // Ensure a top-level category exists for filtering/grouping.
    final category = (data['category'] as String?)?.trim();
    if (category == null || category.isEmpty) {
      final specialization = (data['specialization'] as String?)?.trim() ?? '';
      data['category'] = inferCategoryFromSpecialization(specialization);
    }

    // Mark as demo so you can filter/clean later if needed.
    data['isDemo'] = true;

    final ref = firestore.collection('providers').doc(docId);
    batch.set(ref, data, SetOptions(merge: true));
  }

  try {
    await batch.commit();
    // ignore: avoid_print
    print('Seeded ${demoProviders.length} providers.');

    // Force a server read to confirm the writes actually reached Cloud Firestore
    // (not just local/offline cache).
    final serverSnap = await firestore
        .collection('providers')
        .limit(5)
        .get(const GetOptions(source: Source.server));
    // ignore: avoid_print
    print(
      'Server read-back ok. providers sample count=${serverSnap.docs.length}, ids=${serverSnap.docs.map((d) => d.id).toList()}',
    );
  } on FirebaseException catch (e) {
    // ignore: avoid_print
    print('Firestore seeding failed: code=${e.code}, message=${e.message}');
    rethrow;
  }
}
