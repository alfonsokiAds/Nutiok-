import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';
import '../models/reminder.dart';
import '../models/recipe.dart';
import '../models/schedule_class.dart';
import '../config/supabase_config.dart';

/// Servicio de base de datos con Supabase
/// Maneja todas las operaciones CRUD para notas, recordatorios, etc.
class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Getter publico para acceder al cliente de Supabase
  /// Usado por providers para verificar la sesion del usuario
  SupabaseClient get supabase => _supabase;

  /// =====================
  /// NOTAS (HU-3)
  /// =====================

  /// Obtener todas las notas del usuario
  Future<List<NoteModel>> getNotes({String? sortBy}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _supabase
        .from(SupabaseConfig.notesTable)
        .select()
        .eq('user_id', userId)
        .order(sortBy ?? 'meal_date', ascending: false);

    final response = await query;
    return response.map<NoteModel>((json) => NoteModel.fromJson(json)).toList();
  }

  /// Crear una nueva nota
  Future<({NoteModel? note, String? error})> createNote(NoteModel note) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.notesTable)
          .insert(note.toJson())
          .select()
          .single();

      return (note: NoteModel.fromJson(response), error: null);
    } catch (e) {
      debugPrint('Error en createNote: $e');
      return (note: null, error: 'Error al crear la nota');
    }
  }

  /// Actualizar una nota existente
  Future<({bool success, String? error})> updateNote(NoteModel note) async {
    try {
      await _supabase
          .from(SupabaseConfig.notesTable)
          .update(note.toJson())
          .eq('id', note.id);
      return (success: true, error: null);
    } catch (e) {
      debugPrint('Error en updateNote: $e');
      return (success: false, error: 'Error al actualizar la nota');
    }
  }

  /// Eliminar una nota
  Future<({bool success, String? error})> deleteNote(String noteId) async {
    try {
      // Verificar que la nota pertenece al usuario actual
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return (success: false, error: 'Usuario no autenticado');
      }

      await _supabase
          .from(SupabaseConfig.notesTable)
          .delete()
          .eq('id', noteId)
          .eq('user_id', userId);

      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: 'Error al eliminar la nota');
    }
  }

  /// =====================
  /// RECORDATORIOS (HU-4)
  /// =====================

  /// Obtener todos los recordatorios del usuario
  Future<List<ReminderModel>> getReminders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from(SupabaseConfig.remindersTable)
          .select()
          .eq('user_id', userId)
          .order('time', ascending: true);

      return response
          .map<ReminderModel>((json) => ReminderModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error en getReminders: $e');
      return [];
    }
  }

  /// Crear un nuevo recordatorio
  Future<({ReminderModel? reminder, String? error})> createReminder(
      ReminderModel reminder) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.remindersTable)
          .insert(reminder.toJson())
          .select()
          .single();

      return (reminder: ReminderModel.fromJson(response), error: null);
    } catch (e) {
      debugPrint('Error en createReminder: $e');
      return (reminder: null, error: 'Error al crear el recordatorio');
    }
  }

  /// Actualizar un recordatorio
  Future<({bool success, String? error})> updateReminder(
      ReminderModel reminder) async {
    try {
      await _supabase
          .from(SupabaseConfig.remindersTable)
          .update(reminder.toJson())
          .eq('id', reminder.id);
      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: 'Error al actualizar el recordatorio');
    }
  }

  /// Eliminar un recordatorio
  Future<({bool success, String? error})> deleteReminder(
      String reminderId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return (success: false, error: 'Usuario no autenticado');
      }

      await _supabase
          .from(SupabaseConfig.remindersTable)
          .delete()
          .eq('id', reminderId)
          .eq('user_id', userId);

      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: 'Error al eliminar el recordatorio');
    }
  }

  /// =====================
  /// RECETAS (HU-5)
  /// =====================

  /// Obtener recetas
  Future<List<RecipeModel>> getRecipes({String? query, String? category}) async {
    try {
      var dbQuery = _supabase.from(SupabaseConfig.recipesTable).select();
      
      if (category != null && category.isNotEmpty && category != 'Todas') {
        dbQuery = dbQuery.eq('category', category.toLowerCase());
      }
      
      if (query != null && query.isNotEmpty) {
        dbQuery = dbQuery.ilike('name', '%$query%');
      }

      final response = await dbQuery;
      return response
          .map<RecipeModel>((json) => RecipeModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error en getRecipes: $e');
      return [];
    }
  }

  /// Crear una nueva receta (creada por un estudiante)
  Future<({RecipeModel? recipe, String? error})> createRecipe(
      RecipeModel recipe) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.recipesTable)
          .insert(recipe.toJson())
          .select()
          .single();
      return (recipe: RecipeModel.fromJson(response), error: null);
    } catch (e) {
      debugPrint('Error en createRecipe: $e');
      return (recipe: null, error: 'Error al guardar la receta: $e');
    }
  }

  /// =====================
  /// FAVORITOS (HU-5)
  /// =====================

  /// Obtener lista de recetas favoritas del usuario
  Future<List<String>> getFavoriteRecipeIds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from(SupabaseConfig.favoritesTable)
        .select('recipe_id')
        .eq('user_id', userId);

    return response.map<String>((json) => json['recipe_id'] as String).toList();
  }

  /// Agregar receta a favoritos
  Future<bool> toggleFavorite(String recipeId, bool isFavorite) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      if (isFavorite) {
        await _supabase.from(SupabaseConfig.favoritesTable).insert({
          'user_id': userId,
          'recipe_id': recipeId,
        });
      } else {
        await _supabase
            .from(SupabaseConfig.favoritesTable)
            .delete()
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// =====================
  /// HORARIOS (HU-4 / Sprint 4)
  /// =====================

  /// Obtener horario del estudiante
  Future<List<ScheduleClassModel>> getSchedule() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from(SupabaseConfig.schedulesTable)
          .select()
          .eq('user_id', userId)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      return response
          .map<ScheduleClassModel>((json) => ScheduleClassModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error en getSchedule: $e');
      return [];
    }
  }

  /// Agregar clase al horario
  Future<({ScheduleClassModel? scheduleClass, String? error})> addScheduleClass(
      ScheduleClassModel scheduleClass) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.schedulesTable)
          .insert(scheduleClass.toJson())
          .select()
          .single();

      return (
        scheduleClass: ScheduleClassModel.fromJson(response),
        error: null
      );
    } catch (e) {
      debugPrint('Error en addScheduleClass: $e');
      return (scheduleClass: null, error: 'Error al agregar la clase');
    }
  }

  /// Eliminar clase del horario
  Future<({bool success, String? error})> deleteScheduleClass(
      String classId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return (success: false, error: 'Usuario no autenticado');
      }

      await _supabase
          .from(SupabaseConfig.schedulesTable)
          .delete()
          .eq('id', classId)
          .eq('user_id', userId);

      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: 'Error al eliminar la clase');
    }
  }
}
