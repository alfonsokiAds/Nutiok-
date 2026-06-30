import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../providers/auth_provider.dart';

// Importar pantallas de otros sprints
import '../sprint2/recipe_search_screen.dart';
import '../sprint2/reminders_screen.dart';
import '../sprint4/map_screen.dart';
import '../sprint3/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Navega a las distintas pantallas según el índice del BottomNavBar
  void _navigateTo(int index) {
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecipeSearchScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RemindersScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  /// Datos de los horarios de comidas
  final List<Map<String, dynamic>> _mealSchedule = const [
    {
      'icon': Icons.free_breakfast_rounded,
      'name': 'Desayuno',
      'time': '7:00 AM',
      'color': Color(0xFFFF9800),
    },
    {
      'icon': Icons.lunch_dining_rounded,
      'name': 'Almuerzo',
      'time': '12:30 PM',
      'color': Color(0xFF4CAF50),
    },
    {
      'icon': Icons.cookie_rounded,
      'name': 'Merienda',
      'time': '4:00 PM',
      'color': Color(0xFFFF6B35),
    },
    {
      'icon': Icons.dinner_dining_rounded,
      'name': 'Cena',
      'time': '8:00 PM',
      'color': Color(0xFF2E7D32),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Saludo con nombre del usuario ──
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final userName = authProvider.currentUser?.fullName ?? 'Usuario';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, $userName! 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: NutiokTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¿Qué vamos a comer hoy?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Tarjeta: Recomendación del Día ──
              _buildRecommendationCard(),

              const SizedBox(height: 28),

              // ── Sección: Mejores Horarios ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mejores Horarios',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: NutiokTheme.primaryGreen,
                    ),
                  ),
                  Text(
                    'Hoy',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: NutiokTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Lista de tarjetas de horarios
              ..._mealSchedule.map((meal) => _buildMealCard(meal)),

              // Toggle ACTIVAR horarios
              const SizedBox(height: 20),
              _buildScheduleToggle(),

              const SizedBox(height: 100), // Espacio para el BottomNavBar
            ],
          ),
        ),
      ),
      // ── Barra de navegación inferior ──
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: _navigateTo,
      ),
    );
  }

  /// Construye la tarjeta de recomendación del día
  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            NutiokTheme.primaryGreen,
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: NutiokTheme.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono de comida
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Texto de recomendación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendación del Día',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Incluye una porción de frutas\nfrescas en tu desayuno 🍎',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta individual de horario de comida
  Widget _buildMealCard(Map<String, dynamic> meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono de la comida
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (meal['color'] as Color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              meal['icon'] as IconData,
              color: meal['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Nombre de la comida
          Expanded(
            child: Text(
              meal['name'] as String,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          // Hora
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: NutiokTheme.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              meal['time'] as String,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: NutiokTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el toggle de activar horarios (estilo ToggleButtons verde)
  Widget _buildScheduleToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recordatorio de horarios',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Recibe notificaciones en cada comida',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          // Toggle verde estilo ToggleButtons
          _ScheduleToggle(),
        ],
      ),
    );
  }
}

/// Toggle personalizado verde estilo ToggleButtons
class _ScheduleToggle extends StatefulWidget {
  @override
  State<_ScheduleToggle> createState() => _ScheduleToggleState();
}

class _ScheduleToggleState extends State<_ScheduleToggle> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isActive = !_isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _isActive ? NutiokTheme.primaryGreen : Colors.grey.shade300,
          boxShadow: [
            BoxShadow(
              color: (_isActive ? NutiokTheme.primaryGreen : Colors.grey)
                  .withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment:
              _isActive ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
