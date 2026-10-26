import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nutiok_app/app_theme.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();

  bool _emailSent = false;
  String _sentToEmail = '';
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validateToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el código o token de verificación';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La nueva contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
    if (!regex.hasMatch(value)) {
      return 'Debe incluir mayúsculas, minúsculas, números y símbolos';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu nueva contraseña';
    }
    if (value != _newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _sendResetEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.resetPassword(email: email);

    if (!mounted) return;

    if (success) {
      setState(() {
        _emailSent = true;
        _sentToEmail = email;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Correo enviado! Ingresa el código recibido para continuar.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: NutiokTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      String errorMessage = authProvider.errorMessage ??
          'No se pudo enviar el correo de recuperación. Verifica la dirección.';
      if (errorMessage.toLowerCase().contains('rate limit')) {
        errorMessage =
            'Límite de envíos de Supabase alcanzado (máx. 3 por hora). Puedes usar el código o enlace que ya recibiste antes haciendo clic abajo.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _verifyAndResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.verifyRecoveryOtpAndSetNewPassword(
      email: _sentToEmail,
      token: _tokenController.text.trim(),
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: NutiokTheme.primaryGreen, size: 28),
              const SizedBox(width: 8),
              Text(
                '¡Éxito!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Tu contraseña ha sido restablecida correctamente. Ya puedes ingresar con tu nueva clave.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NutiokTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: Text(
                'Ir al Inicio',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      final errorMessage = authProvider.errorMessage ??
          'No se pudo verificar el código o cambiar la contraseña.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: Text(
          _emailSent ? 'Nueva Contraseña' : 'Recuperar Contraseña',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NutiokTheme.primaryOrange,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: NutiokTheme.primaryOrange,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Cabecera Naranja ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NutiokTheme.primaryOrange,
                  Color(0xFFFF8F5E),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _emailSent
                        ? Icons.password_rounded
                        : Icons.lock_reset_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _emailSent
                      ? 'Paso 2: Código y Nueva Clave'
                      : '¿Olvidaste tu contraseña?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _emailSent
                      ? 'Ingresa el código que enviamos a:\n$_sentToEmail'
                      : 'Ingresa tu correo registrado para enviarte el código de verificación.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // ── Cuerpo del formulario ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: _emailSent ? _buildResetForm() : _buildEmailForm(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Paso 1: Pedir Correo ──
  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Correo electrónico',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetEmail(),
            decoration: InputDecoration(
              hintText: 'ejemplo@universidad.edu.co',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: NutiokTheme.primaryOrange,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: NutiokTheme.primaryOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: NutiokTheme.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Te enviaremos un código de seguridad para confirmar tu identidad antes de cambiar la contraseña.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _sendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutiokTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'ENVIAR CÓDIGO',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              final email = _emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Por favor ingresa primero tu correo arriba',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              setState(() {
                _emailSent = true;
                _sentToEmail = email;
              });
            },
            icon: const Icon(Icons.key_rounded, size: 18, color: NutiokTheme.primaryOrange),
            label: Text(
              'Ya tengo un código o correo anterior',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: NutiokTheme.primaryOrange,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: NutiokTheme.primaryOrange, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Volver al inicio de sesión',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NutiokTheme.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Paso 2: Pedir Código OTP + Nueva Contraseña ──
  Widget _buildResetForm() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo Código / Token
          Text(
            'Código de verificación o Token',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _tokenController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Ingresa el código recibido en tu correo',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.pin_outlined,
                color: NutiokTheme.primaryOrange,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: NutiokTheme.primaryOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: _validateToken,
          ),
          const SizedBox(height: 18),

          // Campo Nueva Contraseña
          Text(
            'Nueva contraseña',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Mínimo 8 caracteres',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: NutiokTheme.primaryOrange,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: NutiokTheme.primaryOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: _validateNewPassword,
          ),
          const SizedBox(height: 18),

          // Campo Confirmar Contraseña
          Text(
            'Confirmar nueva contraseña',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _verifyAndResetPassword(),
            decoration: InputDecoration(
              hintText: 'Repite tu nueva contraseña',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: NutiokTheme.primaryOrange,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: NutiokTheme.primaryOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 18),

          // Requisitos de contraseña
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requisitos de la contraseña:',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                _buildRequirement('Mínimo 8 caracteres'),
                _buildRequirement('Mayúsculas, minúsculas, números y símbolos'),
                _buildRequirement('Las contraseñas deben coincidir'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botón de acción
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      authProvider.isLoading ? null : _verifyAndResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutiokTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'ESTABLECER NUEVA CONTRASEÑA',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _emailSent = false;
                  _tokenController.clear();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                });
              },
              child: Text(
                '¿No recibiste el código? Reenviar o cambiar correo',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: NutiokTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: NutiokTheme.primaryGreen,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
