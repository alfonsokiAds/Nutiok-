# 🛡️ Registro de Actualizaciones de Seguridad (Nutiok)

Este documento detalla las mejoras de seguridad implementadas en la arquitectura y el código de la aplicación.

## Sprint 1: Hardening de Base de Datos (Supabase)
**Fecha:** 14 de Septiembre de 2026
**Objetivo:** Proteger los datos sensibles de los usuarios y evitar el acceso no autorizado a través de la API.

**Cambios implementados:**
1. **Activación de RLS (Row Level Security):** Se aplicaron políticas RLS en todas las tablas (`profiles`, `notes`, `reminders`, `recipes`, `favorites`) para garantizar que un usuario autenticado **solo pueda acceder, leer y modificar sus propios datos**.
2. **Restricción de acceso a funciones SQL:** Se actualizó la función `handle_new_user()` (encargada de crear el perfil automáticamente) para revocar permisos de ejecución pública (`REVOKE EXECUTE FROM PUBLIC`). Esto evita que usuarios malintencionados llamen a la función directamente desde la API.
3. **Restricción de longitud de contraseña en Backend:** Se actualizó la política de contraseñas de Supabase para requerir un mínimo de 8 caracteres a nivel de servidor.

## Sprint 2: Validación Fuerte de Contraseñas (Frontend)
**Fecha:** 14 de Septiembre de 2026
**Archivo Modificado:** `lib/services/auth_service.dart`

**Cambios implementados:**
1. **Validación estricta con RegEx:** Se reemplazó la validación básica de contraseñas por una Expresión Regular (`RegExp`) de grado industrial que exige:
   - Mínimo 8 caracteres de longitud.
   - Al menos una letra mayúscula (A-Z).
   - Al menos una letra minúscula (a-z).
   - Al menos un número (0-9).
   - Al menos un carácter especial (ej. @, #, !, ?, _, -).
2. **Feedback al usuario:** Se actualizaron los mensajes de error en los métodos `signUp` y `updatePassword` para indicarle claramente al usuario los nuevos requisitos si su contraseña es rechazada antes de hacer la petición al servidor.

---

*Nota: Estos cambios preparan la aplicación para cumplir con estándares básicos de seguridad OWASP para aplicaciones móviles.*
