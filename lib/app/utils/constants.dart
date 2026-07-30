class AppConstants {
  static const String appName = 'Istiqamah';
  static const int maxEditDaysBack = 7;
  static const int ramadanMonth = 9;
}

class DefaultHabits {
  static const List<Map<String, dynamic>> habits = [
    {
      'name': 'Fajr',
      'icon': 'mosque',
      'type': 'boolean',
      'targetValue': 1,
      'isCustom': false,
    },
    {
      'name': 'Dhuhr',
      'icon': 'mosque',
      'type': 'boolean',
      'targetValue': 1,
      'isCustom': false,
    },
    {
      'name': 'Asr',
      'icon': 'mosque',
      'type': 'boolean',
      'targetValue': 1,
      'isCustom': false,
    },
    {
      'name': 'Maghrib',
      'icon': 'mosque',
      'type': 'boolean',
      'targetValue': 1,
      'isCustom': false,
    },
    {
      'name': 'Isha',
      'icon': 'mosque',
      'type': 'boolean',
      'targetValue': 1,
      'isCustom': false,
    },
    {
      'name': 'Quran',
      'icon': 'book',
      'type': 'count',
      'targetValue': 1,
      'unit': 'pages',
      'isCustom': false,
    },
    {
      'name': 'Dhikr',
      'icon': 'stars',
      'type': 'count',
      'targetValue': 33,
      'unit': 'times',
      'isCustom': false,
    },
    {
      'name': 'Sadaqah',
      'icon': 'volunteer_activism',
      'type': 'boolean',
      'targetValue': 1,
      'isCustom': false,
    },
    {
      'name': 'Qiyam al-layl',
      'icon': 'nightlight',
      'type': 'boolean',
      'targetValue': 1,
      'isCustom': false,
    },
  ];
}
