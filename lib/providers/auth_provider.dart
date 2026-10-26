import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider para gestionar el estado de autenticacion
/// Sprint 1 - HU-1 y HU-2
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  UserModel? _currentUser;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;

  /// Alias para compatibilidad con pantallas que usan authProvider.user
  UserModel? get user => _currentUser;

  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        if (data.session != null) {
          _isAuthenticated = true;
          _currentUser = await _authService.getCurrentProfile();
          notifyListeners();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// Verificar sesion al iniciar la app
  Future<void> checkAuth() async {
    debugPrint('[AUTH] 🔍 Iniciando verificación de autenticación...');
    _isLoading = true;
    notifyListeners();

    if (_authService.isAuthenticated) {
      debugPrint('[AUTH] ✅ Usuario autenticado detectado');
      _isAuthenticated = true;
      _currentUser = await _authService.getCurrentProfile();
      debugPrint('[AUTH] 👤 Perfil de usuario obtenido: ${_currentUser?.email}');
    } else {
      debugPrint('[AUTH] ❌ No hay usuario autenticado');
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('[AUTH] ✨ Verificación completada');
  }

  /// Alias para compatibilidad - register(nombre) -> signUp(fullName)
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await signUp(
      email: email,
      password: password,
      fullName: name,
    );
  }

  /// Registrar nuevo usuario
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    _isLoading = false;

    if (result.error != null) {
      _errorMessage = result.error!;
      notifyListeners();
      return false;
    }

    _isAuthenticated = true;
    _currentUser = await _authService.getCurrentProfile();
    notifyListeners();
    return true;
  }

  /// Iniciar sesion
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signIn(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result.error != null) {
      _errorMessage = result.error!;
      notifyListeners();
      return false;
    }

    _isAuthenticated = true;
    _currentUser = await _authService.getCurrentProfile();
    notifyListeners();
    return true;
  }

  /// Cerrar sesion
  Future<void> signOut() async {
    await _authService.signOut();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  /// Recuperar contrasena
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.resetPassword(email: email);

    _isLoading = false;

    if (result.error != null) {
      _errorMessage = result.error!;
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Verificar codigo OTP de recuperacion y actualizar contrasena
  Future<bool> verifyRecoveryOtpAndSetNewPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.verifyRecoveryOtpAndSetNewPassword(
      email: email,
      token: token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    _isLoading = false;

    if (result.error != null) {
      _errorMessage = result.error!;
      notifyListeners();
      return false;
    }

    _isAuthenticated = true;
    _currentUser = await _authService.getCurrentProfile();
    notifyListeners();
    return true;
  }

  /// Cambiar contrasena
  Future<bool> changePassword({
    required String newPassword,
    String? confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.updatePassword(
      newPassword: newPassword,
      confirmPassword: confirmPassword ?? newPassword,
    );

    _isLoading = false;

    if (result.error != null) {
      _errorMessage = result.error!;
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Actualizar perfil
  Future<bool> updateProfile(UserModel profile) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.updateProfile(profile);

    _isLoading = false;

    if (result.success) {
      _currentUser = profile;
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
