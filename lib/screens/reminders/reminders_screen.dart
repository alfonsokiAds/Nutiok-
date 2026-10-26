import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:nutiok_app/app_theme.dart';
import '../../providers/reminders_provider.dart';
import '../../models/reminder.dart';
import 'package:nutiok_app/screens/schedule/schedule_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemindersProvider>().loadReminders().then((_) {
        _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _showAddReminderDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedMealType = 'Desayuno';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24, right: 24, top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40, height: 5,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nuevo Recordatorio',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFFFF6B35)),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Título',
                                prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFFFF6B35)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2)),
                                filled: true, fillColor: Colors.grey.shade50,
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: messageController,
                              decoration: InputDecoration(
                                labelText: 'Mensaje',
                                prefixIcon: const Icon(Icons.message_rounded, color: Color(0xFFFF6B35)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2)),
                                filled: true, fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: selectedTime);
                                if (t != null) setSheetState(() => selectedTime = t);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Hora',
                                  prefixIcon: const Icon(Icons.access_time_rounded, color: Color(0xFFFF6B35)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                  filled: true, fillColor: Colors.grey.shade50,
                                ),
                                child: Text(
                                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: selectedMealType,
                              decoration: InputDecoration(
                                labelText: 'Comida',
                                prefixIcon: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFFF6B35)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                filled: true, fillColor: Colors.grey.shade50,
                              ),
                              items: ['Desayuno', 'Almuerzo', 'Cena', 'Snack', 'Otro']
                                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                  .toList(),
                              onChanged: (val) => setSheetState(() => selectedMealType = val!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<RemindersProvider>().createReminder(
                                title: titleController.text,
                                message: messageController.text,
                                time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                mealType: selectedMealType,
                                repeatDaily: true,
                                isSmart: false,
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 5,
                          ),
                          child: Text('Guardar Recordatorio', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B35),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Recordatorios', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<RemindersProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))),
                  );
                }
                if (provider.reminders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.alarm_off_rounded, size: 100, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text('Sin recordatorios', style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Sección: Horario Universitario ---
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, spreadRadius: 2)
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tu Horario Universitario', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Analizando huecos...', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF6B35),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Color(0xFFFF6B35)),
                                ),
                              ),
                              child: const Text('Configurar'),
                            )
                          ],
                        ),
                      ),
                    ),

                    // --- Recordatorios Inteligentes ---
                    if (provider.smartReminders.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Recordatorios Inteligentes', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            Switch(
                              value: provider.smartReminders.isNotEmpty &&
                                  provider.smartReminders.any((r) => r.isActive),
                              onChanged: (val) {
                                provider.toggleAllSmartReminders(val);
                              },
                              activeColor: Colors.green,
                            )
                          ],
                        ),
                      ),
                      _buildRemindersList(provider.smartReminders, provider, true),
                    ],

                    // --- Recordatorios Manuales ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Text('Recordatorios Manuales', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    if (provider.manualReminders.isEmpty)
                      Center(child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('Sin recordatorios manuales extras.', style: GoogleFonts.poppins(color: Colors.grey)),
                      ))
                    else
                      _buildRemindersList(provider.manualReminders, provider, false),
                      
                    const SizedBox(height: 80), // Espacio para FAB
                  ],
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(),
        backgroundColor: const Color(0xFFFF6B35),
        elevation: 8,
        child: const Icon(Icons.add_alarm_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildRemindersList(List<ReminderModel> reminders, RemindersProvider provider, bool isSmart) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: reminders.length,
      itemBuilder: (context, i) {
        final reminder = reminders[i];
        final isActive = reminder.isActive;
        final Color cardBg = isActive ? Colors.white : const Color(0xFFEBEBEB);
        final Color textColor = isActive ? Colors.black87 : Colors.grey.shade600;
        final Color timeColor = isActive ? const Color(0xFFFF6B35) : Colors.grey.shade500;
        final Color iconBg = isActive
            ? _mealTypeColor(reminder.mealType).withOpacity(0.15)
            : Colors.grey.shade300;
        final Color iconColor =
            isActive ? _mealTypeColor(reminder.mealType) : Colors.grey.shade500;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(i * 0.1, 1.0, curve: Curves.easeOutBack),
                  )),
              child: FadeTransition(
                opacity: _animationController,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.grey.shade100 : Colors.grey.shade300,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: isSmart ? () async {
                  // Editar hora de recordatorio inteligente
                  final parts = reminder.time.split(':');
                  final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                  final newTime = await showTimePicker(context: context, initialTime: initialTime);
                  if (newTime != null) {
                    final updated = reminder.copyWith(time: '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}');
                    provider.updateReminder(updated);
                  }
                } : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_mealTypeIcon(reminder.mealType), color: iconColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reminder.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                            Text(reminder.time, style: GoogleFonts.poppins(fontSize: 14, color: timeColor, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Switch(
                        value: reminder.isActive,
                        onChanged: (val) {
                          provider.toggleReminderActive(reminder.id, val);
                        },
                        activeColor: isSmart ? Colors.green : const Color(0xFFFF6B35),
                      ),
                      if (!isSmart)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => provider.deleteReminder(reminder.id),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
