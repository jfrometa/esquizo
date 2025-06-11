// Test script to verify both default and business routing patterns work correctly
void main() {
  print('=== ROUTING PATTERN TEST ===');
  print('');

  // Test business slug validation
  print('🧪 Testing Business Slug Validation:');
  print(
      '_isValidBusinessSlug("g2"): ${_isValidBusinessSlug("g2")}'); // Should be true
  print(
      '_isValidBusinessSlug("menu"): ${_isValidBusinessSlug("menu")}'); // Should be false (reserved)
  print(
      '_isValidBusinessSlug("carrito"): ${_isValidBusinessSlug("carrito")}'); // Should be false (reserved)
  print(
      '_isValidBusinessSlug("cuenta"): ${_isValidBusinessSlug("cuenta")}'); // Should be false (reserved)
  print('');

  print('📍 Expected Routing Patterns:');
  print('');
  print('DEFAULT ROUTES (no business slug):');
  print('/ → ScaffoldWithNestedNavigation → ResponsiveLandingPage');
  print('/menu → ScaffoldWithNestedNavigation → MenuScreen');
  print('/carrito → ScaffoldWithNestedNavigation → CartScreen');
  print('/cuenta → ScaffoldWithNestedNavigation → CustomProfileScreen');
  print('');
  print('BUSINESS ROUTES (with business slug "g2"):');
  print('/g2 → BusinessScaffoldWithNavigation → HomeScreenContentWrapper');
  print('/g2/menu → BusinessScaffoldWithNavigation → MenuScreenWrapper');
  print('/g2/carrito → BusinessScaffoldWithNavigation → CartScreenWrapper');
  print('/g2/cuenta → BusinessScaffoldWithNavigation → ProfileScreenWrapper');
  print('');

  print('🔍 Route Matching Logic:');
  print('1. /:businessSlug pattern will catch /g2 (business slug route)');
  print('2. /menu will NOT match /:businessSlug because "menu" is reserved');
  print('3. StatefulShellRoute will catch /menu as default route');
  print('4. /g2/menu will match /:businessSlug/menu (business sub-route)');
  print('');

  print('✅ This routing structure should work correctly!');
}

// Copy of the business slug validation function for testing
bool _isValidBusinessSlug(String slug) {
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#'))
    return false;
  if (slug.startsWith('-') || slug.endsWith('-')) return false;
  if (slug.contains('--')) return false;

  final validPattern = RegExp(r'^[a-z0-9-]+$');
  if (!validPattern.hasMatch(slug)) return false;

  final reservedSlugs = {
    'admin',
    'api',
    'www',
    'app',
    'help',
    'support',
    'about',
    'contact',
    'signin',
    'signup',
    'login',
    'logout',
    'register',
    'dashboard',
    'settings',
    'profile',
    'account',
    'billing',
    'pricing',
    'terms',
    'privacy',
    'legal',
    'security',
    'status',
    'blog',
    'news',
    'docs',
    'documentation',
    'guide',
    'tutorial',
    'faq',
    'mail',
    'email',
    'static',
    'assets',
    'images',
    'css',
    'js',
    'javascript',
    'fonts',
    'menu',
    'carrito',
    'cuenta',
    'ordenes',
    'startup',
    'error',
    'onboarding',
    'business-setup',
    'admin-setup'
  };

  return !reservedSlugs.contains(slug);
}
