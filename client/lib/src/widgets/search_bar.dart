import 'dart:async';

import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({
    super.key,
    required this.search,
  });
  final Function(String) search;

  @override
  ConsumerState createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  Timer? _debounce;

  _debounceSearch(String search) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.search(search);
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: customAppTheme.colorsPalette.secondary7,
        ),
        child: TextField(
          onChanged: (search) => _debounceSearch(search),
          cursorColor: customAppTheme.colorsPalette.primary,
          textAlign: TextAlign.center,
          style: customAppTheme.textStyles.headlineLarge.copyWith(
            height: 1.6,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintStyle: customAppTheme.textStyles.headlineLarge.copyWith(
              height: 1.6,
              fontSize: 14,
              color: customAppTheme.colorsPalette.secondary40,
            ),
            hintText: 'search.placeholder'.t(),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
