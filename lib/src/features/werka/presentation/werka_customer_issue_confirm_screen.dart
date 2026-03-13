import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../shared/models/app_models.dart';
import 'widgets/werka_dock.dart';
import 'package:flutter/material.dart';

class WerkaCustomerIssueConfirmArgs {
  const WerkaCustomerIssueConfirmArgs({
    required this.customer,
    required this.item,
    required this.qty,
  });

  final CustomerDirectoryEntry customer;
  final SupplierItem item;
  final double qty;
}

class WerkaCustomerIssueConfirmScreen extends StatefulWidget {
  const WerkaCustomerIssueConfirmScreen({
    super.key,
    required this.args,
  });

  final WerkaCustomerIssueConfirmArgs args;

  @override
  State<WerkaCustomerIssueConfirmScreen> createState() =>
      _WerkaCustomerIssueConfirmScreenState();
}

class _WerkaCustomerIssueConfirmScreenState
    extends State<WerkaCustomerIssueConfirmScreen> {
  bool _saving = false;

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await MobileApi.instance.createWerkaCustomerIssue(
        customerRef: widget.args.customer.ref,
        itemCode: widget.args.item.code,
        qty: widget.args.qty,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.werkaHome,
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Tasdiqlash',
      subtitle: '',
      leading: AppShellIconAction(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      bottom: const WerkaDock(activeTab: null),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            'Customer: ${widget.args.customer.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Mahsulot: ${widget.args.item.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Miqdor: ${widget.args.qty.toStringAsFixed(2)} ${widget.args.item.uom}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: _saving ? null : _submit,
              child: Text(_saving ? 'Saqlanmoqda...' : 'Tasdiqlash'),
            ),
          ),
        ],
      ),
    );
  }
}
