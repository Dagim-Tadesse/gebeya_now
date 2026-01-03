List<Map<String, dynamic>> generateCategoryProviders({
  required int startId,
  required int count,
  required String category,
  required List<String> specializations,
  required int basePrice,
  bool emergencyDefault = false,
}) {
  const firstNames = [
    'Abel',
    'Meron',
    'Dawit',
    'Saron',
    'Yonatan',
    'Liya',
    'Henok',
    'Bethel',
    'Solomon',
    'Selam',
    'Kaleb',
    'Tigist',
    'Meklit',
    'Mulu',
    'Nahom',
    'Rahel',
    'Samuel',
    'Eden',
    'Amanuel',
    'Hanna',
    'Robel',
    'Ruth',
    'Biruk',
    'Marta',
  ];

  const lastNames = [
    'Kebede',
    'Tesfaye',
    'Bekele',
    'Haile',
    'Tadesse',
    'Girma',
    'Abebe',
    'Mekonnen',
    'Assefa',
    'Wondimu',
    'Yohannes',
    'Getachew',
    'Alemu',
    'Demissie',
    'Worku',
    'Gebre',
    'Fikru',
    'Daniel',
  ];

  const locations = [
    'Bole, Addis Ababa',
    'Megenagna, Addis Ababa',
    'Kazanchis, Addis Ababa',
    'Piassa, Addis Ababa',
    'Saris, Addis Ababa',
    'CMC, Addis Ababa',
    'Gerji, Addis Ababa',
    '4 Kilo, Addis Ababa',
    '6 Kilo, Addis Ababa',
    'Mexico, Addis Ababa',
    'Gurd Shola, Addis Ababa',
    'Jemo, Addis Ababa',
  ];

  return List<Map<String, dynamic>>.generate(count, (index) {
    final id = (startId + index).toString();
    final first = firstNames[index % firstNames.length];
    final last = lastNames[(index * 7) % lastNames.length];
    final specialization = specializations[index % specializations.length];

    final gender = (index % 2 == 0) ? 'men' : 'women';
    final avatarId = (startId + index) % 100;

    final rating = 4.2 + ((index % 8) * 0.1);
    final reviewCount = 18 + (index * 5);
    final distance = 0.9 + ((index % 14) * 0.45);
    final availability = (index % 5 == 0) ? 'Busy' : 'Available';

    final isFeatured = index < 6;
    final isEmergency = emergencyDefault ? (index % 4 != 0) : (index % 10 == 0);

    final price = basePrice + ((index % 7) * 20);

    final month = ((index % 12) + 1).toString().padLeft(2, '0');
    final day = (((index * 3) % 28) + 1).toString().padLeft(2, '0');
    final joinedDate = '2024-$month-${day}T00:00:00+03:00';

    final phone =
        '+2519${(10000000 + startId + index).toString().padLeft(8, '0')}';

    return {
      'id': id,
      'name': '$first $last',
      'avatar': 'https://randomuser.me/api/portraits/$gender/$avatarId.jpg',
      'semanticLabel':
          'Profile photo of a local service professional for $category services',
      'specialization': specialization,
      'category': category,
      'rating': double.parse(rating.toStringAsFixed(1)),
      'reviewCount': reviewCount,
      'location': locations[index % locations.length],
      'distance': double.parse(distance.toStringAsFixed(1)),
      'availability': availability,
      'phone': phone,
      'isFeatured': isFeatured,
      'isEmergency': isEmergency,
      'price': price,
      'joinedDate': joinedDate,
    };
  });
}
