import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utilidades de seguridad para NUTIOK
/// Implementa las normas de seguridad recomendadas para aplicaciones moviles
class SecurityUtils {
  // ==================
  // VALIDACIONES
  // ==================

  /// Validar formato de correo electronico
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Validar fortaleza de contrasena
  /// Minimo 8 caracteres, al menos una mayuscula y un numero
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  /// Validar contrasena basica (minimo 8 caracteres)
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  /// Validar que las contrasenas coincidan
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  /// Validar nombre (solo letras y espacios, minimo 2 caracteres)
  static bool isValidName(String name) {
    if (name.trim().length < 2) return false;
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$');
    return regex.hasMatch(name);
  }

  /// Validar peso (kg) - rango realista
  static bool isValidWeight(double weight) {
    return weight >= 20.0 && weight <= 300.0;
  }

  /// Validar altura (cm) - rango realista
  static bool isValidHeight(double height) {
    return height >= 50.0 && height <= 250.0;
  }

  /// Validar edad
  static bool isValidAge(int age) {
    return age >= 10 && age <= 120;
  }

  // ==================
  // SANITIZACION
  // ==================

  /// Sanitizar texto para prevenir inyeccion
  /// Elimina caracteres especiales y HTML
  static String sanitizeText(String input) {
    // Eliminar etiquetas HTML basicas
    String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');
    // Eliminar scripts
    sanitized = sanitized.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    // Limitar longitud
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }
    return sanitized.trim();
  }

  /// Sanitizar entrada de texto para formularios
  static String sanitizeInput(String input, {int maxLength = 200}) {
    String sanitized = input.trim();
    // Eliminar caracteres de control
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    // Limitar longitud
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }

  // ==================
  // CIFRADO
  // ==================

  /// Generar hash SHA-256 de un texto
  /// Util para almacenar datos sensibles de forma cifrada
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Generar token aleatorio seguro
  static String generateSecureToken({int length = 32}) {
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = generateHash(random);
    return hash.substring(0, length);
  }

  // ==================
  // POLITICAS DE SEGURIDAD
  // ==================

  /// Reglas de contrasena como mensajes legibles
  static List<String> getPasswordRequirements() {
    return [
      'Minimo 8 caracteres',
      'Al menos una letra mayuscula',
      'Al menos un numero',
      'No usar caracteres especiales excesivos',
    ];
  }

  /// Obtener mensaje de error de validacion
  static String? getValidationError({
    String? email,
    String? password,
    String? name,
  }) {
    if (email != null && !isValidEmail(email)) {
      return 'El formato del correo no es valido';
    }
    if (password != null && !isValidPassword(password)) {
      return 'La contrasena debe tener minimo 8 caracteres';
    }
    if (password != null && !isStrongPassword(password)) {
      return 'La contrasena debe incluir al menos una mayuscula y un numero';
    }
    if (name != null && !isValidName(name)) {
      return 'El nombre solo debe contener letras y espacios';
    }
    return null;
  }
}
