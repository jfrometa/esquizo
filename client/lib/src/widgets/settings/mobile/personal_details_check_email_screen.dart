import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/personal_details_check_email_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class PersonalDetailsCheckEmailScreen extends ConsumerStatefulWidget {
  const PersonalDetailsCheckEmailScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.email,
  });

  final String icon;
  final String title;
  final String message;
  final String email;

  @override
  ConsumerState<PersonalDetailsCheckEmailScreen> createState() =>
      _PersonalDetailsCheckEmailScreenState();
}

class _PersonalDetailsCheckEmailScreenState
    extends ConsumerState<PersonalDetailsCheckEmailScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return PersonalDetailsCheckEmailScreenContent(
      icon: widget.icon,
      message: widget.message,
      title: widget.title,
      email: widget.email,
    );
  }
}
