import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/update_passcode_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class UpdatePasscodeSuccessMobileScreen extends ConsumerStatefulWidget {
  const UpdatePasscodeSuccessMobileScreen({super.key});

  @override
  ConsumerState<UpdatePasscodeSuccessMobileScreen> createState() =>
      _UpdatePasscodeScreenState();
}

class _UpdatePasscodeScreenState
    extends ConsumerState<UpdatePasscodeSuccessMobileScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return const UpdatePasscodeSuccessContent();
  }
}
