import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/motion_widgets.dart';
import '../../shared/models/app_models.dart';
import 'widgets/werka_dock.dart';
import 'package:flutter/material.dart';

class WerkaCustomerIssueCustomerScreen extends StatefulWidget {
  const WerkaCustomerIssueCustomerScreen({super.key});

  @override
  State<WerkaCustomerIssueCustomerScreen> createState() =>
      _WerkaCustomerIssueCustomerScreenState();
}

class _WerkaCustomerIssueCustomerScreenState
    extends State<WerkaCustomerIssueCustomerScreen> {
  late Future<List<CustomerDirectoryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = MobileApi.instance.werkaCustomers();
  }

  Future<void> _reload() async {
    final future = MobileApi.instance.werkaCustomers();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Customer tanlang',
      subtitle: '',
      leading: AppShellIconAction(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      bottom: const WerkaDock(activeTab: null),
      child: FutureBuilder<List<CustomerDirectoryEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: SoftCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Customerlar yuklanmadi: ${snapshot.error}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            );
          }
          final items = snapshot.data ?? const <CustomerDirectoryEntry>[];
          if (items.isEmpty) {
            return const Center(
              child: SoftCard(
                child: Text('Customer topilmadi.'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SoftCard(
                  padding: EdgeInsets.zero,
                  borderWidth: 1.45,
                  borderRadius: 20,
                  child: Column(
                    children: [
                      for (int index = 0; index < items.length; index++) ...[
                        PressableScale(
                          borderRadius: 20,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.werkaCustomerIssueItem,
                            arguments: items[index],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[index].name,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (items[index].phone.trim().isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      items[index].phone,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (index != items.length - 1)
                          const Divider(height: 1, thickness: 1),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
