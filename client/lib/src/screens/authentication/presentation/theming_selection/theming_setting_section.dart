import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/firebase_auth_repository.dart'; 
import 'package:starter_architecture_flutter_firebase/src/core/providers/user_preference/user_preference_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class ThemeSettingsSection extends ConsumerWidget {
  const ThemeSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeProvider);
    final user = ref.watch(firebaseAuthProvider).currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferencias de Tema',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Theme mode selector
            _buildThemeModeSelector(context, ref, currentThemeMode),
            
            const SizedBox(height: 24),
            
            // Theme mode details
            _buildThemeModeDetails(context, currentThemeMode),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentThemeMode,
  ) {
    return Center(
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
            label: Text('Claro'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.system,
            icon: Icon(Icons.smartphone),
            label: Text('Sistema'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
            label: Text('Oscuro'),
          ),
        ],
        selected: {currentThemeMode},
        onSelectionChanged: (Set<ThemeMode> selection) {
          _updateThemeMode(ref, selection.first);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return Colors.transparent;
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.white;
              }
              return Theme.of(context).colorScheme.onSurface;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeDetails(BuildContext context, ThemeMode themeMode) {
    final theme = Theme.of(context);
    
    IconData icon;
    String title;
    String description;
    
    switch (themeMode) {
      case ThemeMode.light:
        icon = Icons.light_mode;
        title = 'Tema Claro';
        description = 'Utiliza el tema claro independientemente de la configuración del sistema.';
        break;
      case ThemeMode.dark:
        icon = Icons.dark_mode;
        title = 'Tema Oscuro';
        description = 'Utiliza el tema oscuro independientemente de la configuración del sistema.';
        break;
      case ThemeMode.system:
      default:
        icon = Icons.smartphone;
        title = 'Tema del Sistema';
        description = 'Cambia entre tema claro y oscuro automáticamente según la configuración de tu dispositivo.';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateThemeMode(WidgetRef ref, ThemeMode themeMode) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;
    
    try {
      final themeNotifier = ref.read(themeProvider.notifier);
      await themeNotifier.setThemeMode(themeMode);
    } catch (e) {
      debugPrint('Error updating theme mode: $e');
    }
  }
}
