# Manual Técnico - NUTIOK

## 1. Introducción
NUTIOK es una aplicación móvil desarrollada en **Flutter** diseñada para ayudar a estudiantes universitarios a gestionar su nutrición en función de sus horarios académicos. El backend está soportado por **Supabase** (PostgreSQL, Auth, Storage).

## 2. Arquitectura del Sistema
El sistema sigue una arquitectura basada en componentes cliente-servidor:
*   **Frontend (Cliente):** Aplicación móvil multiplataforma desarrollada con Flutter y el lenguaje de programación Dart.
*   **Backend as a Service (BaaS):** Supabase se utiliza para la autenticación de usuarios, base de datos relacional y políticas de seguridad a nivel de fila (RLS).
*   **Servicios Externos:** Google Maps API para la visualización de restaurantes cercanos.

## 3. Tecnologías y Dependencias Principales
*   **Framework:** Flutter SDK (>=3.0.0 <4.0.0)
*   **Gestión de Estado:** `provider` (^6.1.5+1)
*   **Autenticación y Base de Datos:** `supabase_flutter` (^2.8.4)
*   **Mapas y Geolocalización:** `google_maps_flutter` (^2.14.2), `geolocator` (^13.0.2)
*   **Notificaciones Locales:** `flutter_local_notifications` (^18.0.1), `timezone` (^0.10.0)
*   **Seguridad y Almacenamiento Local:** `flutter_secure_storage` (^9.2.4), `shared_preferences` (^2.5.3)

## 4. Estructura del Proyecto
El código fuente está organizado principalmente dentro del directorio `lib/`:
*   `/lib/models/`: Clases de datos y modelos (ej. `recipe.dart`, `schedule_class.dart`).
*   `/lib/providers/`: Lógica de negocio y manejo del estado (ej. `reminders_provider.dart`).
*   `/lib/screens/`: Vistas de la aplicación divididas lógicamente (ej. `home_screen.dart`, `map_screen.dart`).
*   `/lib/services/`: Clases dedicadas a la interacción con APIs y Supabase (ej. `database_service.dart`).

## 5. Configuración del Entorno de Desarrollo
Para compilar y ejecutar NUTIOK localmente:
1.  Instalar Flutter SDK.
2.  Clonar el repositorio.
3.  Ejecutar `flutter pub get` para descargar dependencias.
4.  Configurar el archivo `.env` en la raíz del proyecto basándose en `.env.example` con las credenciales de Supabase y Google Maps API.
5.  Ejecutar `flutter run` en un emulador o dispositivo físico.

## 6. Base de Datos y Seguridad (Supabase)
La base de datos PostgreSQL contiene tablas principales como `users`, `schedules`, y `reminders`.
Se han implementado políticas RLS (Row Level Security) para asegurar que un usuario únicamente pueda realizar operaciones CRUD sobre sus propios registros, verificando que el `user_id` coincida con el usuario autenticado.
