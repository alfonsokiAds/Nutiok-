import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/supabase_config.dart';

/// Servicio de autenticacion con Supabase
/// Sprint 1 - HU-1 y HU-2: Registro e inicio de sesion
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Registrar nuevo usuario con correo y contrasena
  /// Retorna el usuario o un mensaje de error
  Future<({User? user, String? error})> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Validar formato de correo
      if (!_isValidEmail(email)) {
        return (user: null, error: 'El formato del correo no es valido');
      }

      // Validar contrasena
      if (!_isValidPassword(password)) {
        return (user: null, error: 'La contrasena debe tener al menos 8 caracteres, incluir mayúsculas, números y símbolos');
      }

      // Registrar en Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      // Si identities está vacío, significa que el usuario ya existe (por privacidad Supabase devuelve éxito falso)
      if (response.user != null && (response.user!.identities == null || response.user!.identities!.isEmpty)) {
        return (user: null, error: 'Este correo electrónico ya está registrado en el sistema.');
      }

      // Crear perfil en la tabla profiles
      if (response.user != null) {
        try {
          await _supabase.from(SupabaseConfig.profilesTable).upsert({
            'id': response.user!.id,
            'email': email,
            'full_name': fullName,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Nota: Error al insertar perfil (posible trigger): $e');
        }
      }

      return (user: response.user, error: null);
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        return (user: null, error: 'Este correo electrónico ya está registrado.');
      }
      return (user: null, error: 'Error de registro: ${e.message}');
    } catch (e) {
      return (user: null, error: 'Error inesperado al registrarse: $e');
    }
  }

  /// Iniciar sesion con correo y contrasena
  Future<({User? user, String? error})> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Guardar sesion de forma segura
      if (response.user != null) {
        await _secureStorage.write(key: 'user_id', value: response.user!.id);
        await _secureStorage.write(key: 'user_email', value: response.user!.email);
      }

      return (user: response.user, error: null);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        return (user: null, error: 'Correo o contraseña incorrectos.');
      }
      return (user: null, error: 'Error al iniciar sesión: ${e.message}');
    } catch (e) {
      return (user: null, error: 'Error inesperado al iniciar sesión.');
    }
  }

  /// Cerrar sesion
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _secureStorage.delete(key: 'user_id');
    await _secureStorage.delete(key: 'user_email');
  }

  /// Recuperar contrasena (enviar email de reset)
  Future<({bool success, String? error})> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return (success: true, error: null);
    } on AuthException catch (e) {
      return (success: false, error: 'Error al enviar correo de recuperacion: ${e.message}');
    } catch (e) {
      return (success: false, error: 'Error inesperado');
    }
  }

  /// Cambiar contrasena del usuario actual
  Future<({bool success, String? error})> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        return (success: false, error: 'Las contrasenas no coinciden');
      }

      if (!_isValidPassword(newPassword)) {
        return (success: false, error: 'La contrasena debe tener al menos 8 caracteres, incluir mayúsculas, números y símbolos');
      }

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return (success: true, error: null);
    } catch (e) {
      print('Error real al cambiar la contraseña: $e');
      return (success: false, error: 'Error: $e');
    }
  }

  /// Obtener perfil del usuario actual
  Future<UserModel?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error al obtener perfil de tabla, usando metadata: $e');
      // Fallback a los datos de auth si la tabla profiles falla o no tiene el registro
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Actualizar perfil del usuario
  Future<({bool success, String? error})> updateProfile(UserModel profile) async {
    try {
      await _supabase
          .from(SupabaseConfig.profilesTable)
          .update(profile.toJson())
          .eq('id', profile.id);
      return (success: true, error: null);
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return (success: false, error: 'Error al actualizar el perfil: $e');
    }
  }

  /// Verificar si hay sesion activa
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Obtener ID del usuario actual
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Obtener email del usuario actual
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  // Validaciones de seguridad
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // Al menos 8 caracteres, 1 mayúscula, 1 minúscula, 1 número y 1 carácter especial
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
    return regex.hasMatch(password);
  }
}
