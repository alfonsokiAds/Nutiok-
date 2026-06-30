import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../data/recipe_data.dart';

/// Provider para gestionar recordatorios y recetas
/// Sprint 2 - HU-4: Recordatorios
/// Sprint 3 - HU-5: Recetas
class RemindersProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<ReminderModel> _reminders = [];
  List<RecipeModel> _recipes = [];
  List<String> _favoriteRecipeIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReminderModel> get reminders => _reminders;
  List<RecipeModel> get recipes => _recipes;
  List<String> get favoriteRecipeIds => _favoriteRecipeIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Alias para compatibilidad con pantallas que usan isLoadingReminders
  bool get isLoadingReminders => _isLoading;

  /// Alias para compatibilidad con pantallas que usan isLoadingRecipes
  bool get isLoadingRecipes => false; // Las recetas se cargan de forma sincrona

  // =====================
  // RECORDATORIOS (HU-4)
  // =====================

  /// Cargar recordatorios
  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    _reminders = await _dbService.getReminders();

    _isLoading = false;
    notifyListeners();
  }

  /// Crear recordatorio
  Future<bool> createReminder({
    required String title,
    required String message,
    required String time,
    required String mealType,
    bool repeatDaily = true,
  }) async {
    final userId = _dbService.supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Debe iniciar sesion';
      notifyListeners();
      return false;
    }

    final reminder = ReminderModel(
      id: '', // Generado por Supabase
      userId: userId,
      title: title,
      message: message,
      time: time,
      mealType: mealType,
      isActive: true,
      repeatDaily: repeatDaily,
      createdAt: DateTime.now(),
    );

    final result = await _dbService.createReminder(reminder);

    if (result.error != null) {
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }

    if (result.reminder != null) {
      // Programar notificacion
      await _notificationService.scheduleReminder(result.reminder!);
      _reminders.add(result.reminder!);
    }

    notifyListeners();
    return true;
  }

  /// Actualizar recordatorio
  Future<bool> updateReminder(ReminderModel reminder) async {
    final result = await _dbService.updateReminder(reminder);

    if (result.success) {
      await _notificationService.scheduleReminder(reminder);
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder;
      }
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Eliminar recordatorio
  Future<bool> deleteReminder(String reminderId) async {
    final result = await _dbService.deleteReminder(reminderId);

    if (result.success) {
      await _notificationService.cancelReminder(reminderId.hashCode);
      _reminders.removeWhere((r) => r.id == reminderId);
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Activar/Desactivar recordatorio
  Future<void> toggleReminder(ReminderModel reminder) async {
    final updated = reminder.copyWith(isActive: !reminder.isActive);

    if (!updated.isActive) {
      await _notificationService.cancelReminder(reminder.hashCode);
    } else {
      await _notificationService.scheduleReminder(updated);
    }

    await updateReminder(updated);
  }

  // =====================
  // RECETAS (HU-5)
  // =====================

  /// Cargar recetas desde datos locales
  void loadRecipes() {
    // Cargar recetas predeterminadas
    _recipes = RecipeData.defaultRecipes
        .map((json) => RecipeModel.fromJson(json))
        .toList();
    notifyListeners();
  }

  /// Filtrar recetas por categoria
  List<RecipeModel> getRecipesByCategory(String category) {
    if (category == 'todas') return _recipes;
    return _recipes.where((r) => r.category == category).toList();
  }

  /// Buscar recetas por nombre
  List<RecipeModel> searchRecipes(String query) {
    if (query.isEmpty) return _recipes;
    final lowerQuery = query.toLowerCase();
    return _recipes
        .where((r) =>
            r.name.toLowerCase().contains(lowerQuery) ||
            r.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Alternar favorito
  Future<void> toggleFavorite(String recipeId) async {
    final isCurrentlyFavorite = _favoriteRecipeIds.contains(recipeId);
    final success =
        await _dbService.toggleFavorite(recipeId, !isCurrentlyFavorite);

    if (success) {
      if (isCurrentlyFavorite) {
        _favoriteRecipeIds.remove(recipeId);
      } else {
        _favoriteRecipeIds.add(recipeId);
      }
      notifyListeners();
    }
  }

  /// Cargar favoritos del usuario
  Future<void> loadFavorites() async {
    _favoriteRecipeIds = await _dbService.getFavoriteRecipeIds();
    notifyListeners();
  }

  /// Verificar si una receta es favorita
  bool isFavorite(String recipeId) => _favoriteRecipeIds.contains(recipeId);

  /// Alias para compatibilidad - isRecipeFavorite
  bool isRecipeFavorite(String recipeId) => isFavorite(recipeId);

  /// Alias para compatibilidad - toggleRecipeFavorite
  Future<void> toggleRecipeFavorite(String recipeId) async {
    await toggleFavorite(recipeId);
  }

  Future<void> toggleReminderActive(String reminderId, bool newValue) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index].isActive = newValue;
      notifyListeners();
      // Aquí después pondremos la actualización a Supabase
    }
  }
}
