/// Modelo de recordatorio para NUTIOK
/// HU-4: Recibir recordatorios de horarios de comida
library;

/// Alias para compatibilidad con pantallas que usan Reminder
typedef Reminder = ReminderModel;

class ReminderModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String time; // Formato HH:mm
  final String mealType; // desayuno, almuerzo, cena, snack
  bool isActive;
  final bool repeatDaily;
  final int? dayOfWeek; // 1=Lunes, 7=Domingo, null = todos los dias
  final DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.time,
    required this.mealType,
    this.isActive = true,
    this.repeatDaily = true,
    this.dayOfWeek,
    required this.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      time: json['time'] as String,
      mealType: json['meal_type'] as String,
      isActive: json['is_active'] as bool? ?? true,
      repeatDaily: json['repeat_daily'] as bool? ?? true,
      dayOfWeek: json['day_of_week'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'time': time,
      'meal_type': mealType,
      'is_active': isActive,
      'repeat_daily': repeatDaily,
      'day_of_week': dayOfWeek,
    };
  }

  /// Obtener la hora como TimeOfDay
  DateTime get scheduledTime {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Obtener icono segun tipo de comida
  String get mealIcon {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return 'wb_sunny';
      case 'almuerzo':
        return 'restaurant';
      case 'cena':
        return 'dinner_dining';
      default:
        return 'coffee';
    }
  }

  ReminderModel copyWith({
    String? title,
    String? message,
    String? time,
    String? mealType,
    bool? isActive,
    bool? repeatDaily,
    int? dayOfWeek,
  }) {
    return ReminderModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      mealType: mealType ?? this.mealType,
      isActive: isActive ?? this.isActive,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      createdAt: createdAt,
    );
  }
}
