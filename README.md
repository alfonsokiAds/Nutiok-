# 🥑 NUTIOK - Alimentación Saludable e Inteligente
> Aplicación móvil integral desarrollada con **Flutter** para la comunidad universitaria de la **Universidad de Cundinamarca (UdeC) - Sede Ubaté**.

---

## 📲 Descarga Directa del APK (Versión Presentación v1.0)

El instalador oficial para dispositivos Android está disponible directamente en la raíz de este repositorio:

📦 **[Descargar NUTIOK_v1.0_Presentacion.apk (Clic para descargar)](./NUTIOK_v1.0_Presentacion.apk?raw=true)**

### 📋 Guía rápida de instalación en tu teléfono:
1. Descarga el archivo `NUTIOK_v1.0_Presentacion.apk` en tu dispositivo Android.
2. Abre el archivo descargado. Si Android te solicita autorización, activa la opción **"Permitir la instalación de fuentes desconocidas"** o **"Confiar en esta fuente"**.
3. Toca **Instalar** y abre la aplicación.

---

## 🚀 Últimas Funcionalidades Implementadas

### 1. ⏰ Módulo de Recordatorios y Alertas Inteligentes (Resuelto)
* **Carga instantánea sin bloqueos:** Se solucionó el problema donde la pantalla se quedaba cargando indefinidamente debido a bloqueos de políticas RLS o tiempos de espera de red.
* **Persistencia local con `SharedPreferences`:** Los recordatorios se almacenan localmente en el dispositivo para estar disponibles al instante (0 ms) incluso sin conexión a internet.
* **4 Horarios Inteligentes Predeterminados:**
  * 🌅 **Desayuno (07:00 AM)** - *¡Hora de empezar el día con energía!*
  * 🍱 **Almuerzo (01:00 PM)** - *¡Momento de recargar energías!*
  * 🍎 **Merienda (04:00 PM)** - *Un pequeño snack balanceado para continuar.*
  * 🥗 **Cena (07:30 PM)** - *Termina el día con una buena cena ligera.*
* **Sincronización en segundo plano con Supabase:** La app actualiza la interfaz de forma optimista inmediatamente y sincroniza los cambios de forma asíncrona sin congelar la pantalla.
* **Tolerancia a fallos en notificaciones:** Blindaje en el servicio de alarmas locales para dispositivos sin permisos de alarmas exactas configurados.

### 2. 🗺️ Módulo de Mapa y Guía de Restaurantes Saludables (Campus Ubaté)
* **Solución a errores de API Key:** Se reemplazó la dependencia de Google Maps SDK con pago restrictivo por una **Guía Interactiva del Campus Ubaté**.
* **Directorio de Opciones Saludables Cercanas:**
  * 🥗 **Restaurante Doña Luz:** Comida casera balanceada (Almuerzo con vegetales y proteína magra).
  * 🥩 **Don Pedro - Parrilla & Ensaladas:** Ensaladas abundantes con proteína a la plancha.
  * 🍲 **El Sabor:** Menú ejecutivo del día con opción vegetariana.
  * 🎓 **Comedor Estudiantil Ubaté:** Tarifas especiales para estudiantes universitarios.
  * 🥑 **Verde Oliva:** Bowls saludables, wraps y jugos naturales sin azúcar añadida.
* **Cálculo dinámico de tiempos según transporte:**
  * 🚶 **Caminando**
  * 🚗 **En Auto**
  * 🚲 **En Bicicleta**
* **Navegación directa con Google Maps:**
  * Botón **"Cómo llegar"** en cada restaurante que abre directamente la ruta paso a paso (*turn-by-turn*) en la aplicación nativa de Google Maps.
  * Botón **"Ver Mapa"** para explorar la zona circundante en Google Maps.
  * Configuración de `<queries>` en `AndroidManifest.xml` para compatibilidad completa con esquemas `geo:` y `https:`.

### 3. 🍳 Catálogo y Buscador de Recetas Saludables
* Filtros por categoría: **Desayunos**, **Almuerzos**, **Meriendas** y **Cenas**.
* Buscador en tiempo real por palabras clave e ingredientes.
* Ficha técnica detallada por receta: ingredientes, paso a paso, tiempo de preparación y desglose nutricional (calorías, proteínas, carbohidratos y grasas).

### 4. 🎨 Diseño y Experiencia de Usuario
* Interfaz moderna inspirada en diseño limpio y accesible para universitarios.
* Barra de navegación inferior flotante con transiciones suaves.
* Tipografía optimizada con Google Fonts (`Poppins`).

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología |
| :--- | :--- |
| **Framework** | [Flutter 3.x](https://flutter.dev/) |
| **Lenguaje** | [Dart](https://dart.dev/) |
| **Backend & Base de Datos** | [Supabase](https://supabase.com/) (PostgreSQL + Auth + Storage) |
| **Almacenamiento Local** | `shared_preferences` |
| **Navegación Externa** | `url_launcher` (Integración Google Maps) |
| **Diseño y Fuentes** | `google_fonts` |

---

## 💻 Compilación y Ejecución en Desarrollo

### Prerrequisitos:
* Flutter SDK (3.x o superior)
* Android SDK configurado

```bash
# 1. Clonar el repositorio
git clone https://github.com/alfonsokiAds/Nutiok-.git
cd Nutiok-

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo desarrollo
flutter run

# 4. Generar APK Release
flutter build apk --release
```
El APK resultante se genera en:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 👥 Equipo del Proyecto
* **Proyecto:** NUTIOK - Salud y Nutrición Universitaria
* **Institución:** Universidad de Cundinamarca - Sede Ubaté
* **Versión actual:** v1.0 (Presentación Oficial)
