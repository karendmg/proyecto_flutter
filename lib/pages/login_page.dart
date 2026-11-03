import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_flutter/config/router.dart';
import 'package:proyecto_flutter/services/auth_service.dart';
import 'package:proyecto_flutter/utils/validators.dart';
import 'package:proyecto_flutter/widgets/app_primary_button.dart';
import 'package:proyecto_flutter/widgets/app_text_field.dart';

/// Pantalla de inicio de sesión.
///
/// Es un StatefulWidget porque necesita guardar estado:
/// los controladores de los campos y si está cargando.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Key del formulario: permite validar todos los campos desde el botón.
  final _formKey = GlobalKey<FormState>();

  /// Controladores: guardan lo que el usuario escribe.
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  /// Bandera de carga: true mientras se espera respuesta del "servidor".
  bool _loading = false;

  @override
  void dispose() {
    // Liberar los controladores cuando la vista se cierra.
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Se ejecuta al pulsar "Iniciar sesión".
  Future<void> _submit() async {
    // 1. Validar el formulario. Si hay errores, no seguimos.
    if (!_formKey.currentState!.validate()) return;

    // 2. Activar el estado de carga.
    setState(() => _loading = true);

    // 3. Llamar al servicio (simula petición al backend).
    final ok = await AuthService.instance.login(
      _emailCtrl.text,
      _passCtrl.text,
    );

    // 4. Verificar que la pantalla siga montada antes de usar context.
    if (!mounted) return;

    // 5. Desactivar la carga.
    setState(() => _loading = false);

    // 6. Redirigir o mostrar error.
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bienvenido, ${_emailCtrl.text}')));
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Credenciales inválidas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- LOGO ----------
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        // Si no encuentra el logo, muestra un ícono.
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.trending_up,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---------- TÍTULOS ----------
                  Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Inicia sesión con tu cuenta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),

                  // ---------- CAMPOS ----------
                  AppTextField(
                    controller: _emailCtrl,
                    label: 'Correo electrónico',
                    hint: 'nombre@correo.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _passCtrl,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 24),

                  // ---------- BOTÓN ----------
                  AppPrimaryButton(
                    label: 'Iniciar sesión',
                    isLoading: _loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),

                  // ---------- LINK A REGISTRO ----------
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text('¿No tienes cuenta? Regístrate'),
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
