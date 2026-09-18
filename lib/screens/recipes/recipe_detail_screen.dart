import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutiok_app/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../providers/reminders_provider.dart';
import '../../models/recipe.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late List<bool> _checkedIngredients;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _checkedIngredients = List.filled(widget.recipe.ingredients.length, false);
    _isFavorite =
        context.read<RemindersProvider>().isRecipeFavorite(widget.recipe.id);
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
        return 'Facil';
      case 'media':
        return 'Media';
      case 'dificil':
        return 'Dificil';
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image area
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image or colored fallback
                      if (recipe.imageUrl != null &&
                          recipe.imageUrl!.isNotEmpty)
                        Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildColorFallback(recipe),
                        )
                      else
                        _buildColorFallback(recipe),

                      // Gradient overlay for text readability
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black54,
                                ],
                                stops: [0.3, 1.0],
                              ),
                            ),
                            child: SizedBox(height: 140),
                          ),
                        ),
                      ),

                      // Back button
                      Positioned(
                        top: 48,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF2E7D32),
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      // Favorite heart button
                      Positioned(
                        top: 48,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            final provider = context.read<RemindersProvider>();
                            provider.toggleFavorite(recipe.id);
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              _isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _isFavorite
                                  ? const Color(0xFFFF6B35)
                                  : Colors.grey.shade500,
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      // Recipe name overlaid on bottom of image
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 12,
                                    color: Colors.black54,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _difficultyColor(recipe.difficulty),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _difficultyLabel(recipe.difficulty),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Info row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      _buildInfoItem(
                        icon: Icons.people_outline_rounded,
                        label: 'Porciones',
                        value: '${recipe.servings}',
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoItem(
                        icon: Icons.schedule_rounded,
                        label: 'Tiempo',
                        value: recipe.prepTime,
                        color: const Color(0xFFFF6B35),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoItem(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Calorias',
                        value: '${recipe.calories ?? 0} kcal',
                        color: const Color(0xFFD32F2F),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Ingredientes section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_basket_rounded,
                            size: 22,
                            color: const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ingredientes',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${recipe.ingredients.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Checkable ingredient list
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipe.ingredients.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) newIndex -= 1;
                      final item = recipe.ingredients.removeAt(oldIndex);
                      recipe.ingredients.insert(newIndex, item);
                      final checked = _checkedIngredients.removeAt(oldIndex);
                      _checkedIngredients.insert(newIndex, checked);
                    });
                  },
                  buildDefaultDragHandles: false,
                  itemBuilder: (context, index) {
                    final ingredient = recipe.ingredients[index];
                    return Padding(
                      key: ValueKey('ingredient-$index-$ingredient'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 3,
                      ),
                      child: CustomCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _checkedIngredients[index] =
                                      !_checkedIngredients[index];
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _checkedIngredients[index]
                                      ? const Color(0xFF2E7D32)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _checkedIngredients[index]
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: _checkedIngredients[index]
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _checkedIngredients[index]
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                  decoration: _checkedIngredients[index]
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle_rounded,
                                size: 20,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Pasos de Preparacion section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_list_numbered_rounded,
                            size: 22,
                            color: const Color(0xFFFF6B35),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pasos de Preparacion',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${recipe.steps.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF6B35),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Numbered steps
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(recipe.steps.length, (index) {
                      final step = recipe.steps[index];
                      final isLast = index == recipe.steps.length - 1;

                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step number circle
                            Column(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFF6B35),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 24,
                                    color: Colors.orange.shade100,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // Step text
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  step,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

                // Spacing for the bottom button
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bottom favorite button - fixed at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final provider = context.read<RemindersProvider>();
                    provider.toggleFavorite(recipe.id);
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isFavorite
                              ? 'Receta agregada a favoritos!'
                              : 'Receta eliminada de favoritos',
                        ),
                        backgroundColor: _isFavorite
                            ? const Color(0xFFFF6B35)
                            : Colors.grey.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFavorite
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 22,
                  ),
                  label: Text(
                    _isFavorite
                        ? 'Quitar de Favoritas'
                        : 'Marcar como Favorita',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorFallback(Recipe recipe) {
    Color bgColor;
    IconData fallbackIcon;
    switch (recipe.category.toLowerCase()) {
      case 'desayuno':
        bgColor = const Color(0xFFFF9800);
        fallbackIcon = Icons.wb_sunny_rounded;
        break;
      case 'almuerzo':
        bgColor = const Color(0xFF2E7D32);
        fallbackIcon = Icons.restaurant_rounded;
        break;
      case 'cena':
        bgColor = const Color(0xFF5C6BC0);
        fallbackIcon = Icons.nightlight_rounded;
        break;
      case 'snack':
        bgColor = const Color(0xFFFF6B35);
        fallbackIcon = Icons.cookie_rounded;
        break;
      default:
        bgColor = const Color(0xFF78909C);
        fallbackIcon = Icons.restaurant_menu_rounded;
    }

    return Container(
      color: bgColor.withValues(alpha: 0.2),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              fallbackIcon,
              size: 80,
              color: bgColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.category,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: bgColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        borderRadius: 14,
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
