import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/reminders_provider.dart';
import 'services/notification_service.dart';
import 'screens/onboarding/welcome_onboarding_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/main_layout_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno de forma segura
  await dotenv.load(fileName: ".env");

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Inicializar notificaciones
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => RemindersProvider()),
      ],
      child: const NutiokApp(),
    ),
  );
}

class NutiokApp extends StatelessWidget {
  const NutiokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUTIOK',
      debugShowCheckedModeBanner: false,
      theme: NutiokTheme.lightTheme,
      home: const _AppEntryPoint(),
      routes: {
        '/login': (context) => const WelcomeScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/forgot-password': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return ForgotPasswordScreen(initialEmail: email);
        },
      },
    );
  }
}

/// Punto de entrada que verifica si el usuario ya vio el onboarding
class _AppEntryPoint extends StatefulWidget {
  const _AppEntryPoint();

  @override
  State<_AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<_AppEntryPoint> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[APP] 🚀 _AppEntryPoint iniciando...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  Future<void> _checkOnboarding() async {
    debugPrint('[APP] 📋 Verificando onboarding...');
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    debugPrint('[APP] 📋 Onboarding completado: $onboardingCompleted');

    if (!mounted) {
      debugPrint('[APP] ⚠️ Widget desmontado, cancelando...');
      return;
    }

    // Verificar sesion activa
    final authProvider = context.read<AuthProvider>();
    debugPrint('[APP] 🔐 Verificando sesión...');
    await authProvider.checkAuth();

    if (!mounted) {
      debugPrint('[APP] ⚠️ Widget desmontado, cancelando...');
      return;
    }

    setState(() {
      _showOnboarding = !onboardingCompleted;
      _isLoading = false;
      debugPrint(
          '[APP] ✅ Estado actualizado - Onboarding: $_showOnboarding, Loading: $_isLoading');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '[APP] 🎨 BUILD - _isLoading: $_isLoading, _showOnboarding: $_showOnboarding');

    if (_isLoading) {
      debugPrint('[APP] 🔄 Mostrando splash/loading...');
      return Scaffold(
        backgroundColor: NutiokTheme.primaryOrange,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_showOnboarding) {
      debugPrint('[APP] 📚 Mostrando onboarding...');
      return const WelcomeOnboardingScreen();
    }

    // Si esta autenticado, ir al home; si no, al login
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        debugPrint(
            '[APP] 📱 BUILD Consumer - Autenticado: ${authProvider.isAuthenticated}');
        if (authProvider.isAuthenticated) {
          debugPrint('[APP] 🏠 Mostrando MainLayoutScreen...');
          return const MainLayoutScreen();
        }
        debugPrint('[APP] 🔐 Mostrando WelcomeScreen (Login)...');
        return const WelcomeScreen();
      },
    );
  }
}
