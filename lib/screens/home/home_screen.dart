import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nutiok_app/app_theme.dart';
import 'package:nutiok_app/widgets/bottom_nav_bar.dart';
import '../../providers/auth_provider.dart';

import 'package:nutiok_app/screens/recipes/recipe_search_screen.dart';
import 'package:nutiok_app/screens/reminders/reminders_screen.dart';
import 'package:nutiok_app/screens/map/map_screen.dart';
import 'package:nutiok_app/screens/profile/profile_screen.dart';
import '../../providers/reminders_provider.dart';
import '../../models/reminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemindersProvider>().loadReminders();
    });
  }
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

              Consumer<RemindersProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: NutiokTheme.primaryGreen));
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recordatorios Inteligentes (Horarios)
                      ...provider.smartReminders.map((reminder) => _buildReminderCard(reminder)),
                      
                      const SizedBox(height: 20),
                      _buildScheduleToggle(provider),

                      const SizedBox(height: 28),
                      // Recordatorios Manuales
                      Text(
                        'Tus Recordatorios',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NutiokTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (provider.manualReminders.isEmpty)
                        Text('No tienes recordatorios manuales programados.', style: GoogleFonts.poppins(color: Colors.grey))
                      else
                        ...provider.manualReminders.map((reminder) => _buildReminderCard(reminder)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
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

  /// Construye una tarjeta individual de recordatorio
  Widget _buildReminderCard(ReminderModel reminder) {
    Color cardColor;
    IconData cardIcon;
    
    switch (reminder.mealType.toLowerCase()) {
      case 'desayuno':
        cardColor = const Color(0xFFFF9800);
        cardIcon = Icons.free_breakfast_rounded;
        break;
      case 'almuerzo':
        cardColor = const Color(0xFF4CAF50);
        cardIcon = Icons.lunch_dining_rounded;
        break;
      case 'cena':
        cardColor = const Color(0xFF2E7D32);
        cardIcon = Icons.dinner_dining_rounded;
        break;
      case 'snack':
        cardColor = const Color(0xFFFF6B35);
        cardIcon = Icons.cookie_rounded;
        break;
      default:
        cardColor = Colors.blueGrey;
        cardIcon = Icons.notifications_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cardIcon, color: cardColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                if (reminder.message.isNotEmpty)
                  Text(
                    reminder.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: NutiokTheme.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              reminder.time,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: NutiokTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el toggle de activar horarios (estilo ToggleButtons verde)
  Widget _buildScheduleToggle(RemindersProvider provider) {
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
          Expanded(
            child: Column(
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
          ),
          // Toggle verde estilo ToggleButtons
          _ScheduleToggle(provider: provider),
        ],
      ),
    );
  }
}

/// Toggle personalizado verde estilo ToggleButtons
class _ScheduleToggle extends StatelessWidget {
  final RemindersProvider provider;
  
  const _ScheduleToggle({required this.provider});

  @override
  Widget build(BuildContext context) {
    bool isActive = provider.smartReminders.any((r) => r.isActive);

    return GestureDetector(
      onTap: () {
        for(var r in provider.smartReminders) {
          provider.toggleReminderActive(r.id, !isActive);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive ? NutiokTheme.primaryGreen : Colors.grey.shade300,
          boxShadow: [
            BoxShadow(
              color: (isActive ? NutiokTheme.primaryGreen : Colors.grey)
                  .withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment:
              isActive ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
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
