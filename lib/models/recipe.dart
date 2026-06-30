/// Modelo de receta para NUTIOK
/// HU-5: Consultar recetas saludables
library;

/// Alias para compatibilidad con pantallas que usan Recipe
typedef Recipe = RecipeModel;

class RecipeModel {
  final String id;
  final String name;
  final String description;
  final String category; // desayuno, almuerzo, cena, snack
  final String difficulty; // facil, media, dificil
  final int preparationTime; // en minutos

  /// Alias para compatibilidad con pantallas que usan prepTime
  String get prepTime => '$preparationTime min';
  final int servings;
  final List<String> ingredients;
  final List<String> steps;
  final String? imageUrl;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final bool isFavorite;

  RecipeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.preparationTime,
    required this.servings,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.isFavorite = false,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'otro',
      difficulty: json['difficulty'] as String? ?? 'facil',
      preparationTime: json['preparation_time'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      steps: List<String>.from(json['steps'] as List? ?? []),
      imageUrl: json['image_url'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'preparation_time': preparationTime,
      'servings': servings,
      'ingredients': ingredients,
      'steps': steps,
      'image_url': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'is_favorite': isFavorite,
    };
  }

  /// Alias para compatibilidad - difficulty como String
  String get difficultyStr => difficulty;

  /// Obtener icono de dificultad
  String get difficultyLabel {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return 'Facil';
      case 'media':
        return 'Media';
      case 'dificil':
        return 'Dificil';
      default:
        return difficulty;
    }
  }

  /// Color de dificultad
  int get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return 0xFF4CAF50;
      case 'media':
        return 0xFFFF9800;
      case 'dificil':
        return 0xFFE53935;
      default:
        return 0xFF9E9E9E;
    }
  }

  RecipeModel copyWith({
    bool? isFavorite,
  }) {
    return RecipeModel(
      id: id,
      name: name,
      description: description,
      category: category,
      difficulty: difficulty,
      preparationTime: preparationTime,
      servings: servings,
      ingredients: ingredients,
      steps: steps,
      imageUrl: imageUrl,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
