import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

/// Barra de navegacion inferior compartida
/// Utilizada en todas las pantallas principales de la app
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            index: 0,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.restaurant_menu_rounded,
            label: 'Recetas',
            index: 1,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.notifications_rounded,
            label: 'Alertas',
            index: 2,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.map_rounded,
            label: 'Mapa',
            index: 3,
            context: context,
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Perfil',
            index: 4,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isActive = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive ? NutiokTheme.primaryGreen : Colors.grey[500],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? NutiokTheme.primaryGreen : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
