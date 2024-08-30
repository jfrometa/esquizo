bool isPasswordValid(String password) {
  return RegExp(
          r'^(?!.*0123)(?!.*1234)(?!.*2345)(?!.*3456)(?!.*4567)(?!.*5678)(?!.*6789)(?!.*([A-Za-z0-9])\1{3})[A-Za-z0-9].{5,}$',)
      .hasMatch(password);
}
