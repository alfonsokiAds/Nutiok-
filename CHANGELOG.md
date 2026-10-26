# 📝 Registro de Cambios (Changelog) - NUTIOK

## [v1.0.0-presentacion] - 2026-10-26

### 🚀 Nuevas Características y Mejoras
- **Módulo de Mapa y Restaurantes Saludables:**
  - Implementación de guía interactiva del campus Ubaté con establecimientos de comida saludable.
  - Integración con Google Maps mediante `url_launcher` para abrir la navegación GPS punto a punto ("Cómo llegar") y visualización de la zona ("Ver Mapa").
  - Selector dinámico de transporte (Caminando, Auto, Bicicleta) con cálculo en vivo de distancias y minutos estimados.
  - Configuración de `<queries>` de Android para soporte de intents `geo:` y `https:`.

- **Módulo de Recordatorios Inteligentes:**
  - Corrección del bloqueo de carga infinita en la pantalla de alertas.
  - Implementación de almacenamiento local con `SharedPreferences` para disponibilidad instantánea (0 ms) sin depender de conexión externa.
  - Adición de 4 recordatorios predeterminados inteligentes de comidas universitarias (Desayuno, Almuerzo, Merienda, Cena).
  - Manejo de excepciones y timeouts para sincronización resiliente con Supabase en segundo plano.
  - Control de excepciones en `NotificationService` para dispositivos que no soportan alarmas exactas.

- **Distribución y APK:**
  - Generación de release APK oficial optimizado (`NUTIOK_v1.0_Presentacion.apk`).
  - Publicación directa del APK en la raíz del repositorio para descarga inmediata en dispositivos móviles.
  - Documentación de instalación y uso en `README.md`.
