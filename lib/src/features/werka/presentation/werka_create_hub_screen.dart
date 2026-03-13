import '../../../app/app_router.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import 'widgets/werka_dock.dart';
import 'package:flutter/material.dart';

class WerkaCreateHubScreen extends StatelessWidget {
  const WerkaCreateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Qayd',
      subtitle: '',
      leading: AppShellIconAction(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      bottom: const WerkaDock(activeTab: null),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SoftCard(
            padding: EdgeInsets.zero,
            borderWidth: 1.45,
            borderRadius: 20,
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.werkaUnannouncedSupplier,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text('Aytilmagan mol'),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.werkaCustomerIssueCustomer,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text('Mol jo‘natish'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
