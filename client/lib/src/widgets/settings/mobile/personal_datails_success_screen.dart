import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/update_personal_details_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class PersonalDetailsSuccessScreen extends ConsumerStatefulWidget {
  const PersonalDetailsSuccessScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onButtonPress,
  });

  final String icon;
  final String title;
  final String message;
  final Function? onButtonPress;

  @override
  ConsumerState<PersonalDetailsSuccessScreen> createState() =>
      _PersonalDetailsSuccessScreenState();
}

class _PersonalDetailsSuccessScreenState
    extends ConsumerState<PersonalDetailsSuccessScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return UpdatePersonalDetailsSuccessContent(
      icon: widget.icon,
      message: widget.message,
      title: widget.title,
      onButtonPress: widget.onButtonPress,
    );
  }
}
