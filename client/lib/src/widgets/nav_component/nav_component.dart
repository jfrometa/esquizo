import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/nav_component/progress_bar_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressData {
  ProgressData({
    required this.currentValue,
    required this.initialInvestment,
    this.forecastValue,
  });

  double initialInvestment;
  double currentValue;
  double? forecastValue;
}

class NavComponent extends ConsumerWidget {
  const NavComponent({
    super.key,
    this.backgroundColor,
    required this.leading,
    required this.title,
    this.description,
    this.leadingBackgroundColor,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.progress,
    this.opacity,
    this.textColor,
  });

  final Color? backgroundColor;
  final Widget leading;
  final String title;
  final String? subtitle;
  final String? description;
  final Color? leadingBackgroundColor;
  final Widget? trailing;
  final Function()? onTap;
  final ProgressData? progress;
  final double? opacity;
  final Color? textColor;

  Widget _buildProgressBar(CustomAppTheme customAppTheme) => progress == null
      ? Container()
      : SizedBox(
          height: 64,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'subscriptions.section.investments.product.current_value',
                    style: customAppTheme.textStyles.bodySmall,
                  ),
                  Text(
                    'subscriptions.section.investments.product.forecast_value',
                    style: customAppTheme.textStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 4,
                child: CustomPaint(
                  foregroundPainter: ProgressBarPainter(
                    backgroundColor: customAppTheme.colorsPalette.ternary20,
                    color: customAppTheme.colorsPalette.primary,
                    progress: 100 *
                        (progress!.currentValue - progress!.initialInvestment) /
                        (progress!.forecastValue ??
                            0 - progress!.initialInvestment),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '€ ${progress!.currentValue}',
                    style: customAppTheme.textStyles.labelMedium.copyWith(
                      color: customAppTheme.colorsPalette.secondary,
                    ),
                  ),
                  progress!.forecastValue != null
                      ? Text(
                          '€ ${progress!.forecastValue}',
                          style: customAppTheme.textStyles.labelMedium.copyWith(
                            color: customAppTheme.colorsPalette.secondary,
                          ),
                        )
                      : const SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(strokeWidth: 1),
                        ),
                ],
              ),
            ],
          ),
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CustomAppTheme customAppTheme = ref.read(appThemeProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? customAppTheme.colorsPalette.primary70,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Opacity(
        opacity: opacity ?? 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: ColoredBox(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 42,
                          width: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              color: leadingBackgroundColor ??
                                  customAppTheme.colorsPalette.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: leading,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: SizedBox(
                              height: 42,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: customAppTheme
                                        .textStyles.headlineLarge
                                        .copyWith(
                                      color: textColor ??
                                          customAppTheme
                                              .colorsPalette.secondary,
                                    ),
                                  ),
                                  subtitle != null
                                      ? Text(
                                          subtitle!,
                                          style: customAppTheme
                                              .textStyles.bodyMedium
                                              .copyWith(
                                            color: customAppTheme
                                                .colorsPalette.secondary40,
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        trailing != null ? trailing! : Container(),
                      ],
                    ),
                    description != null
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 58.0,
                            ),
                            child: Text(
                              description!,
                              style: customAppTheme.textStyles.bodyMedium,
                            ),
                          )
                        : Container(),
                    _buildProgressBar(customAppTheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
