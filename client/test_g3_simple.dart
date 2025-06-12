void main() {
  print('Testing g3 validation...');
  final isValid = _isValidBusinessSlug('g3');
  print('g3 is ${isValid ? 'VALID' : 'INVALID'}');
  
  print('\nTesting kako validation...');
  final isKakoValid = _isValidBusinessSlug('kako');
  print('kako is ${isKakoValid ? 'VALID' : 'INVALID'}');
}

bool _isValidBusinessSlug(String slug) {
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#')) return false;
  if (slug.startsWith('-') || slug.endsWith('-')) return false;
  if (slug.contains('--')) return false;

  final validPattern = RegExp(r'^[a-z0-9-]+\$');
  if (!validPattern.hasMatch(slug)) return false;

  final reservedSlugs = {
    'admin', 'api', 'www', 'app', 'help', 'support', 'about', 'contact',
    'signin', 'signup', 'login', 'logout', 'register', 'dashboard', 'settings',
    'profile', 'account', 'billing', 'pricing', 'terms', 'privacy', 'legal',
    'security', 'status', 'blog', 'news', 'docs', 'documentation', 'guide',
    'tutorial', 'faq', 'mail', 'email', 'static', 'assets', 'images', 'css',
    'js', 'javascript', 'fonts', 'menu', 'carrito', 'cuenta', 'ordenes',
    'startup', 'error', 'onboarding', 'business-setup', 'admin-setup'
  };

  return !reservedSlugs.contains(slug);
}
