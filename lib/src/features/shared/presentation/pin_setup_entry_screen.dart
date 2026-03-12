import '../../../app/app_router.dart';
import 'pin_setup_confirm_screen.dart';
import 'widgets/pin_entry_scaffold.dart';
import 'package:flutter/material.dart';

class PinSetupEntryScreen extends StatefulWidget {
  const PinSetupEntryScreen({super.key});

  @override
  State<PinSetupEntryScreen> createState() => _PinSetupEntryScreenState();
}

class _PinSetupEntryScreenState extends State<PinSetupEntryScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      return;
    }
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.pinSetupConfirm,
      arguments: PinSetupConfirmArgs(firstPin: pin),
    );
    if (!mounted) {
      return;
    }
    if (result == true) {
      Navigator.of(context).pop(true);
    } else {
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PinEntryScaffold(
      title: 'PIN kiriting',
      subtitle: '',
      controller: _pinController,
      actionLabel: 'Keyingi',
      onAction: _handleNext,
    );
  }
}
