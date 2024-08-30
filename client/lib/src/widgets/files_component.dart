import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FilesComponentVariant {
  uploaded,
  approved,
}

class FilesComponent extends ConsumerWidget {
  const FilesComponent({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.variant,
    this.onDelete,
  });
  factory FilesComponent.uploaded(String name, Function() onDelete) {
    return FilesComponent(
      title: name,
      variant: FilesComponentVariant.uploaded,
      onDelete: onDelete,
    );
  }
  final Widget? leading;
  final String title;
  final Widget? trailing;
  final String? subtitle;
  final FilesComponentVariant variant;
  final Function()? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return SizedBox(
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: customAppTheme.colorsPalette.primary7,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              leading != null ? leading! : Container(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: customAppTheme.textStyles.headlineMedium.copyWith(
                        color: _titleColor(customAppTheme),
                      ),
                    ),
                    subtitle != null
                        ? Text(
                            subtitle!,
                            style: customAppTheme.textStyles.bodySmall.copyWith(
                              color: _titleColor(customAppTheme),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              trailing ?? _renderTrailing(customAppTheme),
            ],
          ),
        ),
      ),
    );
  }

  Color _titleColor(CustomAppTheme customAppTheme) {
    switch (variant) {
      case FilesComponentVariant.uploaded:
        return customAppTheme.colorsPalette.primary70;
      case FilesComponentVariant.approved:
        return customAppTheme.colorsPalette.primary;
    }
  }

  Widget _renderTrailing(CustomAppTheme customAppTheme) {
    switch (variant) {
      case FilesComponentVariant.uploaded:
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onDelete,
          child: Icon(
            ThanosIcons.buttonsDelete,
            color: customAppTheme.colorsPalette.negativeAction,
          ),
        );
      case FilesComponentVariant.approved:
        return Container(); //TODO: Update to different variants
    }
  }
}
