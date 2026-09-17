/// Modelo que representa una clase en el horario del estudiante
class ScheduleClassModel {
  final String id;
  final String userId;
  final String className;
  final int dayOfWeek; // 1 = Lunes, 7 = Domingo
  final String startTime; // HH:mm
  final String endTime; // HH:mm

  ScheduleClassModel({
    required this.id,
    required this.userId,
    required this.className,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleClassModel.fromJson(Map<String, dynamic> json) {
    return ScheduleClassModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      className: json['class_name'] as String,
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'class_name': className,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }
}
