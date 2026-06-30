import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_service.dart';

/// Provider para gestionar notas alimentarias
/// Sprint 2 - HU-3
class NotesProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Cargar todas las notas del usuario
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await _dbService.getNotes();

    _isLoading = false;
    notifyListeners();
  }

  /// Crear nueva nota
  Future<bool> createNote({
    required String title,
    required String content,
    String? mealType,
    required DateTime mealDate,
  }) async {
    final userId = _dbService.supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Debe iniciar sesion primero';
      notifyListeners();
      return false;
    }

    final note = NoteModel(
      id: '', // Se genera en Supabase
      userId: userId,
      title: title,
      content: content,
      mealType: mealType,
      mealDate: mealDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _dbService.createNote(note);

    if (result.error != null) {
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }

    if (result.note != null) {
      _notes.insert(0, result.note!);
    }

    notifyListeners();
    return true;
  }

  /// Actualizar nota existente
  Future<bool> updateNote(NoteModel note) async {
    final result = await _dbService.updateNote(note);

    if (result.success) {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
      }
      notifyListeners();
      return true;
    }

    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Eliminar nota
  Future<bool> deleteNote(String noteId) async {
    final result = await _dbService.deleteNote(noteId);

    if (result.success) {
      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();
      return true;
    }

    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Filtrar notas por tipo de comida
  List<NoteModel> getNotesByMealType(String mealType) {
    return _notes.where((n) => n.mealType == mealType).toList();
  }
}
