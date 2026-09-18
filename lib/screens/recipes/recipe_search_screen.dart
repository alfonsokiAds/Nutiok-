import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutiok_app/app_theme.dart';
import 'package:nutiok_app/widgets/bottom_nav_bar.dart';
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
  final String _selectedCategory = 'Todas';

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
      if (provider.recipes.isEmpty) {
        provider.loadRecipes();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Desayuno':
        return const Color(0xFFFF9800);
      case 'Almuerzo':
        return const Color(0xFF2E7D32);
      case 'Cena':
        return const Color(0xFF5C6BC0);
      case 'Snack':
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF78909C);
    }
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return const Color(0xFF2E7D32);
      case 'media':
        return const Color(0xFFFF6B35);
      case 'dificil':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  String _difficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return 'Fácil';
      case 'media':
        return 'Media';
      case 'dificil':
        return 'Difícil';
      default:
        return difficulty;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Desayuno':
        return Icons.wb_sunny_rounded;
      case 'Almuerzo':
        return Icons.restaurant_rounded;
      case 'Cena':
        return Icons.nightlight_rounded;
      case 'Snack':
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant_menu_rounded;
    }
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    List<Recipe> filtered = recipes;

    if (_selectedCategory != 'Todas') {
      filtered = filtered
          .where((r) =>
              r.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.ingredients.any((i) => i.toLowerCase().contains(query)))
          .toList();
    }

    return filtered;
  }

  void _showSuggestRecipeDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sugerir Receta',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D32),
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la receta',
                    prefixIcon: Icon(Icons.title_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre de la receta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_rounded),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Receta sugerida con éxito! 🎉'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Sugerir',
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
        automaticallyImplyLeading: false,
        title: Text(
          'Recetario',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E7D32),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar recetas...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFFF6B35),
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
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

          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcon(category),
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Recipes list
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron recetas',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Intenta con otra búsqueda'
                              : '¡Agrega una nueva receta!',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    final isFavorite = provider.isRecipeFavorite(recipe.id);

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
                              // Recipe image / color block
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: Container(
                                  width: 110,
                                  height: 120,
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
                                                _categoryColor(recipe.category)
                                                    .withValues(alpha: 0.6),
                                          ),
                                        )
                                      : null,
                                ),
                              ),

                              // Recipe info
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Recipe name
                                      Text(
                                        recipe.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),

                                      // Category label
                                      Row(
                                        children: [
                                          Icon(
                                            _categoryIcon(recipe.category),
                                            size: 14,
                                            color:
                                                _categoryColor(recipe.category),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            recipe.category,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: _categoryColor(
                                                  recipe.category),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Difficulty badge, time, favorite
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                // Difficulty badge
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _difficultyColor(recipe.difficulty)
                                                        .withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    _difficultyLabel(recipe.difficulty),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: _difficultyColor(recipe.difficulty),
                                                    ),
                                                  ),
                                                ),
                                                // Prep time
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.schedule_rounded,
                                                      size: 13,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      recipe.prepTime,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Favorite heart
                                          GestureDetector(
                                            onTap: () {
                                              provider.toggleRecipeFavorite(recipe.id);
                                            },
                                            child: AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 250),
                                              child: Icon(
                                                isFavorite
                                                    ? Icons.favorite_rounded
                                                    : Icons.favorite_border_rounded,
                                                size: 22,
                                                color: isFavorite
                                                    ? const Color(0xFFFF6B35)
                                                    : Colors.grey.shade400,
                                                key: ValueKey(isFavorite),
                                              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSuggestRecipeDialog,
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'Sugerir',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
