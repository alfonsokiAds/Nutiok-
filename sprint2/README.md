# SPRINT 2 - Implementar (Semanas 8-9)

## Objetivo
Implementar sistema de notas alimentarias y recordatorios con notificaciones push (HU-3, HU-4).

## Historias de Usuario
- **HU-3**: Crear y guardar notas sobre comidas (registro alimentario)
- **HU-4**: Recibir recordatorios de horarios de comida (notificaciones push)

## Actividades XP
- Implementacion de notificaciones push con flutter_local_notifications
- Desarrollo de notes_screen.dart (crear/editar/eliminar notas)
- Conexión de notas y recordatorios a Supabase Database
- Pruebas TDD para recordatorios y notas
- Refactoring del codigo de Sprint 1

## Actividades Scrum
- Daily Scrum cada 3 dias (Discord)
- Encuesta preliminar a 5 estudiantes Ubaté (Google Forms)
- Sprint Review: demo recordatorios + notas
- Retrospectiva de mejora de proceso

## Archivos Creados
### Pantallas
- `lib/screens/sprint2/notes_screen.dart` - Gestion de notas alimentarias
- `lib/screens/sprint2/reminders_screen.dart` - Configuracion de recordatorios

### Servicios
- `lib/services/notification_service.dart` - Notificaciones locales programadas
  - initialize() - Inicializar servicio
  - scheduleReminder() - Programar recordatorio
  - cancelReminder() - Cancelar recordatorio
- `lib/services/database_service.dart` - Operaciones CRUD con Supabase
  - getNotes() / createNote() / updateNote() / deleteNote()
  - getReminders() / createReminder() / updateReminder() / deleteReminder()

### Proveedores
- `lib/providers/notes_provider.dart` - Estado de notas
  - CRUD completo con sincronizacion Supabase
  - Filtrado por tipo de comida
- `lib/providers/reminders_provider.dart` - Estado de recordatorios
  - Programacion y cancelacion de notificaciones
  - Activacion/desactivacion de recordatorios

## Caracteristicas de Seguridad
- Notificaciones programadas con timezone America/Bogota
- Validacion de datos antes de enviar a Supabase
- Cada usuario solo puede acceder a sus propios datos (RLS)
- Eliminacion segura con verificacion de ownership

## Criterios de Aceptacion Cumplidos
- [x] Notas con fecha y hora personalizadas
- [x] Notas guardadas en Supabase
- [x] Notas editables y eliminables
- [x] Notas mostradas en orden cronologico
- [x] Minimo 5 recordatorios configurables
- [x] Notificaciones push en horarios configurados
- [x] Recordatorios activos aun con app cerrada
- [x] Activar/desactivar recordatorios desde configuracion

## Correcciones de Errores (Post-Desarrollo)
- **Duplicidad de Recordatorios Inteligentes:** Se solucionó una condición de carrera *(race condition)* en `RemindersProvider` que ocasionaba la creación duplicada de los recordatorios inteligentes ("Desayuno", "Almuerzo", etc.) al iniciar la aplicación rápidamente. Se implementó un bloqueo de estado (`_isCreatingDefaultReminders`) y una limpieza automática en base de datos al cargar (Supabase).
