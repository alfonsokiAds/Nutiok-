/// Modelo de nota alimentaria para NUTIOK
/// HU-3: Crear y guardar notas sobre comidas
library;

/// Alias para compatibilidad con pantallas que usan Note
typedef Note = NoteModel;

class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? mealType; // desayuno, almuerzo, cena, snack
  final DateTime mealDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.mealType,
    required this.mealDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mealType: json['meal_type'] as String?,
      mealDate: DateTime.parse(json['meal_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'meal_type': mealType,
      'meal_date': mealDate.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  NoteModel copyWith({
    String? title,
    String? content,
    String? mealType,
    DateTime? mealDate,
  }) {
    return NoteModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mealType: mealType ?? this.mealType,
      mealDate: mealDate ?? this.mealDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Alias para compatibilidad - mealDate como date
  DateTime get date => mealDate;

  /// Alias para compatibilidad - mealType nunca es null en uso
  String get mealTypeDisplay => mealType ?? 'Otro';
}
