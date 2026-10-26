import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutiok_app/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../providers/reminders_provider.dart';
import '../../models/recipe.dart';
import 'recipe_detail_screen.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todas';

  final List<String> _categories = [
    'Todas',
    'Desayuno',
    'Almuerzo',
    'Cena',
    'Snack',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RemindersProvider>();
      provider.loadRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
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

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
      case 'fácil':
        return const Color(0xFF2E7D32);
      case 'media':
        return const Color(0xFFFF6B35);
      case 'dificil':
      case 'difícil':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  String _difficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
      case 'fácil':
        return 'Fácil';
      case 'media':
        return 'Media';
      case 'dificil':
      case 'difícil':
        return 'Difícil';
      default:
        return difficulty;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'desayuno':
        return Icons.wb_sunny_rounded;
      case 'almuerzo':
        return Icons.restaurant_rounded;
      case 'cena':
        return Icons.nightlight_rounded;
      case 'snack':
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant_menu_rounded;
    }
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    List<Recipe> filtered = recipes;

    // Filtro por categoría seleccionada
    if (_selectedCategory != 'Todas') {
      filtered = filtered
          .where((r) =>
              r.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Filtro por texto de búsqueda (nombre, ingredientes o descripción)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.description.toLowerCase().contains(query) ||
              r.ingredients.any((i) => i.toLowerCase().contains(query)))
          .toList();
    }

    return filtered;
  }

  /// Diálogo modal completo para que el estudiante cree su propia receta
  void _showCreateRecipeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final ingredientsController = TextEditingController();
    final stepsController = TextEditingController();
    final prepTimeController = TextEditingController(text: '15');

    String selectedCategory =
        _selectedCategory == 'Todas' ? 'Desayuno' : _selectedCategory;
    String selectedDifficulty = 'Facil';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Barra decorativa superior
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Color(0xFF2E7D32),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Crear Receta Universitaria',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                                Text(
                                  'Comparte tu preparación saludable',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 1. Título de la receta
                      Text(
                        'Título de la receta *',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Ej. Wrap de Atún y Aguacate',
                          prefixIcon: const Icon(
                            Icons.restaurant_menu_rounded,
                            color: Color(0xFF2E7D32),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Ingresa el título de la receta'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // 2. Categoría
                      Text(
                        'Categoría de la comida *',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
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
                        ].map((cat) {
                          final isSelected = selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: const Color(0xFF2E7D32),
                            labelStyle: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (_) {
                              setSheetState(() => selectedCategory = cat);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 3. Tiempo y Dificultad
                      Row(
                        children: [
                          // Tiempo de preparación
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tiempo (min) *',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: prepTimeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '15',
                                    prefixIcon: const Icon(
                                      Icons.timer_outlined,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9F9F9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Requerido'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Dificultad
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dificultad *',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9F9),
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedDifficulty,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Facil',
                                            child: Text('Fácil')),
                                        DropdownMenuItem(
                                            value: 'Media',
                                            child: Text('Media')),
                                        DropdownMenuItem(
                                            value: 'Dificil',
                                            child: Text('Difícil')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) {
                                          setSheetState(
                                              () => selectedDifficulty = v);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Ingredientes con Cantidades
                      Text(
                        'Ingredientes y cantidades *',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Escribe cada ingrediente en una línea con su cantidad:',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: ingredientsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              '1 lata de atún en agua\n2 tortillas integrales\n1/2 aguacate maduro\n1 tomate picado\n1 pizca de sal y limón',
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Ingresa los ingredientes'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // 5. Descripción del proceso / Paso a paso
                      Text(
                        'Descripción del proceso y preparación *',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explica los pasos para prepararla:',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: stepsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              '1. Escurrir bien el atún.\n2. En un tazón machacar el aguacate con sal y limón.\n3. Mezclar el atún y el tomate.\n4. Rellenar las tortillas y enrollar.',
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Ingresa los pasos de preparación'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // 6. Descripción corta / Resumen
                      Text(
                        'Breve descripción o beneficio nutricional',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              'Rápido de preparar entre clases, alto en proteína y grasas saludables.',
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón Guardar / Publicar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_rounded),
                          label: Text(
                            'PUBLICAR MI RECETA',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final name = nameController.text.trim();
                              final description = descriptionController.text.trim().isNotEmpty
                                  ? descriptionController.text.trim()
                                  : 'Receta creada por estudiante para la comunidad NUTIOK';
                              final prepTime =
                                  int.tryParse(prepTimeController.text.trim()) ?? 15;

                              // Separar ingredientes por salto de línea
                              final rawIngredients = ingredientsController.text
                                  .split('\n')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .toList();

                              // Separar pasos por salto de línea
                              final rawSteps = stepsController.text
                                  .split('\n')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .toList();

                              final provider = context.read<RemindersProvider>();
                              await provider.addStudentRecipe(
                                name: name,
                                description: description,
                                category: selectedCategory,
                                difficulty: selectedDifficulty,
                                preparationTime: prepTime,
                                ingredients: rawIngredients,
                                steps: rawSteps,
                              );

                              if (context.mounted) {
                                Navigator.of(sheetContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '¡Receta "$name" publicada con éxito en $selectedCategory! 🎓',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF2E7D32),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
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

  void _showPdfBookletInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Desayunos y Meriendas Saludables',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Manual Oficial AFA • 14 Recetas Integradas',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Las 14 recetas de este manual han sido extraídas y clasificadas según su momento del día para el bienestar universitario.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Column(
                children: [
                  _buildBookletStat(Icons.wb_sunny_rounded, 'Desayunos', '4 opciones energéticas'),
                  const Divider(height: 12),
                  _buildBookletStat(Icons.restaurant_rounded, 'Almuerzos', '4 platos y bocadillos completos'),
                  const Divider(height: 12),
                  _buildBookletStat(Icons.nights_stay_rounded, 'Cenas', '3 preparaciones ligeras'),
                  const Divider(height: 12),
                  _buildBookletStat(Icons.cookie_rounded, 'Snacks / Meriendas', '3 opciones saciantes'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: Text(
                  'Ver Recetas en el Recetario',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBookletStat(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Recetario',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por receta o ingrediente...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          color: Colors.grey.shade400,
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Botones Filtro de Categoría (Todas, Desayuno, Almuerzo, Cena, Snack) ──
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2E7D32)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcon(category),
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : _categoryColor(category),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ── Banner Recetario Oficial AFA ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Libro Oficial AFA Integrado',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Desayunos y Meriendas Saludables (14 recetas)',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showPdfBookletInfo(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Detalles',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2E7D32),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Lista de Recetas Filtradas ──
          Expanded(
            child: Consumer<RemindersProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingRecipes) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  );
                }

                final filteredRecipes = _filterRecipes(provider.recipes);

                if (filteredRecipes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 70,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No hay recetas en "$_selectedCategory"',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No encontramos coincidencias para "$_searchQuery".'
                                : '¡Sé el primero en compartir una receta en esta categoría!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateRecipeDialog(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Crear Receta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 4,
                    bottom: 80, // Espacio para el botón flotante inferior
                  ),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    final isFavorite = provider.isRecipeFavorite(recipe.id);
                    final isStudentRecipe =
                        recipe.id.startsWith('student_') || recipe.id.length > 20;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(
                                recipe: recipe,
                              ),
                            ),
                          );
                        },
                        child: CustomCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 16,
                          child: Row(
                            children: [
                              // Imagen de la receta con fallback
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: Container(
                                  width: 110,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    color: _categoryColor(recipe.category)
                                        .withValues(alpha: 0.15),
                                    image: recipe.imageUrl != null &&
                                            recipe.imageUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(recipe.imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: recipe.imageUrl == null ||
                                          recipe.imageUrl!.isEmpty
                                      ? Center(
                                          child: Icon(
                                            _categoryIcon(recipe.category),
                                            size: 40,
                                            color:
                                                _categoryColor(recipe.category),
                                          ),
                                        )
                                      : null,
                                ),
                              ),

                              // Contenido de la receta
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Título
                                      Text(
                                        recipe.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),

                                      // Categoría y distintivo si fue creada por estudiante
                                      Row(
                                        children: [
                                          Icon(
                                            _categoryIcon(recipe.category),
                                            size: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            recipe.category.toLowerCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (isStudentRecipe) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF673AB7)
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Estudiante 🎓',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF673AB7),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Dificultad, tiempo y favoritos
                                      Row(
                                        children: [
                                          // Badge de dificultad
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _difficultyColor(
                                                      recipe.difficulty)
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _difficultyLabel(recipe.difficulty),
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _difficultyColor(
                                                    recipe.difficulty),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Tiempo estimado
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 13,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${recipe.preparationTime} min',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),

                                          // Botón Favorito
                                          GestureDetector(
                                            onTap: () {
                                              provider.toggleRecipeFavorite(
                                                  recipe.id);
                                            },
                                            child: Icon(
                                              isFavorite
                                                  ? Icons.favorite_rounded
                                                  : Icons.favorite_border_rounded,
                                              size: 20,
                                              color: isFavorite
                                                  ? Colors.red
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
            ),
          ),
        ],
      ),

      // ── Botón en la Zona Morada: Crear / Sugerir Receta ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRecipeDialog(context),
        backgroundColor: const Color(0xFFFF6B35),
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: Text(
          'Crear mi Receta',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
