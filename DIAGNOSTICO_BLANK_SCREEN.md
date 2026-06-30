# 🔧 Diagnóstico - Pantalla en Blanco

## Cambios Realizados

He agregado debug prints y una opción de prueba al código para ayudarte a diagnosticar el problema.

---

## 1️⃣ FORZAR VISUALIZACIÓN DE LOGIN (Prueba Rápida)

En `lib/main.dart`, en la clase `NutiokApp.build()`:

```dart
// 🔧 MODO PRUEBA: Forzar visualización de LoginScreen
// Comentar la siguiente línea para volver al flujo normal
if (false) { // ⚠️ CAMBIAR A 'true' PARA ACTIVAR PRUEBA
  return MaterialApp(
    title: 'NUTIOK',
    debugShowCheckedModeBanner: false,
    theme: NutiokTheme.lightTheme,
    home: const LoginScreen(),
  );
}
```

### Cómo usar:
1. **Para probar Login directamente:** Cambia `if (false)` a `if (true)`
2. **Ejecuta:** `flutter run`
3. **Si se visualiza LoginScreen:** El problema está en el flujo de autenticación
4. **Si SIGUE en blanco:** El problema es más profundo (posiblemente Supabase)

---

## 2️⃣ REVISAR LOS LOGS

Abre la consola/terminal donde ejecutas `flutter run` y busca estos prefijos:

### Logs Principales:
```
[APP] 🚀 _AppEntryPoint iniciando...
[APP] 📋 Verificando onboarding...
[APP] 🔐 Verificando sesión...
[AUTH] 🔍 Iniciando verificación de autenticación...
[APP] 🎨 BUILD - Renderizando...
[APP] 🏠 Mostrando HomeScreen... ✅ TODO OK
[APP] 🔐 Mostrando WelcomeScreen (Login)... ✅ TODO OK
```

### Qué Significa Cada Log:

| Log | Significa |
|-----|-----------|
| `[APP] 🚀` | App iniciando |
| `[APP] 📋 Onboarding completado: true/false` | Determina si muestra onboarding |
| `[AUTH] 🔍` | Verificando si hay usuario logueado |
| `[AUTH] ✅ Usuario autenticado detectado` | Hay sesión activa |
| `[AUTH] ❌ No hay usuario autenticado` | Sin sesión (normal al principio) |
| `[APP] 🎨 BUILD - _isLoading: true` | App cargando (debe cambiar a false) |
| `[APP] 🎨 BUILD - _isLoading: false` | Carga completada |
| `[APP] 📱 BUILD Consumer - Autenticado: false` | Va a mostrar LoginScreen |

---

## 3️⃣ POSIBLES PROBLEMAS Y SOLUCIONES

### ❌ PROBLEMA: Se queda en blanco indefinidamente

**Posibles causas:**

1. **Supabase no responde:**
   - El `Supabase.initialize()` en `main()` se queda esperando
   - Solución: Agrega timeout en `main.dart`

2. **`_checkOnboarding()` se queda esperando:**
   - El acceso a SharedPreferences no responde
   - Solución: Agrega timeout o manejo de errores

3. **`AuthService.isAuthenticated` retorna null/error:**
   - Problema en `lib/services/auth_service.dart`
   - Solución: Revisa el código de `isAuthenticated`

### ❌ PROBLEMA: Aparece LoginScreen pero sin contenido

- Es raro, pero revisa `LoginScreen.build()` - ya agregué prints ahí
- Busca en logs: `[LOGIN] 🎨 BUILD`

---

## 4️⃣ PASOS PARA RESOLVER

### Paso 1: Verifica si LoginScreen solo se muestra
```
if (true) { // Activar modo prueba
```
- Si se muestra: **Ir a Paso 3**
- Si sigue en blanco: **Ir a Paso 2**

### Paso 2: Problema está en `Supabase.initialize()`
En `main()`, después de `WidgetsFlutterBinding.ensureInitialized();`:
```dart
try {
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  ).timeout(
    const Duration(seconds: 5),
    onTimeout: () => print('[ERROR] ⏱️ Timeout en Supabase.initialize()'),
  );
} catch (e) {
  print('[ERROR] 🔥 Error inicializando Supabase: $e');
}
```

### Paso 3: Revisa los logs con todo activado
Desactiva el modo prueba (`if (false)`) y ejecuta:
```
flutter run
```
Copia TODO el output de la consola y **analiza los logs** con la tabla de arriba.

---

## 5️⃣ CHECKLIST DE VERIFICACIÓN

- [ ] **LoginScreen se muestra** cuando `if (true)` en main.dart
- [ ] **Logs muestran** `[APP] 🎨 BUILD` (al menos una vez)
- [ ] **SharedPreferences** carga sin timeout (logs de onboarding aparecen)
- [ ] **AuthService** responde (logs `[AUTH]` aparecen)
- [ ] **Consumer** renderiza (logs `[APP] 📱 BUILD Consumer` aparecen)
- [ ] **Pantalla final** es LoginScreen o HomeScreen (no en blanco)

---

## 📝 PRÓXIMOS PASOS

1. **Ejecuta con `if (true)`** y reporta si se ve LoginScreen
2. **Copia todos los logs** desde la consola
3. **Reporta qué logs ves** usando la tabla anterior
4. Según los logs, identificamos dónde se queda trabado

