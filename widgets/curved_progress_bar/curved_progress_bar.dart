import 'package:starter_architecture_flutter_firebase/helpers/currency_converter.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/curved_progress_bar/curved_progress_bar_painter.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurvedProgressBar extends ConsumerStatefulWidget {
  const CurvedProgressBar({
    super.key,
    required this.currentValue,
    required this.initialInvestment,
    this.forecast,
    required this.currencyCode,
    required this.term,
    this.cancelled = false,
  });

  final double currentValue;
  final double initialInvestment;
  final double? forecast;
  final String? currencyCode;
  final String term;
  final bool cancelled;

  @override
  ConsumerState createState() => _CurvedProgressBarState();
}

class _CurvedProgressBarState extends ConsumerState<CurvedProgressBar> {
  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width,
              child: CustomPaint(
                foregroundPainter: CurvedProgressBarPainter(
                  padding: 5,
                  color: customAppTheme.colorsPalette.primary,
                  progress: widget.forecast != null
                      ? 100 *
                          (widget.currentValue - widget.initialInvestment) /
                          (widget.forecast! - widget.initialInvestment)
                      : 0,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                child: SizedBox(
                  height: 124,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        'subscriptions.section.investments.product.current_value'
                            .t(),
                        style: customAppTheme.textStyles.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.currentValue
                            .convertToCurrency(widget.currencyCode),
                        style: customAppTheme.textStyles.displayLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'subscriptions_investment_movements.values.earned'.t(
                          {
                            'value_earned':
                                (widget.currentValue - widget.initialInvestment)
                                    .convertToCurrency(widget.currencyCode),
                          },
                        ),
                        style:
                            customAppTheme.textStyles.headlineMedium.copyWith(
                          color: widget.cancelled
                              ? customAppTheme.colorsPalette.primary40
                              : customAppTheme.colorsPalette.primary,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'subscriptions_investment_movements.values.initial_investment'
                      .t(),
                  style: customAppTheme.textStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.initialInvestment
                      .convertToCurrency(widget.currencyCode),
                  style: customAppTheme.textStyles.headlineMedium,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.term} forecast',
                  style: customAppTheme.textStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                widget.forecast != null
                    ? Text(
                        widget.forecast!.convertToCurrency(widget.currencyCode),
                        style: customAppTheme.textStyles.headlineMedium,
                      )
                    : const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
