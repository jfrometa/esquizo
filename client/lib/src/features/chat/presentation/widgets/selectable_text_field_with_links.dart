import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectableTextFieldWithLinks extends StatefulWidget {
  const SelectableTextFieldWithLinks({super.key});

  @override
  _SelectableTextFieldWithLinksState createState() =>
      _SelectableTextFieldWithLinksState();
}

class _SelectableTextFieldWithLinksState
    extends State<SelectableTextFieldWithLinks> {
  final TextEditingController _controller = TextEditingController();
  final RegExp _urlRegExp = RegExp(r'((https?:\/\/)|(www\.))[^\s]+');

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (text) {
        setState(() {}); // Rebuild the widget to update the RichText
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildRichText() {
    final text = _controller.text;
    final spans = <TextSpan>[];

    int startIndex = 0;
    for (final match in _urlRegExp.allMatches(text)) {
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: text.substring(startIndex, match.start),
      ));
      spans.add(TextSpan(
        text: url,
        style: const TextStyle(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrl(Uri.parse(url));
          },
      ));
      startIndex = match.end;
    }
    spans.add(TextSpan(text: text.substring(startIndex)));

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
