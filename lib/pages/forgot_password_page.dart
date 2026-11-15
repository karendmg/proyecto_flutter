import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/router.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/empty_state.dart';

/// Recuperar contraseña: pide el correo, envía el enlace de Firebase y deja
/// reenviarlo (con una espera de 60 s para evitar abusos).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  /// Correo con el que se rellena el campo (el que estaba en el login).
  final String initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const int _cooldownSeconds = 60;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl = TextEditingController(
    text: widget.initialEmail,
  );
  final _auth = AuthService.instance;

  bool _loading = false;
  bool _sent = false;
  String _sentTo = '';
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await _deliver(_emailCtrl.text.trim());
  }

  Future<void> _deliver(String email) async {
    setState(() => _loading = true);
    try {
      await _auth.restablecerContrasena(email);
      if (!mounted) return;
      setState(() {
        _sent = true;
        _sentTo = email;
      });
      _startCooldown();
    } catch (e) {
      if (mounted) _snack(_auth.mensajeErrorRecuperacion(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            AuthHeader(
              title: 'Recupera tu contraseña',
              subtitle: _sent
                  ? 'Ya casi: revisa tu bandeja de entrada.'
                  : 'Escribe tu correo y te enviaremos un enlace para crear una nueva.',
              onBack: _goBack,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: _sent ? _buildSent(context) : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Correo',
            icon: Icons.mail_outline,
            controller: _emailCtrl,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Enviar enlace',
            icon: Icons.send_outlined,
            isLoading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _goBack,
            child: const Text('Volver a iniciar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildSent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Revisa tu correo',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Si $_sentTo tiene una cuenta en InverApp, te enviamos un enlace '
          'para crear una nueva contraseña.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        const InfoBanner(
          icon: Icons.info_outline,
          message:
              '¿No lo ves? Revisa la carpeta de spam o correo no deseado. '
              'Puede tardar unos minutos en llegar.',
        ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          label: 'Volver a iniciar sesión',
          onPressed: _goBack,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: (_cooldown > 0 || _loading)
              ? null
              : () => _deliver(_sentTo),
          child: Text(
            _cooldown > 0
                ? 'Reenviar enlace en ${_cooldown}s'
                : 'Reenviar enlace',
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: const Text('Usar otro correo'),
        ),
      ],
    );
  }
}
