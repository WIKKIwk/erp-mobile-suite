import '../../../app/app_router.dart';
import '../../../core/widgets/app_shell.dart';
import '../../shared/models/app_models.dart';
import 'werka_customer_issue_confirm_screen.dart';
import 'widgets/werka_dock.dart';
import 'package:flutter/material.dart';

class WerkaCustomerIssueQtyArgs {
  const WerkaCustomerIssueQtyArgs({
    required this.customer,
    required this.item,
  });

  final CustomerDirectoryEntry customer;
  final SupplierItem item;
}

class WerkaCustomerIssueQtyScreen extends StatefulWidget {
  const WerkaCustomerIssueQtyScreen({
    super.key,
    required this.args,
  });

  final WerkaCustomerIssueQtyArgs args;

  @override
  State<WerkaCustomerIssueQtyScreen> createState() =>
      _WerkaCustomerIssueQtyScreenState();
}

class _WerkaCustomerIssueQtyScreenState
    extends State<WerkaCustomerIssueQtyScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Miqdor kiriting',
      subtitle: widget.args.item.name,
      leading: AppShellIconAction(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      bottom: const WerkaDock(activeTab: null),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.displaySmall,
            decoration: InputDecoration(
              hintText: '0',
              suffixText: widget.args.item.uom,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 22,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () {
                final qty = double.tryParse(_controller.text.trim()) ?? 0;
                if (qty <= 0) {
                  return;
                }
                Navigator.of(context).pushNamed(
                  AppRoutes.werkaCustomerIssueConfirm,
                  arguments: WerkaCustomerIssueConfirmArgs(
                    customer: widget.args.customer,
                    item: widget.args.item,
                    qty: qty,
                  ),
                );
              },
              child: const Text('Keyingi'),
            ),
          ),
        ],
      ),
    );
  }
}
