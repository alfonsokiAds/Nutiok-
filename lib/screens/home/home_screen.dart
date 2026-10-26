import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:nutiok_app/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reminders_provider.dart';
import '../../models/reminder.dart';
import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Solicitar permisos de notificación explícitamente en el primer ingreso (Android 13+)
      await NotificationService().requestPermission();
      if (mounted) {
        context.read<RemindersProvider>().loadReminders();
      }
    });
  }

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
                  final userName =
                      authProvider.currentUser?.fullName ?? 'Usuario';
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

              // ── Sección: Mejores Horarios (Recordatorios Inteligentes) ──
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NutiokTheme.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hoy',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: NutiokTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Consumer<RemindersProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: NutiokTheme.primaryGreen,
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recordatorios Inteligentes (Horarios)
                      ...provider.smartReminders
                          .map((reminder) => _buildSmartReminderCard(
                                context,
                                reminder,
                                provider,
                              )),

                      const SizedBox(height: 14),

                      // Toggle maestro para activar o desactivar todos
                      _buildScheduleMasterToggle(provider),

                      const SizedBox(height: 32),

                      // ── Sección: Tus Recordatorios (Manuales / Personalizados) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tus Recordatorios',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: NutiokTheme.primaryGreen,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddReminderDialog(context),
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 18,
                              color: NutiokTheme.primaryGreen,
                            ),
                            label: Text(
                              'Nuevo',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: NutiokTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (provider.manualReminders.isEmpty)
                        _buildEmptyManualRemindersCard(context)
                      else
                        ...provider.manualReminders
                            .map((reminder) => _buildManualReminderCard(
                                  context,
                                  reminder,
                                  provider,
                                )),

                      const SizedBox(height: 30),
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

  /// Construye una tarjeta de recordatorio inteligente (se pone en gris si está desactivado)
  Widget _buildSmartReminderCard(
    BuildContext context,
    ReminderModel reminder,
    RemindersProvider provider,
  ) {
    final bool isActive = reminder.isActive;

    Color themeColor;
    IconData cardIcon;

    switch (reminder.mealType.toLowerCase()) {
      case 'desayuno':
        themeColor = const Color(0xFFFF9800);
        cardIcon = Icons.free_breakfast_rounded;
        break;
      case 'almuerzo':
        themeColor = const Color(0xFF4CAF50);
        cardIcon = Icons.lunch_dining_rounded;
        break;
      case 'cena':
        themeColor = const Color(0xFF2E7D32);
        cardIcon = Icons.dinner_dining_rounded;
        break;
      case 'snack':
        themeColor = const Color(0xFFFF6B35);
        cardIcon = Icons.cookie_rounded;
        break;
      default:
        themeColor = Colors.blueGrey;
        cardIcon = Icons.notifications_rounded;
    }

    // Colores dinámicos: si está inactivo se vuelve gris
    final Color backgroundColor = isActive ? Colors.white : const Color(0xFFEBEBEB);
    final Color iconBoxColor =
        isActive ? themeColor.withValues(alpha: 0.12) : Colors.grey.shade300;
    final Color iconColor = isActive ? themeColor : Colors.grey.shade500;
    final Color titleColor = isActive ? Colors.black87 : Colors.grey.shade600;
    final Color subtitleColor = isActive ? Colors.grey.shade600 : Colors.grey.shade500;
    final Color timeBadgeBg =
        isActive ? NutiokTheme.primaryGreen.withValues(alpha: 0.1) : Colors.grey.shade300;
    final Color timeBadgeText =
        isActive ? NutiokTheme.primaryGreen : Colors.grey.shade600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBoxColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cardIcon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),

          // Título y Mensaje
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reminder.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    if (!isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pausado',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  isActive
                      ? reminder.message
                      : 'Recordatorio inactivo para esta comida',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),

          // Hora
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: timeBadgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              reminder.time.length == 5 ? '${reminder.time}:00' : reminder.time,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: timeBadgeText,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Switch individual para apagar/encender
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: isActive,
              activeColor: NutiokTheme.primaryGreen,
              activeTrackColor: NutiokTheme.primaryGreen.withValues(alpha: 0.4),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: (newValue) {
                provider.toggleReminderActive(reminder.id, newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el toggle maestro para activar o desactivar todos los horarios
  Widget _buildScheduleMasterToggle(RemindersProvider provider) {
    final bool anyActive =
        provider.smartReminders.isNotEmpty && provider.smartReminders.any((r) => r.isActive);

    return Container(
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
                  anyActive
                      ? 'Recibe notificaciones en cada comida'
                      : 'Todos los horarios están desactivados',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: anyActive ? Colors.grey.shade600 : Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: anyActive,
            activeColor: NutiokTheme.primaryGreen,
            activeTrackColor: NutiokTheme.primaryGreen.withValues(alpha: 0.4),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (newValue) {
              provider.toggleAllSmartReminders(newValue);
            },
          ),
        ],
      ),
    );
  }

  /// Construye la tarjeta cuando no hay recordatorios manuales aún
  Widget _buildEmptyManualRemindersCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: NutiokTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_add_rounded,
              color: NutiokTheme.primaryGreen,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No tienes recordatorios manuales programados',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crea alertas personalizadas con tus comidas, meriendas o consumo de agua.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddReminderDialog(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              'Crear recordatorio',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: NutiokTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de recordatorio manual personalizado
  Widget _buildManualReminderCard(
    BuildContext context,
    ReminderModel reminder,
    RemindersProvider provider,
  ) {
    final bool isActive = reminder.isActive;

    Color themeColor;
    IconData cardIcon;

    switch (reminder.mealType.toLowerCase()) {
      case 'desayuno':
        themeColor = const Color(0xFFFF9800);
        cardIcon = Icons.wb_sunny_rounded;
        break;
      case 'almuerzo':
        themeColor = const Color(0xFF4CAF50);
        cardIcon = Icons.lunch_dining_rounded;
        break;
      case 'cena':
        themeColor = const Color(0xFF2E7D32);
        cardIcon = Icons.dinner_dining_rounded;
        break;
      case 'snack':
      case 'merienda':
        themeColor = const Color(0xFFFF6B35);
        cardIcon = Icons.cookie_rounded;
        break;
      case 'agua':
        themeColor = Colors.blue;
        cardIcon = Icons.water_drop_rounded;
        break;
      default:
        themeColor = const Color(0xFF009688);
        cardIcon = Icons.alarm_rounded;
    }

    final Color backgroundColor = isActive ? Colors.white : const Color(0xFFEBEBEB);
    final Color iconBoxColor =
        isActive ? themeColor.withValues(alpha: 0.12) : Colors.grey.shade300;
    final Color iconColor = isActive ? themeColor : Colors.grey.shade500;
    final Color titleColor = isActive ? Colors.black87 : Colors.grey.shade600;
    final Color subtitleColor = isActive ? Colors.grey.shade600 : Colors.grey.shade500;
    final Color timeBadgeBg =
        isActive ? themeColor.withValues(alpha: 0.1) : Colors.grey.shade300;
    final Color timeBadgeText = isActive ? themeColor : Colors.grey.shade600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBoxColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cardIcon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        reminder.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pausado',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  reminder.message.isNotEmpty
                      ? reminder.message
                      : 'Recordatorio programado',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),

          // Hora
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: timeBadgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              reminder.time.length == 5 ? '${reminder.time}:00' : reminder.time,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: timeBadgeText,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Switch de activación
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: isActive,
              activeColor: themeColor,
              activeTrackColor: themeColor.withValues(alpha: 0.4),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: (newValue) {
                provider.toggleReminderActive(reminder.id, newValue);
              },
            ),
          ),

          // Botón Eliminar
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade300,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dContext) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Eliminar Recordatorio',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    '¿Deseas eliminar "${reminder.title}"?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dContext, false),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dContext, true),
                      child: Text(
                        'Eliminar',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                provider.deleteReminder(reminder.id);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Diálogo modal para crear un recordatorio manual
  void _showAddReminderDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedMealType = 'Desayuno';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Nuevo Recordatorio',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: NutiokTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configura tu alerta personalizada para el día',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo Título
                        Text(
                          'Título',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'Ej. Batido de Proteína / Tomar Agua',
                            prefixIcon: const Icon(
                              Icons.alarm_rounded,
                              color: NutiokTheme.primaryGreen,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Ingresa un título'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Campo Mensaje / Nota
                        Text(
                          'Mensaje o nota (opcional)',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Ej. Recuerda tomar 500ml de agua',
                            prefixIcon: const Icon(
                              Icons.edit_note_rounded,
                              color: NutiokTheme.primaryGreen,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Selector de Categoría
                        Text(
                          'Categoría',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            'Desayuno',
                            'Almuerzo',
                            'Cena',
                            'Snack',
                            'Agua',
                            'Otro',
                          ].map((cat) {
                            final isSel = selectedMealType == cat;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: isSel,
                              selectedColor: NutiokTheme.primaryGreen,
                              labelStyle: GoogleFonts.poppins(
                                color: isSel ? Colors.white : Colors.black87,
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                setSheetState(() {
                                  selectedMealType = cat;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),

                        // Selector de Hora
                        Text(
                          'Hora del recordatorio',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setSheetState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: NutiokTheme.primaryGreen,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Cambiar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: NutiokTheme.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón Guardar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NutiokTheme.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final timeStr =
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                                final title = titleController.text.trim();
                                final message = messageController.text.trim();

                                await context
                                    .read<RemindersProvider>()
                                    .createReminder(
                                      title: title,
                                      message: message,
                                      time: timeStr,
                                      mealType: selectedMealType.toLowerCase(),
                                      repeatDaily: true,
                                      isSmart: false,
                                    );

                                if (context.mounted) {
                                  Navigator.pop(bottomSheetContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '¡Recordatorio "$title" creado para las $timeStr!',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: NutiokTheme.primaryGreen,
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'Probar Notificación',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          NotificationService()
                                              .showNotificationNow(
                                            title: '🔔 $title',
                                            message: message.isNotEmpty
                                                ? message
                                                : '¡Es hora de tu comida programada!',
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'Guardar Recordatorio',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
