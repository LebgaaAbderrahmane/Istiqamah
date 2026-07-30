class HabitModel {
  final String id;
  final String name;
  final String icon;
  final String type;
  final int targetValue;
  final String? unit;
  final bool isCustom;
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.targetValue,
    this.unit,
    this.isCustom = false,
    this.isArchived = false,
    required this.sortOrder,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'type': type,
        'targetValue': targetValue,
        'unit': unit,
        'isCustom': isCustom ? 1 : 0,
        'isArchived': isArchived ? 1 : 0,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HabitModel.fromMap(Map<String, dynamic> map) => HabitModel(
        id: map['id'] as String,
        name: map['name'] as String,
        icon: map['icon'] as String,
        type: map['type'] as String,
        targetValue: map['targetValue'] as int,
        unit: map['unit'] as String?,
        isCustom: (map['isCustom'] as int) == 1,
        isArchived: (map['isArchived'] as int) == 1,
        sortOrder: map['sortOrder'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  HabitModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? type,
    int? targetValue,
    String? unit,
    bool? isCustom,
    bool? isArchived,
    int? sortOrder,
    DateTime? createdAt,
  }) =>
      HabitModel(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        type: type ?? this.type,
        targetValue: targetValue ?? this.targetValue,
        unit: unit ?? this.unit,
        isCustom: isCustom ?? this.isCustom,
        isArchived: isArchived ?? this.isArchived,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
}
