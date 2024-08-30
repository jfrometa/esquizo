bool isReferralCodeValid(String? code) {
  return RegExp(r'^[A-Z]{6}\d{5}$').hasMatch(code ?? '');
}
