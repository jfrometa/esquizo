import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme mode state provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Read theme preference from local storage if available
  // For now, default to system
  return ThemeMode.system;
});

class ThemeSwitch extends ConsumerWidget {
  final bool showLabel;
  
  const ThemeSwitch({
    super.key,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            _getThemeModeLabel(themeMode),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
        ],
        
        IconButton(
          icon: Icon(_getThemeModeIcon(themeMode)),
          tooltip: 'Toggle theme',
          onPressed: () => _toggleTheme(ref, themeMode),
        ),
      ],
    );
  }
  
  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
  
  void _toggleTheme(WidgetRef ref, ThemeMode currentMode) {
    ThemeMode newMode;
    
    switch (currentMode) {
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
    }
    
    ref.read(themeModeProvider.notifier).state = newMode;
    
    // Save theme preference to local storage
    _saveThemePreference(newMode);
  }
  
  Future<void> _saveThemePreference(ThemeMode mode) async {
    // Implement saving to local storage
    // This would typically use SharedPreferences
    // For example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('theme_mode', mode.toString());
  }
}

// ThemeData provider for light theme
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.blue,
    // Customize other theme properties as needed
  );
});

// ThemeData provider for dark theme
final darkThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.blue,
    // Customize other theme properties as needed
  );
});

// Theme configuration wrapper widget
class ThemeConfigWrapper extends ConsumerWidget {
  final Widget child;
  
  const ThemeConfigWrapper({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    
    return MaterialApp.router(
      title: 'Business Admin',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      // Add your router configuration here
      routerConfig: null, // Replace with your GoRouter configuration
    );
  }
}

// Extension to improve theme switching UX with animation
class ThemeSwitchAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  
  const ThemeSwitchAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: Theme.of(context),
      duration: duration,
      child: child,
    );
  }
}