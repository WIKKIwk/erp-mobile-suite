import '../native_back_button_bridge.dart';
import 'package:flutter/material.dart';

bool useNativeBackButton(BuildContext context) {
  return NativeBackButtonBridge.shouldUseNativeBackButton(context);
}

class NativeBackButtonSlot extends StatelessWidget {
  const NativeBackButtonSlot({
    super.key,
    required this.onPressed,
    this.iconSize = 28,
  });

  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (useNativeBackButton(context)) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 52,
      width: 52,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(Icons.arrow_back_rounded, size: iconSize),
      ),
    );
  }
}
