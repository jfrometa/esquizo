import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/chat/domain/message.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';

class MessageTile extends ConsumerWidget {
  final Message message;
  final bool isOutgoing;

  const MessageTile({
    super.key,
    required this.message,
    required this.isOutgoing,
  }) : super();

  @override
  Widget build(BuildContext context, ref) {
    final theme = ref.watch(appThemeProvider);

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isOutgoing
              ? theme.colorsPalette.secondary
              : theme.colorsPalette.secondarySoft,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: theme.textStyles.bodyLarge.copyWith(
                color: isOutgoing ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            message.imageUrl != null
                ? 
                CachedNetworkImage(
                  imageUrl: message.imageUrl!,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red,),
                ) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
