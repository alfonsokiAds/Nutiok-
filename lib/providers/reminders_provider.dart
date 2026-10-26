import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/recipe.dart';
import '../models/schedule_class.dart';
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
  List<ScheduleClassModel> _schedule = [];
  List<RecipeModel> _recipes = [];
  List<String> _favoriteRecipeIds = [];
  bool _isLoading = false;
  bool _isCreatingDefaultReminders = false;
  String? _errorMessage;

  List<ReminderModel> get reminders => _reminders;
  List<ReminderModel> get smartReminders => _reminders.where((r) => r.isSmart).toList();
  List<ReminderModel> get manualReminders => _reminders.where((r) => !r.isSmart).toList();
  List<ScheduleClassModel> get schedule => _schedule;
  List<RecipeModel> get recipes => _recipes;
  List<String> get favoriteRecipeIds => _favoriteRecipeIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Alias para compatibilidad con pantallas que usan isLoadingReminders
  bool get isLoadingReminders => _isLoading;

  /// Alias para compatibilidad con pantallas que usan isLoadingRecipes
  bool get isLoadingRecipes => false; // Las recetas se cargan de forma sincrona

  /// Limpiar estado y alarmas al cerrar sesión
  void clear() {
    _reminders = [];
    _schedule = [];
    _favoriteRecipeIds = [];
    _notificationService.cancelAll();
    notifyListeners();
  }

  // =====================
  // RECORDATORIOS (HU-4)
  // =====================

  /// Cargar recordatorios
  /// Cargar recordatorios y verificar si se deben crear los por defecto
  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    _reminders = await _dbService.getReminders();
    _schedule = await _dbService.getSchedule();

    // Si no hay recordatorios inteligentes, creamos los por defecto
    if (!smartReminders.any((r) => r.title == 'Desayuno') && !_isCreatingDefaultReminders) {
      _isCreatingDefaultReminders = true;
      try {
        await _createDefaultSmartReminders();
      } finally {
        _isCreatingDefaultReminders = false;
      }
    }

    // Limpieza automática de duplicados generados por el bug anterior
    final seen = <String>{};
    final duplicates = <String>[];
    for (var r in _reminders) {
      final key = '${r.title}_${r.time}';
      if (seen.contains(key) && r.isSmart) {
        duplicates.add(r.id);
      } else {
        seen.add(key);
      }
    }
    
    for (var id in duplicates) {
      await deleteReminder(id);
    }

    // Sincronizar alarmas del dispositivo con el estado guardado en Supabase
    for (var r in _reminders) {
      if (r.isActive) {
        await _notificationService.scheduleReminder(r);
      } else {
        await _notificationService.cancelReminder(r.id.hashCode);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _createDefaultSmartReminders() async {
    await createReminder(title: 'Desayuno', message: '¡Hora de empezar el día con energía!', time: '07:00', mealType: 'desayuno', isSmart: true);
    await createReminder(title: 'Almuerzo', message: '¡Momento de recargar energías!', time: '13:00', mealType: 'almuerzo', isSmart: true);
    await createReminder(title: 'Merienda', message: 'Un pequeño snack para continuar.', time: '16:00', mealType: 'snack', isSmart: true);
    await createReminder(title: 'Cena', message: 'Termina el día con una buena cena.', time: '19:30', mealType: 'cena', isSmart: true);
    _reminders = await _dbService.getReminders();
  }

  /// Analiza los huecos en el horario y sugiere recordatorios de descanso o hidratación
  Future<void> analyzeScheduleAndSuggestReminders() async {
    // 1. Agrupar clases por día
    Map<int, List<ScheduleClassModel>> classesByDay = {};
    for (var c in _schedule) {
      if (!classesByDay.containsKey(c.dayOfWeek)) {
        classesByDay[c.dayOfWeek] = [];
      }
      classesByDay[c.dayOfWeek]!.add(c);
    }

    // 2. Por cada día, ordenar las clases y buscar huecos mayores a 1 hora
    for (var entry in classesByDay.entries) {
      // var day = entry.key;
      var classes = entry.value;
      classes.sort((a, b) => a.startTime.compareTo(b.startTime));

      for (int i = 0; i < classes.length - 1; i++) {
        var class1 = classes[i];
        var class2 = classes[i + 1];

        // Lógica simple para parsear la hora "HH:mm" y calcular diferencia en minutos
        var endParts = class1.endTime.split(':');
        var startParts2 = class2.startTime.split(':');
        
        int endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        int startMinutes2 = int.parse(startParts2[0]) * 60 + int.parse(startParts2[1]);
        
        int gap = startMinutes2 - endMinutes;

        // Si hay un hueco de al menos 90 minutos, sugerimos un descanso o snack
        if (gap >= 90) {
          int suggestionMinutes = endMinutes + 30; // 30 minutos después de clase
          String suggestionTime = '${(suggestionMinutes ~/ 60).toString().padLeft(2, '0')}:${(suggestionMinutes % 60).toString().padLeft(2, '0')}';
          
          // Verificar si ya existe un recordatorio en esa hora para ese día
          bool exists = _reminders.any((r) => r.time == suggestionTime && r.isSmart && r.title.contains('Descanso'));
          if (!exists) {
            await createReminder(
              title: 'Descanso / Hidratación',
              message: 'Tienes un hueco libre, ¡Aprovecha para descansar y tomar agua!',
              time: suggestionTime,
              mealType: 'snack',
              isSmart: true,
            );
          }
        }
      }
    }
    
    _reminders = await _dbService.getReminders();
    notifyListeners();
  }

  /// Crear clase en el horario
  Future<void> addScheduleClass(ScheduleClassModel newClass) async {
    final userId = _dbService.supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Debe iniciar sesión para guardar el horario';
      notifyListeners();
      return;
    }

    final classWithUser = ScheduleClassModel(
      id: newClass.id,
      userId: userId,
      className: newClass.className,
      dayOfWeek: newClass.dayOfWeek,
      startTime: newClass.startTime,
      endTime: newClass.endTime,
    );

    final result = await _dbService.addScheduleClass(classWithUser);
    if (result.scheduleClass != null) {
      _schedule.add(result.scheduleClass!);
      notifyListeners();
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }
  }

  /// Eliminar clase del horario
  Future<void> deleteScheduleClass(String id) async {
    final result = await _dbService.deleteScheduleClass(id);
    if (result.success) {
      _schedule.removeWhere((c) => c.id == id);
      notifyListeners();
    }
  }

  /// Crear recordatorio
  Future<bool> createReminder({
    required String title,
    required String message,
    required String time,
    required String mealType,
    bool repeatDaily = true,
    DateTime? reminderDate,
    bool isAllDay = false,
    bool isSmart = false,
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
      isSmart: isSmart,
      repeatDaily: repeatDaily,
      reminderDate: reminderDate,
      isAllDay: isAllDay,
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
      if (reminder.isActive) {
        await _notificationService.scheduleReminder(reminder);
      } else {
        await _notificationService.cancelReminder(reminder.id.hashCode);
      }
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
    await updateReminder(updated);
  }

  // =====================
  // RECETAS (HU-5)
  // =====================

  /// Cargar recetas desde datos locales y de Supabase
  Future<void> loadRecipes() async {
    // 1. Cargar recetas predeterminadas
    final defaultList = RecipeData.defaultRecipes
        .map((json) => RecipeModel.fromJson(json))
        .toList();

    // 2. Cargar recetas comunitarias/creadas desde Supabase
    final dbList = await _dbService.getRecipes();

    final existingIds = defaultList.map((r) => r.id).toSet();
    final combined = List<RecipeModel>.from(defaultList);
    for (var r in dbList) {
      if (!existingIds.contains(r.id)) {
        combined.insert(0, r); // Las de estudiantes primero
      }
    }

    _recipes = combined;
    notifyListeners();
  }

  /// Agregar una receta creada por un estudiante
  Future<bool> addStudentRecipe({
    required String name,
    required String description,
    required String category,
    required String difficulty,
    required int preparationTime,
    required List<String> ingredients,
    required List<String> steps,
    String? imageUrl,
  }) async {
    final newRecipe = RecipeModel(
      id: '',
      name: name,
      description: description,
      category: category.toLowerCase(),
      difficulty: difficulty.toLowerCase(),
      preparationTime: preparationTime,
      servings: 1,
      ingredients: ingredients,
      steps: steps,
      imageUrl: imageUrl ??
          'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500',
    );

    final result = await _dbService.createRecipe(newRecipe);
    if (result.recipe != null) {
      _recipes.insert(0, result.recipe!);
      notifyListeners();
      return true;
    } else {
      // Fallback local con ID temporal para disponibilidad inmediata
      final localRecipe = RecipeModel(
        id: 'student_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        category: category.toLowerCase(),
        difficulty: difficulty.toLowerCase(),
        preparationTime: preparationTime,
        servings: 1,
        ingredients: ingredients,
        steps: steps,
        imageUrl: imageUrl ??
            'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500',
      );
      _recipes.insert(0, localRecipe);
      notifyListeners();
      return true;
    }
  }

  /// Filtrar recetas por categoria
  List<RecipeModel> getRecipesByCategory(String category) {
    if (category.toLowerCase() == 'todas') return _recipes;
    return _recipes
        .where((r) => r.category.toLowerCase() == category.toLowerCase())
        .toList();
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
      final updated = _reminders[index].copyWith(isActive: newValue);
      _reminders[index] = updated;
      notifyListeners(); // Respuesta visual inmediata
      await updateReminder(updated);
    }
  }

  /// Activa o desactiva todos los recordatorios inteligentes en bloque
  Future<void> toggleAllSmartReminders(bool newValue) async {
    for (int i = 0; i < _reminders.length; i++) {
      if (_reminders[i].isSmart) {
        _reminders[i] = _reminders[i].copyWith(isActive: newValue);
      }
    }
    notifyListeners(); // Actualización inmediata de toda la interfaz

    // Persistir y actualizar notificaciones
    for (var r in _reminders.where((r) => r.isSmart)) {
      if (!newValue) {
        await _notificationService.cancelReminder(r.id.hashCode);
      } else {
        await _notificationService.scheduleReminder(r);
      }
      await _dbService.updateReminder(r);
    }
  }
}
