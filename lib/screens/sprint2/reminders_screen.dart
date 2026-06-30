import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../providers/reminders_provider.dart';
import '../../models/reminder.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RemindersProvider>();
      if (provider.reminders.isEmpty) {
        provider.loadReminders();
      }
    });
  }

  Color _mealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return const Color(0xFFFF9800);
      case 'almuerzo':
        return const Color(0xFF2E7D32);
      case 'cena':
        return const Color(0xFF5C6BC0);
      case 'snack':
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF78909C);
    }
  }

  IconData _mealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return Icons.wb_sunny_rounded;
      case 'almuerzo':
        return Icons.restaurant_rounded;
      case 'cena':
        return Icons.nightlight_rounded;
      case 'snack':
        return Icons.cookie_rounded;
      default:
        return Icons.alarm_rounded;
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showAddReminderDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedMealType = 'Desayuno';
    bool repeatDaily = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.92,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.alarm_add_rounded,
                            color: Color(0xFFFF6B35),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Nuevo Recordatorio',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // Title field
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Título',
                              prefixIcon: const Icon(
                                Icons.title_rounded,
                                color: Color(0xFFFF6B35),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFF6B35),
                                  width: 2,
                                ),
                              ),
                            ),
                            style: GoogleFonts.poppins(fontSize: 15),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El título es obligatorio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Message field
                          TextFormField(
                            controller: messageController,
                            decoration: InputDecoration(
                              labelText: 'Mensaje',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 24),
                                child: Icon(
                                  Icons.message_rounded,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFF6B35),
                                  width: 2,
                                ),
                              ),
                              alignLabelWithHint: true,
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Time picker
                          InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFFFF6B35),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black87,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedTime != null) {
                                setSheetState(() {
                                  selectedTime = pickedTime;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Hora',
                                prefixIcon: const Icon(
                                  Icons.schedule_rounded,
                                  color: Color(0xFFFF6B35),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTime(selectedTime),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFF6B35),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: Color(0xFFFF6B35),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Meal type selector
                          DropdownButtonFormField<String>(
                            initialValue: selectedMealType,
                            decoration: InputDecoration(
                              labelText: 'Tipo de comida',
                              prefixIcon: const Icon(
                                Icons.category_rounded,
                                color: Color(0xFFFF6B35),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFF6B35),
                                  width: 2,
                                ),
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Desayuno',
                                child: Text('Desayuno'),
                              ),
                              DropdownMenuItem(
                                value: 'Almuerzo',
                                child: Text('Almuerzo'),
                              ),
                              DropdownMenuItem(
                                value: 'Cena',
                                child: Text('Cena'),
                              ),
                              DropdownMenuItem(
                                value: 'Snack',
                                child: Text('Snack'),
                              ),
                              DropdownMenuItem(
                                value: 'Otro',
                                child: Text('Otro'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setSheetState(() {
                                  selectedMealType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Repeat daily toggle
                          Container(
                            decoration: BoxDecoration(
                              color: repeatDaily
                                  ? const Color(0xFF2E7D32).withValues(alpha: 0.06)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: repeatDaily
                                    ? const Color(0xFF2E7D32).withValues(alpha: 0.2)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.repeat_rounded,
                                      size: 20,
                                      color: repeatDaily
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Repetir diariamente',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: repeatDaily
                                            ? const Color(0xFF2E7D32)
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: repeatDaily,
                                  onChanged: (value) {
                                    setSheetState(() {
                                      repeatDaily = value;
                                    });
                                  },
                                  activeThumbColor: const Color(0xFF2E7D32),
                                  activeTrackColor:
                                      const Color(0xFF2E7D32).withValues(alpha: 0.3),
                                  inactiveThumbColor: Colors.grey.shade400,
                                  inactiveTrackColor: Colors.grey.shade200,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final provider =
                                    context.read<RemindersProvider>();
                                provider.createReminder(
                                  title: titleController.text.trim(),
                                  message: messageController.text.trim(),
                                  time: _formatTime(selectedTime),
                                  mealType: selectedMealType,
                                  repeatDaily: repeatDaily,
                                );
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '¡Recordatorio creado con éxito! ⏰'),
                                    backgroundColor: Color(0xFFFF6B35),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: Text(
                              'Guardar',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDefaultRemindersSuggestion() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Recordatorios Sugeridos',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E7D32),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Te sugerimos estos recordatorios para mantener una alimentación saludable:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestedReminderItem(
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFFFF9800),
              title: 'Desayuno',
              time: '7:00',
            ),
            _buildSuggestedReminderItem(
              icon: Icons.restaurant_rounded,
              color: const Color(0xFF2E7D32),
              title: 'Almuerzo',
              time: '12:30',
            ),
            _buildSuggestedReminderItem(
              icon: Icons.nightlight_rounded,
              color: const Color(0xFF5C6BC0),
              title: 'Cena',
              time: '20:00',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Ahora no',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<RemindersProvider>();
              provider.createReminder(
                title: 'Hora del Desayuno',
                message:
                    '¡Es hora de desayunar! Come algo nutritivo para empezar el día.',
                time: '07:00',
                mealType: 'Desayuno',
                repeatDaily: true,
              );
              provider.createReminder(
                title: 'Hora del Almuerzo',
                message:
                    '¡Hora de almuerzo! No olvides incluir proteínas y verduras.',
                time: '12:30',
                mealType: 'Almuerzo',
                repeatDaily: true,
              );
              provider.createReminder(
                title: 'Hora de la Cena',
                message:
                    '¡Es hora de cenar! Opta por una comida ligera y saludable.',
                time: '20:00',
                mealType: 'Cena',
                repeatDaily: true,
              );
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡3 recordatorios añadidos! ⏰'),
                  backgroundColor: Color(0xFF2E7D32),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Agregar todos',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedReminderItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReminder(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Eliminar Recordatorio',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFD32F2F),
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${reminder.title}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RemindersProvider>().deleteReminder(reminder.id);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Recordatorio eliminado 🗑️'),
                  backgroundColor: Color(0xFFD32F2F),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Mis Recordatorios',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E7D32),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<RemindersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingReminders) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              ),
            );
          }

          final reminders = provider.reminders;

          if (reminders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Empty state illustration
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 24,
                            child: Icon(
                              Icons.alarm_rounded,
                              size: 64,
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.25),
                            ),
                          ),
                          Positioned(
                            bottom: 28,
                            left: 30,
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 44,
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '¡Sin recordatorios!',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configura recordatorios para\nmantener tus horarios de comida.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showDefaultRemindersSuggestion,
                            icon: const Icon(Icons.auto_awesome_rounded,
                                size: 18),
                            label: Text(
                              'Sugerencias',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color:
                                      const Color(0xFFFF6B35).withValues(alpha: 0.4)),
                              foregroundColor: const Color(0xFFFF6B35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showAddReminderDialog,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(
                              'Crear',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Suggestion banner (if only a few reminders)
              if (reminders.length < 3)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: GestureDetector(
                    onTap: _showDefaultRemindersSuggestion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2E7D32).withValues(alpha: 0.08),
                            const Color(0xFFFF6B35).withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: const Color(0xFFFF6B35),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '¡Agrega recordatorios sugeridos para mantenerte al día!',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Reminders list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    final mealColor = _mealTypeColor(reminder.mealType);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: reminder.isActive
                                  ? mealColor.withValues(alpha: 0.15)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Left accent bar + content
                              Row(
                                children: [
                                  // Left accent bar
                                  Container(
                                    width: 4,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: reminder.isActive
                                          ? mealColor
                                          : Colors.grey.shade300,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                    ),
                                  ),

                                  // Meal icon
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: mealColor.withValues(alpha: 
                                            reminder.isActive ? 0.1 : 0.05),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _mealTypeIcon(reminder.mealType),
                                        size: 24,
                                        color: reminder.isActive
                                            ? mealColor
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),

                                  // Reminder info
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reminder.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: reminder.isActive
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          if (reminder.message.isNotEmpty)
                                            Text(
                                              reminder.message,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.schedule_rounded,
                                                size: 14,
                                                color: mealColor.withValues(alpha: 
                                                    reminder.isActive
                                                        ? 1.0
                                                        : 0.5),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatTime(TimeOfDay(
                                                    hour: int.parse(reminder
                                                        .time
                                                        .split(':')[0]),
                                                    minute: int.parse(reminder
                                                        .time
                                                        .split(':')[1]))),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: reminder.isActive
                                                      ? mealColor
                                                      : Colors.grey.shade400,
                                                ),
                                              ),
                                              if (reminder.repeatDaily) ...[
                                                const SizedBox(width: 10),
                                                Icon(
                                                  Icons.repeat_rounded,
                                                  size: 13,
                                                  color: Colors.grey.shade400,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  'Diario',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Toggle switch + delete
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 32,
                                          child: Switch(
                                            value: reminder.isActive,
                                            onChanged: (value) {
                                              provider.toggleReminderActive(
                                                  reminder.id, value);
                                            },
                                            activeThumbColor:
                                                const Color(0xFF2E7D32),
                                            activeTrackColor:
                                                const Color(0xFF2E7D32)
                                                    .withValues(alpha: 0.3),
                                            inactiveThumbColor:
                                                Colors.grey.shade400,
                                            inactiveTrackColor:
                                                Colors.grey.shade200,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _confirmDeleteReminder(
                                              context, reminder),
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              size: 16,
                                              color: Colors.red.shade300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2, onTap: (index) {}),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderDialog,
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'Recordatorio',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
