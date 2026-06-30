# SPRINT 1 - Diseñar (Semanas 6-7)

## Objetivo
Implementar autenticacion de usuarios y pantalla principal (HU-1, HU-2).

## Historias de Usuario
- **HU-1**: Registro e inicio de sesion con correo y contrasena
- **HU-2**: Pantalla de inicio con recomendaciones y horarios

## Actividades XP
- TDD para login y autenticacion con Supabase Auth
- Programacion en parejas para home_screen
- Diseno simple: solo lo necesario para HU-1 y HU-2
- Integracion continua en GitHub tras cada historia completada

## Actividades Scrum
- Daily Scrum cada 3 dias (Discord)
- Sprint Review: demo login funcional
- Sprint Retrospective: lecciones de la primera iteracion

## Archivos Creados
### Pantallas
- `lib/screens/sprint1/welcome_screen.dart` - Pantalla de bienvenida
- `lib/screens/sprint1/register_screen.dart` - Formulario de registro
- `lib/screens/sprint1/home_screen.dart` - Pantalla principal
- `lib/screens/sprint1/change_password_screen.dart` - Cambio de contrasena

### Servicios
- `lib/services/auth_service.dart` - Autenticacion con Supabase Auth
  - signUp() - Registro con validacion
  - signIn() - Inicio de sesion
  - signOut() - Cerrar sesion
  - resetPassword() - Recuperar contrasena
  - updatePassword() - Cambiar contrasena

### Proveedores
- `lib/providers/auth_provider.dart` - Estado de autenticacion
  - Gestion de sesion
  - Validacion de formularios
  - Mensajes de error

## Correcciones Aplicadas
1. Se migro completamente de Firebase a Supabase
2. Se agrego autenticacion real (antes era solo UI estatica)
3. Se implemento validacion de formularios (correo, contrasena)
4. Se agrego almacenamiento seguro de credenciales
5. Se corrigio la inconsistencia Firebase/Supabase mencionada en el documento

## Criterios de Aceptacion Cumplidos
- [x] Correo validado por formato (usuario@dominio.com)
- [x] Contrasena minimo 8 caracteres
- [x] Datos almacenados en Supabase
- [x] Mensaje de confirmacion/registro exitoso
- [x] Error si correo ya existe
- [x] Sesion se mantiene activa
- [x] Recomendaciones del dia visibles en home
- [x] Horarios de comida configurables
