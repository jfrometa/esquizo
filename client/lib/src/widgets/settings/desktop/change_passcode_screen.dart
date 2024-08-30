import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/change_passcode_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class ChangePasscodeScreen extends ConsumerStatefulWidget {
  const ChangePasscodeScreen({super.key});

  @override
  ConsumerState<ChangePasscodeScreen> createState() =>
      _ChangePasscodeScreenState();
}

class _ChangePasscodeScreenState extends ConsumerState<ChangePasscodeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return const ChangePasscodeContent();
  }
}
