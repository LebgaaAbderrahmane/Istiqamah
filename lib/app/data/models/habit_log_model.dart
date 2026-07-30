class HabitLogModel {
  final String id;
  final String habitId;
  final DateTime date;
  final int value;
  final DateTime loggedAt;

  HabitLogModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.value,
    required this.loggedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'habitId': habitId,
        'date': normalizeDate(date),
        'value': value,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory HabitLogModel.fromMap(Map<String, dynamic> map) => HabitLogModel(
        id: map['id'] as String,
        habitId: map['habitId'] as String,
        date: DateTime.parse(map['date'] as String),
        value: map['value'] as int,
        loggedAt: DateTime.parse(map['loggedAt'] as String),
      );

  HabitLogModel copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    int? value,
    DateTime? loggedAt,
  }) =>
      HabitLogModel(
        id: id ?? this.id,
        habitId: habitId ?? this.habitId,
        date: date ?? this.date,
        value: value ?? this.value,
        loggedAt: loggedAt ?? this.loggedAt,
      );

  static String normalizeDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
