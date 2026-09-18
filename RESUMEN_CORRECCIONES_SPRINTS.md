# Resumen de Correcciones de Errores (Post-Desarrollo)

A continuación se documentan los problemas principales que se presentaron durante las fases de pruebas (testing) y cómo fueron solucionados en el código. Estos cambios afectan a características desarrolladas previamente en los respectivos Sprints.

## Sprint 2: Alertas y Recordatorios Inteligentes
**Problema:** La aplicación estaba creando duplicados de los "Recordatorios Inteligentes" (Desayuno, Almuerzo, Merienda, Cena).  
**Causa:** Una condición de carrera (*race condition*) en `RemindersProvider.loadReminders`. Al cambiar entre pantallas o iniciar la app, la función se invocaba múltiples veces de manera asíncrona. Si la primera invocación no terminaba de registrar los recordatorios por defecto en la base de datos, las subsecuentes consideraban que la lista seguía vacía y los volvían a crear.  
**Solución:**
- Se agregó una bandera booleana (`_isCreatingDefaultReminders`) como *lock* de estado para prevenir que múltiples procesos asíncronos ingresen al bloque de creación simultáneamente.
- Se añadió una subrutina de limpieza automática durante la carga que identifica la combinación de "Título + Hora" duplicada y la elimina de Supabase, limpiando la experiencia del usuario sin requerir acciones manuales.

## Sprint 4: Horario Universitario y Predicción de Huecos
**Problema:** Al agregar una nueva materia desde la vista del Horario Universitario, la materia no se guardaba y desaparecía al recargar, impidiendo la funcionalidad de predicción de huecos.  
**Causa:** El formulario de creación construía el objeto `ScheduleClassModel` enviando el campo `userId` en blanco (`''`). La política de seguridad a nivel de fila (RLS) en Supabase bloqueaba la inserción de datos cuyo `user_id` estuviera vacío o no correspondiera al usuario logueado. Como el provider no exponía el error devuelto por `DatabaseService`, el error era silencioso.  
**Solución:**
- Se modificó `RemindersProvider.addScheduleClass` para extraer primero de forma segura el ID del usuario activo (`_dbService.supabase.auth.currentUser?.id`).
- El provider ahora inyecta automáticamente este ID correcto en una copia del `ScheduleClassModel` justo antes de delegar la inserción al `DatabaseService`.

## Mejoras Generales de Estabilidad (Global)
**Problema:** La aplicación presentaba una "Pantalla Blanca" infinita en el arranque bajo ciertas condiciones (emulador sin red o lentitud en la inicialización de librerías).  
**Causa:** El hilo principal de ejecución se quedaba esperando indefinidamente (`await Supabase.initialize(...)`) si el endpoint era inalcanzable, bloqueando que el `MainApp` se renderizara.  
**Solución:**
- Se envolvió la inicialización principal en `main.dart` con un bloque `try-catch`.
- Se introdujo un `timeout` controlado para asegurar que, si la base de datos falla al responder en tiempo prudencial, el flujo de la aplicación se destrabe en lugar de dejar al usuario atrapado en el Splash Screen.
