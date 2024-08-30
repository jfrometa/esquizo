import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/animated_button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_field.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProductNameModal extends ConsumerStatefulWidget {
  const EditProductNameModal({
    super.key,
    required this.onSave,
    required this.productName,
  });

  final Function(String) onSave;
  final String productName;

  @override
  ConsumerState createState() => _EditProductNameModalState();
}

class _EditProductNameModalState extends ConsumerState<EditProductNameModal> {
  bool _buttonEnabled = false;
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget.productName);

  @override
  void initState() {
    super.initState();

    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(child: Container()),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: customAppTheme.colorsPalette.white,
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    color: customAppTheme.colorsPalette.primary40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'marketplace_investments_step2_edit_name_save.title'.t(),
                  style: customAppTheme.textStyles.headlineLarge,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InputField(
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    label:
                        'marketplace_investments_step2_changes_success.details.product_name'
                            .t(),
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          _buttonEnabled = true;
                        });
                      } else {
                        setState(() {
                          _buttonEnabled = false;
                        });
                      }
                    },
                  ),
                ),
                AnimatedButton(
                  buttonEnabled: _buttonEnabled,
                  text: Text('button.save_changes'.t()),
                  onPressed: () {
                    widget.onSave(_textEditingController.text);
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
