import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PromoCodeInputStyle { regularWithToggle, noToggle }

class PromoCodeInputField extends ConsumerStatefulWidget {
  const PromoCodeInputField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onToggle,
    this.style = PromoCodeInputStyle.regularWithToggle,
    this.onEditingComplete,
    this.onTextChange,
  });
  final TextEditingController controller;
  final Function(String? message, bool hasError)? onEditingComplete;
  final bool enabled;
  final PromoCodeInputStyle style;
  final Function() onToggle;
  final Function()? onTextChange;

  @override
  PromoCodeInputFieldState createState() => PromoCodeInputFieldState();
}

class PromoCodeInputFieldState extends ConsumerState<PromoCodeInputField> {
  String? _promocodeMessage;
  bool _promoHasError = false;
  Future _promocodeResponse = Future.value();

  resetState() {
    setState(() {
      _promocodeMessage = null;
      _promoHasError = false;
    });
  }

  Future _verifyPromoCode(String code) async {
    setState(() {
      _promocodeMessage = null;
      _promoHasError = false;
    });

    await Future.delayed(
      const Duration(milliseconds: 1200),
    ); //TODO: Update function to verify promo code on BE

    if (code == 'error') {
      setState(() {
        _promocodeMessage = 'some error';
        _promoHasError = true;
      });
    } else {
      setState(() {
        _promoHasError = false;
        _promocodeMessage = '1% more auntil the end of the investment';
      });
    }

    if (widget.onEditingComplete != null) {
      widget.onEditingComplete!(_promocodeMessage, _promoHasError);
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return SizedBox(
      height: 94,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.enabled
                  ? Text(
                      '',
                      style: customAppTheme.textStyles.bodyMedium,
                    )
                  : const SizedBox(height: 20),
              TextFormField(
                controller: widget.controller,
                readOnly: !widget.enabled,
                onEditingComplete: () {
                  setState(() async {
                    _promocodeResponse =
                        await _verifyPromoCode(widget.controller.text);
                  });
                  FocusScope.of(context).unfocus();
                },
                onChanged: (value) {
                  setState(() {
                    _promocodeMessage = null;
                  });
                  if (widget.onTextChange != null) {
                    widget.onTextChange!();
                  }
                },
                style: customAppTheme.textStyles.headlineLarge,
                decoration: InputDecoration(
                  hintText:
                      widget.style == PromoCodeInputStyle.regularWithToggle
                          ? widget.enabled
                              ? 'Type...'
                              : 'marketplace.product.promocode_question'.t()
                          : 'marketplace.product.promocode_question'.t(),
                  hintStyle: customAppTheme.textStyles.headlineLarge.copyWith(
                    color: customAppTheme.colorsPalette.secondary40,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: customAppTheme.colorsPalette.secondary7,
                    ),
                  ),
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: customAppTheme.colorsPalette.secondary7,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: customAppTheme.colorsPalette.primary7,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.enabled
                          ? customAppTheme.colorsPalette.secondary40
                          : customAppTheme.colorsPalette.secondary7,
                      width: widget.enabled ? 2 : 1,
                    ),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: _promoHasError
                          ? customAppTheme.colorsPalette.negativeAction
                          : customAppTheme.colorsPalette.positiveAction,
                    ),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: _promoHasError
                          ? customAppTheme.colorsPalette.negativeAction
                          : customAppTheme.colorsPalette.positiveAction,
                      width: 2,
                    ),
                  ),
                  errorText: _promocodeMessage,
                  errorStyle: customAppTheme.textStyles.bodySmall.copyWith(
                    color: _promoHasError
                        ? customAppTheme.colorsPalette.negativeAction
                        : customAppTheme.colorsPalette.positiveAction,
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FutureBuilder(
                    future: _promocodeResponse,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return widget.style ==
                                PromoCodeInputStyle.regularWithToggle
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 29.0),
                                child: _promocodeMessage == null
                                    ? Toggle(
                                        value: widget.enabled,
                                        onChanged: (value) {
                                          widget.controller.text = '';
                                          widget.onToggle();
                                        },
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Icon(
                                          _promoHasError
                                              ? ThanosIcons.inputFieldError
                                              : ThanosIcons.inputFieldSuccess,
                                          color: _promoHasError
                                              ? customAppTheme
                                                  .colorsPalette.negativeAction
                                              : customAppTheme
                                                  .colorsPalette.positiveAction,
                                        ),
                                      ),
                              )
                            : SizedBox.fromSize();
                      }
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 40, right: 5),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
