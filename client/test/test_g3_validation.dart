// Test the business slug validation for 'g3'
bool isValidBusinessSlug(String slug) {
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#')) {
    return false;
  }
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

void main() {
  print('Testing g3 slug validation:');
  print('g3 is valid: ${isValidBusinessSlug('g3')}');
  print('Length: ${'g3'.length}');
  print('Pattern match: ${RegExp(r'^[a-z0-9-]+$').hasMatch('g3')}');
  print('Reserved check: ${!{'admin', 'menu', 'carrito'}.contains('g3')}');

  // Test other potential issues
  print('\nAdditional tests:');
  print('Empty string: ${isValidBusinessSlug('')}');
  print('Single char: ${isValidBusinessSlug('a')}');
  print('menu (reserved): ${isValidBusinessSlug('menu')}');
  print('admin (reserved): ${isValidBusinessSlug('admin')}');
  print('kako: ${isValidBusinessSlug('kako')}');
}
