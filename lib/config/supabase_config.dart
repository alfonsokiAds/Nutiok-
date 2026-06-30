import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuracion de Supabase para NUTIOK
///
/// IMPORTANTE: Para usar esta aplicacion, configure las credenciales
/// de su proyecto Supabase en este archivo.
///
/// Pasos:
/// 1. Cree un proyecto en https://supabase.com
/// 2. Copie la URL y la API Key (anon public)
/// 3. Reemplace los valores abajo

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Nombre del proyecto
  static const String projectName = 'NUTIOK';

  /// Tablas de la base de datos
  static const String profilesTable = 'profiles';
  static const String notesTable = 'notes';
  static const String remindersTable = 'reminders';
  static const String recipesTable = 'recipes';
  static const String favoritesTable = 'favorites';

  /// Bucket de almacenamiento
  static const String avatarBucket = 'avatars';
}
