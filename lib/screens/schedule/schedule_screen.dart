import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutiok_app/app_theme.dart';
import '../../models/schedule_class.dart';
import '../../providers/reminders_provider.dart';
import 'dart:ui';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemindersProvider>().loadReminders();
    });
  }

  void _showAddClassDialog(BuildContext context, int dayIndex) {
    final formKey = GlobalKey<FormState>();
    final classController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

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
                padding: EdgeInsets.only(
                  left: 24, right: 24, top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40, height: 5,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(height: 24),
                      Text('Nueva Clase - ${_days[dayIndex]}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: NutiokTheme.primaryGreen)),
                      const SizedBox(height: 24),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: classController,
                              decoration: InputDecoration(
                                labelText: 'Nombre de la clase',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                filled: true, fillColor: Colors.grey.shade50,
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final t = await showTimePicker(context: context, initialTime: startTime);
                                      if (t != null) setSheetState(() => startTime = t);
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Hora Inicio',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                        filled: true, fillColor: Colors.grey.shade50,
                                      ),
                                      child: Text('${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final t = await showTimePicker(context: context, initialTime: endTime);
                                      if (t != null) setSheetState(() => endTime = t);
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Hora Fin',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                        filled: true, fillColor: Colors.grey.shade50,
                                      ),
                                      child: Text('${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    final newClass = ScheduleClassModel(
                                      id: '', // Supabase generará el ID
                                      userId: '', // Provider se encarga
                                      className: classController.text,
                                      dayOfWeek: dayIndex + 1,
                                      startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                                      endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                                    );
                                    context.read<RemindersProvider>().addScheduleClass(newClass);
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: NutiokTheme.primaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('Guardar Clase', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ],
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
      appBar: AppBar(
        title: Text('Mi Horario Universitario', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded, color: NutiokTheme.primaryOrange),
            tooltip: 'Analizar Huecos',
            onPressed: () {
              context.read<RemindersProvider>().analyzeScheduleAndSuggestReminders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Horario analizado. Revisa tus recordatorios inteligentes.')),
              );
            },
          )
        ],
      ),
      body: Consumer<RemindersProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 7, // 7 días
            itemBuilder: (context, i) {
              final dayClasses = provider.schedule.where((c) => c.dayOfWeek == (i + 1)).toList();
              dayClasses.sort((a, b) => a.startTime.compareTo(b.startTime));

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _days[i],
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: NutiokTheme.primaryGreen),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: NutiokTheme.primaryGreen),
                            onPressed: () => _showAddClassDialog(context, i),
                          )
                        ],
                      ),
                      const Divider(),
                      if (dayClasses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('Libre', style: GoogleFonts.poppins(color: Colors.grey)),
                        )
                      else
                        ...dayClasses.map((c) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(c.className, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text('${c.startTime} - ${c.endTime}', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => provider.deleteScheduleClass(c.id),
                          ),
                        )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
