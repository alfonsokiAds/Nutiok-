import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nutiok_app/app_theme.dart';
import 'package:nutiok_app/widgets/bottom_nav_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reminders_provider.dart';
import '../../models/user.dart';

/// Pantalla de perfil del usuario
/// Sprint 3 - HU-8: Gestión de perfil y datos nutricionales
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para campos editables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Estado del formulario
  String? _selectedGender;
  String? _selectedDietaryGoal;

  // Control de expandibles
  bool _privacyExpanded = false;
  bool _accessibilityExpanded = false;

  // Configuración de privacidad
  bool _shareDataWithTrainers = false;
  bool _anonymousStatistics = true;
  bool _showProfilePublicly = false;

  // Configuración de accesibilidad
  bool _highContrastMode = false;
  bool _largeTextMode = false;
  bool _hapticFeedback = true;

  // Estado de carga
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  /// Carga los datos del usuario actual en los controladores
  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _weightController.text = user.weight?.toStringAsFixed(1) ?? '';
      _heightController.text = user.height?.toStringAsFixed(0) ?? '';
      _selectedGender = user.gender;
      _selectedDietaryGoal = user.dietaryGoal;
    }
  }

  /// Calcula el IMC a partir del peso y la altura ingresados
  double? _calculateBMI() {
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final heightText = _heightController.text.trim().replaceAll(',', '.');

    if (weightText.isEmpty || heightText.isEmpty) return null;

    final weight = double.tryParse(weightText);
    final heightCm = double.tryParse(heightText);

    if (weight == null || heightCm == null || heightCm <= 0) return null;

    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  /// Retorna el color según el rango del IMC
  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF2196F3); // Azul - Bajo peso
    if (bmi < 25) return NutiokTheme.primaryGreen; // Verde - Normal
    if (bmi < 30) return NutiokTheme.primaryOrange; // Naranja - Sobrepeso
    return NutiokTheme.accentRed; // Rojo - Obesidad
  }

  /// Retorna la categoría del IMC en español
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  /// Retorna la descripción del IMC
  String _getBMIDescription(double bmi) {
    if (bmi < 18.5) return 'Tu peso está por debajo del rango saludable';
    if (bmi < 25) return '¡Estás en un rango de peso saludable!';
    if (bmi < 30) {
      return 'Tu peso está ligeramente por encima del rango saludable';
    }
    return 'Tu peso está significativamente por encima del rango saludable';
  }

  /// Extrae las iniciales del nombre del usuario
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Guarda los cambios del perfil
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      setState(() => _isSaving = false);
      return;
    }

    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final heightText = _heightController.text.trim().replaceAll(',', '.');
    final weight = double.tryParse(weightText);
    final heightCm = double.tryParse(heightText);
    final bmi = (weight != null && heightCm != null && heightCm > 0)
        ? weight / ((heightCm / 100) * (heightCm / 100))
        : null;

    final updatedProfile = currentUser.copyWith(
      fullName: _nameController.text.trim(),
      weight: weight,
      height: heightCm,
      gender: _selectedGender,
      dietaryGoal: _selectedDietaryGoal,
    );

    // Si se calculó un BMI nuevo, lo asignamos manualmente
    final profileWithBmi = bmi != null
        ? UserModel(
            id: updatedProfile.id,
            email: updatedProfile.email,
            fullName: updatedProfile.fullName,
            age: updatedProfile.age,
            weight: updatedProfile.weight,
            height: updatedProfile.height,
            bmi: bmi,
            gender: updatedProfile.gender,
            dietaryGoal: updatedProfile.dietaryGoal,
            createdAt: updatedProfile.createdAt,
            updatedAt: updatedProfile.updatedAt,
          )
        : updatedProfile;

    final success = await authProvider.updateProfile(profileWithBmi);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Perfil actualizado exitosamente'),
          backgroundColor: NutiokTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Error al guardar los cambios',
          ),
          backgroundColor: NutiokTheme.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Cierra la sesión del usuario
  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: NutiokTheme.primaryGreen,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cerrar Sesión',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NutiokTheme.accentRed,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<RemindersProvider>().clear();
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  /// Navega a la pantalla de cambio de contraseña
  void _navigateToChangePassword() {
    Navigator.pushNamed(context, '/change-password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutiokTheme.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: NutiokTheme.primaryGreen,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── Avatar con iniciales y botón de edición ──
                _buildAvatarSection(user),

                const SizedBox(height: 24),

                // ── Información del usuario ──
                _buildUserInfoSection(user),

                const SizedBox(height: 20),

                // ── Tarjeta de Datos Nutricionales ──
                _buildNutritionalDataCard(),

                const SizedBox(height: 16),

                // ── Selector de Género ──
                _buildGenderSelector(),

                const SizedBox(height: 16),

                // ── Selector de Objetivo Dietético ──
                _buildDietaryGoalSelector(),

                const SizedBox(height: 24),

                // ── Botón Guardar Cambios ──
                _buildSaveButton(),

                const SizedBox(height: 12),

                // ── Link Cambiar Contraseña ──
                _buildChangePasswordLink(),

                const SizedBox(height: 20),

                // ── Tarjeta Expandible: Privacidad ──
                _buildPrivacyCard(),

                const SizedBox(height: 12),

                // ── Tarjeta Expandible: Accesibilidad ──
                _buildAccessibilityCard(),

                const SizedBox(height: 24),

                // ── Botón Cerrar Sesión ──
                _buildSignOutButton(),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Avatar
  // ─────────────────────────────────────────
  Widget _buildAvatarSection(UserModel? user) {
    final initials = _getInitials(user?.fullName);
    final hasInitials = initials.isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La carga de foto de perfil estará disponible en futuras actualizaciones.'),
              backgroundColor: NutiokTheme.primaryOrange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Stack(
          children: [
            // Círculo exterior decorativo
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: NutiokTheme.primaryGreen.withValues(alpha: 0.2),
                  width: 3,
                ),
              ),
            ),
            // Avatar principal
            Positioned(
              left: 5,
              top: 5,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: NutiokTheme.greenGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: NutiokTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: hasInitials
                      ? Text(
                          initials,
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
            // Botón de edición (lápiz)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: NutiokTheme.primaryOrange,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NutiokTheme.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Información del usuario
  // ─────────────────────────────────────────
  Widget _buildUserInfoSection(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NutiokTheme.cardDecoration,
      child: Column(
        children: [
          // Nombre
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NutiokTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: NutiokTheme.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.fullName ?? 'Sin nombre',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),
          // Correo electrónico
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NutiokTheme.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: NutiokTheme.primaryOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correo electrónico',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'Sin correo',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Datos Nutricionales (IMC)
  // ─────────────────────────────────────────
  Widget _buildNutritionalDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: NutiokTheme.greenGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: NutiokTheme.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la tarjeta
          Row(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Datos Nutricionales',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Campos de peso y altura en fila
          Row(
            children: [
              // Campo de peso
              Expanded(
                child: _buildNutritionalField(
                  label: 'Peso',
                  hint: '70.0',
                  unit: 'kg',
                  controller: _weightController,
                  icon: Icons.monitor_weight_outlined,
                  onChanged: () => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              // Campo de altura
              Expanded(
                child: _buildNutritionalField(
                  label: 'Altura',
                  hint: '170',
                  unit: 'cm',
                  controller: _heightController,
                  icon: Icons.height_rounded,
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // IMC calculado
          _buildBMIDisplay(),
        ],
      ),
    );
  }

  /// Campo individual dentro de la tarjeta de datos nutricionales
  Widget _buildNutritionalField({
    required String label,
    required String hint,
    required String unit,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Muestra el IMC calculado con indicador de color
  Widget _buildBMIDisplay() {
    final bmi = _calculateBMI();

    if (bmi == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ingresa tu peso y altura para calcular tu IMC',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bmiColor = _getBMIColor(bmi);
    final category = _getBMICategory(bmi);
    final description = _getBMIDescription(bmi);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Indicador circular de IMC
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bmiColor.withValues(alpha: 0.12),
              border: Border.all(color: bmiColor, width: 3),
            ),
            child: Center(
              child: Text(
                bmi.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: bmiColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Información del IMC
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'IMC: ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: bmiColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: bmiColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
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

  // ─────────────────────────────────────────
  // SECCIÓN: Selector de Género
  // ─────────────────────────────────────────
  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NutiokTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wc_rounded,
                color: NutiokTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Género',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  label: 'Masculino',
                  icon: Icons.male_rounded,
                  isSelected: _selectedGender == 'Masculino',
                  onTap: () => setState(() => _selectedGender = 'Masculino'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption(
                  label: 'Femenino',
                  icon: Icons.female_rounded,
                  isSelected: _selectedGender == 'Femenino',
                  onTap: () => setState(() => _selectedGender = 'Femenino'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Opción individual de género
  Widget _buildGenderOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? NutiokTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? NutiokTheme.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  isSelected ? NutiokTheme.primaryGreen : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? NutiokTheme.primaryGreen
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Selector de Objetivo Dietético
  // ─────────────────────────────────────────
  Widget _buildDietaryGoalSelector() {
    final goals = [
      {
        'value': 'Mantener peso',
        'icon': Icons.balance_rounded,
        'color': NutiokTheme.primaryGreen
      },
      {
        'value': 'Bajar peso',
        'icon': Icons.trending_down_rounded,
        'color': NutiokTheme.primaryOrange
      },
      {
        'value': 'Subir peso',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF1976D2)
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NutiokTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.track_changes_rounded,
                color: NutiokTheme.primaryOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Objetivo Nutricional',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...goals.map((goal) {
            final isSelected = _selectedDietaryGoal == goal['value'];
            final color = goal['color'] as Color;
            final icon = goal['icon'] as IconData;
            final label = goal['value'] as String;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedDietaryGoal = label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected ? color : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? color : Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: color,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Botón Guardar
  // ─────────────────────────────────────────
  Widget _buildSaveButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: NutiokTheme.greenGradient,
        borderRadius: BorderRadius.circular(NutiokTheme.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: NutiokTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutiokTheme.buttonRadius),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Guardar Cambios',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Link Cambiar Contraseña
  // ─────────────────────────────────────────
  Widget _buildChangePasswordLink() {
    return TextButton.icon(
      onPressed: _navigateToChangePassword,
      icon: const Icon(Icons.lock_outline_rounded, size: 18),
      label: Text(
        'Cambiar Contraseña',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: NutiokTheme.primaryGreen,
          decoration: TextDecoration.underline,
          decorationColor: NutiokTheme.primaryGreen.withValues(alpha: 0.5),
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: NutiokTheme.primaryGreen,
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Tarjeta Expandible - Privacidad
  // ─────────────────────────────────────────
  Widget _buildPrivacyCard() {
    return Container(
      decoration: NutiokTheme.cardDecoration,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (expanded) {
            setState(() => _privacyExpanded = expanded);
          },
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: NutiokTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: NutiokTheme.primaryGreen,
              size: 20,
            ),
          ),
          title: Text(
            'Privacidad',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            _privacyExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey.shade500,
          ),
          children: [
            _buildPrivacyToggle(
              label: 'Compartir datos con entrenadores',
              subtitle:
                  'Permitir que los entrenadores vean tus datos nutricionales',
              value: _shareDataWithTrainers,
              onChanged: (val) => setState(() => _shareDataWithTrainers = val),
            ),
            const SizedBox(height: 12),
            _buildPrivacyToggle(
              label: 'Estadísticas anónimas',
              subtitle: 'Ayudar a mejorar la app con datos anónimos de uso',
              value: _anonymousStatistics,
              onChanged: (val) => setState(() => _anonymousStatistics = val),
            ),
            const SizedBox(height: 12),
            _buildPrivacyToggle(
              label: 'Perfil público',
              subtitle: 'Mostrar tu perfil a otros usuarios de NUTIOK',
              value: _showProfilePublicly,
              onChanged: (val) => setState(() => _showProfilePublicly = val),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle individual de privacidad
  Widget _buildPrivacyToggle({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: NutiokTheme.primaryGreen,
          activeTrackColor: NutiokTheme.primaryGreen.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Tarjeta Expandible - Accesibilidad
  // ─────────────────────────────────────────
  Widget _buildAccessibilityCard() {
    return Container(
      decoration: NutiokTheme.cardDecoration,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (expanded) {
            setState(() => _accessibilityExpanded = expanded);
          },
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: NutiokTheme.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.accessibility_new_rounded,
              color: NutiokTheme.primaryOrange,
              size: 20,
            ),
          ),
          title: Text(
            'Accesibilidad',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            _accessibilityExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey.shade500,
          ),
          children: [
            _buildAccessibilityToggle(
              label: 'Alto contraste',
              subtitle: 'Aumentar el contraste de colores en la interfaz',
              value: _highContrastMode,
              onChanged: (val) => setState(() => _highContrastMode = val),
            ),
            const SizedBox(height: 12),
            _buildAccessibilityToggle(
              label: 'Texto grande',
              subtitle: 'Aumentar el tamaño de fuente en toda la app',
              value: _largeTextMode,
              onChanged: (val) => setState(() => _largeTextMode = val),
            ),
            const SizedBox(height: 12),
            _buildAccessibilityToggle(
              label: 'Retroalimentación háptica',
              subtitle: 'Vibración al tocar elementos interactivos',
              value: _hapticFeedback,
              onChanged: (val) => setState(() => _hapticFeedback = val),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle individual de accesibilidad
  Widget _buildAccessibilityToggle({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: NutiokTheme.primaryOrange,
          activeTrackColor: NutiokTheme.primaryOrange.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Botón Cerrar Sesión
  // ─────────────────────────────────────────
  Widget _buildSignOutButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(NutiokTheme.buttonRadius),
        border: Border.all(
          color: NutiokTheme.accentRed,
          width: 1.5,
        ),
      ),
      child: OutlinedButton(
        onPressed: _signOut,
        style: OutlinedButton.styleFrom(
          foregroundColor: NutiokTheme.accentRed,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutiokTheme.buttonRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              'Cerrar Sesión',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: NutiokTheme.accentRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
