# SPRINT 0 - Concebir (Semanas 1-5)

## Objetivo
Configuracion inicial del proyecto, definicion de requisitos y planificacion.

## Actividades Realizadas

### Metodologia
- Revision y correccion de metodologia (CDIO a XP + Scrum)
- Redaccion formal de HU-1 a HU-6 y HU-8 con criterios de aceptacion Scrum
- Estimacion de story points y priorizacion del Product Backlog

### Documentacion
- Correccion marco teorico, objetivo 3 y referencias APA 7
- Actualizacion del cronograma por sprints

### Configuracion Tecnica
- Diseno simple de arquitectura con Supabase (3 capas)
- Configuracion entorno Flutter + Supabase + GitHub
- Diseno de mockups finales

## Archivos Creados
- `pubspec.yaml` - Configuracion de dependencias del proyecto
- `lib/config/supabase_config.dart` - Configuracion de conexion a Supabase
- `lib/app_theme.dart` - Tema visual y colores corporativos
- `lib/models/` - Modelos de datos (User, Note, Reminder, Recipe)
- `lib/services/` - Servicios base (Auth, Database, Notifications)
- `lib/providers/` - Proveedores de estado (Provider pattern)
- `lib/widgets/` - Widgets reutilizables (BottomNavBar, NutiokCard, NutiokButton)
- `lib/utils/security_utils.dart` - Utilidades de seguridad
- `supabase_schema.sql` - Esquema de base de datos

## Dependencias Clave
- `supabase_flutter: ^2.8.4` - Backend y autenticacion
- `flutter_local_notifications: ^18.0.1` - Notificaciones push
- `flutter_secure_storage: ^9.2.4` - Almacenamiento seguro
- `provider: ^6.1.5+1` - Gestion de estado
- `google_maps_flutter: ^2.9.0` - Mapa de restaurantes

## Decisiones de Diseno
- Arquitectura de 3 capas: Presentacion (Flutter), Logica (Providers), Datos (Supabase)
- Base de datos relacional con PostgreSQL via Supabase
- Autenticacion segura con Supabase Auth
- Almacenamiento seguro con flutter_secure_storage
- Notificaciones locales programadas con timezone Colombia
