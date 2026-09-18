import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutiok_app/app_theme.dart';

/// Pantalla de onboarding / bienvenida
/// Sprint 3: Tutorial introductorio de 3 páginas con animaciones
/// Al completarse, guarda una bandera en SharedPreferences y navega a LoginScreen
class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with TickerProviderStateMixin {
  // Controlador del PageView
  final PageController _pageController = PageController();

  // Página actual
  int _currentPage = 0;
  static const int _totalPages = 3;

  // Animación para los indicadores de puntos
  late AnimationController _dotAnimationController;

  // Animación de entrada para los elementos de cada página
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  // Datos de cada página del onboarding
  final List<Map<String, dynamic>> _pages = const [
    {
      'title': 'Bienvenido a NUTIOK',
      'subtitle': 'Tu compañero nutricional inteligente',
      'description':
          'Descubre una nueva forma de cuidar tu alimentación. NUTIOK te ayuda a planificar comidas, seguir tu progreso nutricional y encontrar opciones saludables cerca de ti.',
      'icon': Icons.restaurant_menu_rounded,
      'iconBackground': Color(0xFF2E7D32),
      'illustrationColor': Color(0xFFE8F5E9),
      'emoji': '🍎🥗🥑',
    },
    {
      'title': 'Planifica tus Comidas',
      'subtitle': 'Organiza tu día de forma saludable',
      'description':
          'Crea horarios personalizados para tus comidas del día. Recibe recordatorios inteligentes para desayuno, almuerzo, merienda y cena. Nunca más te saltes una comida importante.',
      'icon': Icons.schedule_rounded,
      'iconBackground': Color(0xFFFF6B35),
      'illustrationColor': Color(0xFFFFF3E0),
      'emoji': '⏰🍽️📋',
    },
    {
      'title': 'Mejora tu Nutrición',
      'subtitle': 'Monitorea y optimiza tu alimentación',
      'description':
          'Lleva un registro detallado de tu peso, altura e IMC. Encuentra restaurantes saludables cerca de ti y accede a recetas nutritivas. Tu bienestar es nuestra prioridad.',
      'icon': Icons.favorite_rounded,
      'iconBackground': Color(0xFFE53935),
      'illustrationColor': Color(0xFFFFEBEE),
      'emoji': '💪❤️📈',
    },
  ];

  @override
  void initState() {
    super.initState();
    _dotAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Iniciar la animación inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dotAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  /// Navega a la siguiente página o completa el onboarding
  Future<void> _nextPage() async {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await _completeOnboarding();
    }
  }

  /// Salta el onboarding y va directamente al login
  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
  }

  /// Completa el onboarding: guarda la bandera y navega al LoginScreen
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Maneja el cambio de página
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Reiniciar y reproducir la animación de entrada
    _slideAnimationController.reset();
    _slideAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Botón Saltar (solo en las primeras páginas) ──
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                  ),
                  child: Text(
                    'Saltar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NutiokTheme.primaryGreen.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView con las 3 páginas ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(index, screenSize);
                },
              ),
            ),

            // ── Indicadores de puntos ──
            _buildPageIndicators(),

            const SizedBox(height: 24),

            // ── Botón Siguiente / Comenzar ──
            _buildActionButton(isLastPage),

            const SizedBox(height: 16),

            // ── Texto inferior ──
            if (!isLastPage)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '${_currentPage + 1} de $_totalPages',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              )
            else
              const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Página individual del onboarding
  // ─────────────────────────────────────────
  Widget _buildOnboardingPage(int index, Size screenSize) {
    final page = _pages[index];
    final isActive = index == _currentPage;

    return SlideTransition(
      position: _slideAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

              // ── Ilustración principal ──
              _buildIllustration(page, screenSize, isActive),

              const SizedBox(height: 36),

              // ── Título ──
              Text(
                page['title'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: NutiokTheme.primaryGreen,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // ── Subtítulo ──
              Text(
                page['subtitle'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: NutiokTheme.primaryOrange,
                ),
              ),

              const SizedBox(height: 20),

              // ── Descripción ──
              Text(
                page['description'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
  /// Construye la ilustración decorativa para cada página
  Widget _buildIllustration(
    Map<String, dynamic> page,
    Size screenSize,
    bool isActive,
  ) {
    final icon = page['icon'] as IconData;
    final bgColor = page['illustrationColor'] as Color;
    final iconBgColor = page['iconBackground'] as Color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      width: screenSize.width * 0.72,
      height: screenSize.width * 0.55,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: iconBgColor.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -20,
            right: -20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: isActive ? 100 : 80,
              height: isActive ? 100 : 80,
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            left: -15,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: isActive ? 80 : 60,
              height: isActive ? 80 : 60,
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: isActive ? 50 : 40,
              height: isActive ? 50 : 40,
              decoration: BoxDecoration(
                color: NutiokTheme.primaryOrange.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Emoji decorativo
          Positioned(
            top: 16,
            left: 16,
            child: Text(
              page['emoji'] as String,
              style: const TextStyle(fontSize: 18),
            ),
          ),

          // Ícono principal central
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              width: isActive ? 110 : 95,
              height: isActive ? 110 : 95,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconBgColor,
                    iconBgColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconBgColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: isActive ? 50 : 42,
                color: Colors.white,
              ),
            ),
          ),

          // Elemento decorativo inferior
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'NUTIOK',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: NutiokTheme.primaryGreen,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Indicadores de página (dots)
  // ─────────────────────────────────────────
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        final isActive = index == _currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isActive
                ? NutiokTheme.primaryGreen
                : NutiokTheme.primaryGreen.withValues(alpha: 0.2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: NutiokTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Botón de acción (Siguiente / Comenzar)
  // ─────────────────────────────────────────
  Widget _buildActionButton(bool isLastPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isLastPage
              ? NutiokTheme.greenGradient
              : NutiokTheme.orangeGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (isLastPage
                      ? NutiokTheme.primaryGreen
                      : NutiokTheme.primaryOrange)
                  .withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _nextPage,
            splashColor: Colors.white.withValues(alpha: 0.2),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage ? 'Comenzar' : 'Siguiente',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!isLastPage)
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
