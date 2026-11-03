import 'package:flutter/material.dart';
import 'package:proyecto_flutter/services/theme_service.dart';

/// Pantalla de configuración.
/// Permite cambiar entre tema claro y oscuro, y otras opciones.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Estado local de la notificación (solo visual por ahora)
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // ---------- MODO OSCURO ----------
          // Usa ValueListenableBuilder para escuchar los cambios del tema
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.mode,
            builder: (context, mode, _) {
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Modo oscuro'),
                value: mode == ThemeMode.dark,
                onChanged: (_) => ThemeService.toggle(),
              );
            },
          ),

          // ---------- NOTIFICACIONES ----------
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notificaciones'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),

          const Divider(),

          // ---------- INFORMACIÓN ----------
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versión'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.school_outlined),
            title: Text('InverTrack'),
            subtitle: Text('Repositorio de información financiera'),
          ),
        ],
      ),
    );
  }
}
