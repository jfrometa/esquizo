void main() {
  print('Testing g3 validation step by step...');
  final slug = 'g3';
  
  print('Length check: ${slug.length} (should be >= 2 and <= 50): ${slug.length >= 2 && slug.length <= 50}');
  print('Special chars check: ${!slug.contains(' ') && !slug.contains('?') && !slug.contains('#')}');
  print('Hyphen check: ${!slug.startsWith('-') && !slug.endsWith('-')}');
  print('Double hyphen check: ${!slug.contains('--')}');
  
  final validPattern = RegExp(r'^[a-z0-9-]+$');
  print('Regex pattern check: ${validPattern.hasMatch(slug)}');
  
  final reservedSlugs = {
    'admin', 'api', 'www', 'app', 'help', 'support', 'about', 'contact',
    'signin', 'signup', 'login', 'logout', 'register', 'dashboard', 'settings',
    'profile', 'account', 'billing', 'pricing', 'terms', 'privacy', 'legal',
    'security', 'status', 'blog', 'news', 'docs', 'documentation', 'guide',
    'tutorial', 'faq', 'mail', 'email', 'static', 'assets', 'images', 'css',
    'js', 'javascript', 'fonts', 'menu', 'carrito', 'cuenta', 'ordenes',
    'startup', 'error', 'onboarding', 'business-setup', 'admin-setup'
  };
  
  print('Reserved check: ${!reservedSlugs.contains(slug)}');
  
  print('\n--- Testing kako ---');
  final slug2 = 'kako';
  print('Reserved check for kako: ${!reservedSlugs.contains(slug2)}');
  print('Pattern check for kako: ${validPattern.hasMatch(slug2)}');
}
