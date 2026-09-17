import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../app_theme.dart';
import '../../providers/notes_provider.dart';
import '../../models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes().then((_) {
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
        return Icons.note_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  void _showNoteDialog({Note? note}) {
    final isEditing = note != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    String selectedMealType = note?.mealType ?? 'Otro';
    DateTime selectedDate = note?.date ?? DateTime.now();

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
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
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
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isEditing ? 'Editar Nota' : 'Nueva Nota',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                        ),
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
                                prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFF2E7D32)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: contentController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Contenido',
                                alignLabelWithHint: true,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 50),
                                  child: Icon(Icons.notes_rounded, color: Color(0xFF2E7D32)),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: selectedMealType,
                              decoration: InputDecoration(
                                labelText: 'Comida',
                                prefixIcon: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFF2E7D32)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              items: ['Desayuno', 'Almuerzo', 'Cena', 'Snack', 'Otro']
                                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                  .toList(),
                              onChanged: (val) => setSheetState(() => selectedMealType = val!),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (d != null) setSheetState(() => selectedDate = d);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Fecha',
                                  prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF2E7D32)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                child: Text(_formatDate(selectedDate), style: GoogleFonts.poppins()),
                              ),
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
                              final p = context.read<NotesProvider>();
                              if (isEditing) {
                                p.updateNote(note.copyWith(
                                  title: titleController.text,
                                  content: contentController.text,
                                  mealType: selectedMealType,
                                  mealDate: selectedDate,
                                ));
                              } else {
                                p.createNote(
                                  title: titleController.text,
                                  content: contentController.text,
                                  mealType: selectedMealType,
                                  mealDate: selectedDate,
                                );
                              }
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 5,
                          ),
                          child: Text(isEditing ? 'Actualizar Nota' : 'Guardar Nota',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
            backgroundColor: const Color(0xFF2E7D32),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Mis Notas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<NotesProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                  );
                }
                if (provider.notes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notes_rounded, size: 100, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text('No hay notas aún', style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.notes.length,
                  itemBuilder: (context, i) {
                    final note = provider.notes[i];
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
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _showNoteDialog(note: note),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _mealTypeColor(note.mealType ?? 'Otro').withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(_mealTypeIcon(note.mealType ?? 'Otro'), size: 16, color: _mealTypeColor(note.mealType ?? 'Otro')),
                                            const SizedBox(width: 6),
                                            Text(
                                              note.mealTypeDisplay,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _mealTypeColor(note.mealType ?? 'Otro')),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(_formatDate(note.date), style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                        onPressed: () => context.read<NotesProvider>().deleteNote(note.id),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(note.title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text(note.content, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 8,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
