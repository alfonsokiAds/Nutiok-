# SPRINT 3 - Implementar Funcionalidades Avanzadas (Semanas 10-11)

## Objetivo
Desarrollar recetas saludables, perfil nutricional con calculo de IMC y onboarding.

## Historias de Usuario
- **HU-5**: Consultar recetas saludables
- **HU-8**: Personalizar perfil con datos nutricionales y metas de alimentacion

## Actividades XP
- Desarrollo de recipe_search_screen.dart con recetas categorizadas
- Desarrollo de profile_screen.dart con calculo automatico de IMC (peso/altura²)
- Desarrollo de welcome_onboarding_screen.dart (onboarding 3 pasos)
- Recetas JSON local para funcionamiento sin conexion
- Integracion continua: cada pantalla se integra al repo tras pruebas TDD

## Actividades Scrum
- Daily Scrum cada 3 dias (Discord)
- Encuesta formal a 10 estudiantes Ubaté + analisis de resultados
- Sprint Review: demo perfil + recetas + validacion con usuarios
- Actualizacion del Product Backlog

## Archivos Creados
### Pantallas
- `lib/screens/sprint2/recipe_search_screen.dart` - Busqueda de recetas
- `lib/screens/sprint2/recipe_detail_screen.dart` - Detalle de receta
- `lib/screens/sprint3/profile_screen.dart` - Perfil nutricional
- `lib/screens/sprint3/welcome_onboarding_screen.dart` - Onboarding

### Datos
- `lib/models/recipe_data.dart` - 10 recetas precargadas en espanol
- `lib/models/recipe.dart` - Modelo de receta con info nutricional

## Caracteristicas Implementadas
### Recetas
- 10 recetas precargadas (desayuno, almuerzo, cena, snack)
- Busqueda por nombre y categoria
- Detalle con ingredientes, pasos, info nutricional
- Sistema de favoritos
- Dificultad y tiempo de preparacion

### Perfil Nutricional
- Registro de peso, altura, edad, genero
- Calculo automatico de IMC
- Indicador visual de categoria de IMC
- Metas alimentarias configurables
- Configuracion de privacidad y accesibilidad

### Onboarding
- 3 pantallas explicativas con animaciones
- Indicador de progreso con puntos
- Guardado de estado en SharedPreferences
- Salto rapido disponible

## Criterios de Aceptacion Cumplidos
- [x] Recetas categorizadas (desayuno, almuerzo, cena, snack)
- [x] Cada receta con nombre, ingredientes y preparacion
- [x] Busqueda por tipo de comida o dificultad
- [x] Marcado de recetas favoritas
- [x] Datos basicos del perfil (nombre, edad, peso, altura)
- [x] Resumen del perfil con datos registrados
- [x] Edicion y actualizacion de perfil en cualquier momento
