/// Modelo de usuario para NUTIOK
/// Correspondiente a la tabla 'profiles' en Supabase
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final int? age;
  final double? weight;
  final double? height;
  final double? bmi;
  final String? gender;
  final String? dietaryGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.age,
    this.weight,
    this.height,
    this.bmi,
    this.gender,
    this.dietaryGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear desde JSON de Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      age: json['age'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      dietaryGoal: json['dietary_goal'] as String?,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'age': age,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'gender': gender,
      'dietary_goal': dietaryGoal,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Calcular IMC (Indice de Masa Corporal)
  double calculateBMI() {
    if (weight == null || height == null || height == 0) return 0;
    final heightM = height! / 100;
    return weight! / (heightM * heightM);
  }

  /// Obtener categoria del IMC
  String getBMICategory() {
    final bmi = calculateBMI();
    if (bmi == 0) return 'No disponible';
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  /// Copia con campos actualizados
  UserModel copyWith({
    String? fullName,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? dietaryGoal,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: (weight ?? this.weight) != null && (height ?? this.height) != null
          ? calculateBMI()
          : bmi,
      gender: gender ?? this.gender,
      dietaryGoal: dietaryGoal ?? this.dietaryGoal,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
