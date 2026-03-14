import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/motion_widgets.dart';
import '../../shared/models/app_models.dart';
import 'widgets/customer_dock.dart';
import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late Future<_CustomerHomePayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CustomerHomePayload> _load() async {
    final summary = await MobileApi.instance.customerSummary();
    final history = await MobileApi.instance.customerHistory();
    return _CustomerHomePayload(
      summary: summary,
      previewItems: history.take(3).toList(),
    );
  }

  Future<void> _reload() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Customer',
      subtitle: '',
      bottom: const CustomerDock(activeTab: CustomerDockTab.home),
      child: FutureBuilder<_CustomerHomePayload>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: SoftCard(child: Text('${snapshot.error}')));
          }
          final payload = snapshot.data!;
          return RefreshIndicator.adaptive(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _CustomerSummaryCard(summary: payload.summary),
                const SizedBox(height: 16),
                _CustomerPendingPreviewCard(items: payload.previewItems),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomerHomePayload {
  const _CustomerHomePayload({
    required this.summary,
    required this.previewItems,
  });

  final CustomerHomeSummary summary;
  final List<DispatchRecord> previewItems;
}

class _CustomerSummaryCard extends StatelessWidget {
  const _CustomerSummaryCard({
    required this.summary,
  });

  final CustomerHomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      borderWidth: 1.35,
      borderRadius: 20,
      child: Column(
        children: [
          _CustomerSummaryRow(
            label: 'Kutilmoqda',
            value: summary.pendingCount.toString(),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.customerStatusDetail,
              arguments: CustomerStatusKind.pending,
            ),
            isFirst: true,
          ),
          const Divider(height: 1, thickness: 1),
          _CustomerSummaryRow(
            label: 'Tasdiqlangan',
            value: summary.confirmedCount.toString(),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.customerStatusDetail,
              arguments: CustomerStatusKind.confirmed,
            ),
          ),
          const Divider(height: 1, thickness: 1),
          _CustomerSummaryRow(
            label: 'Rad etilgan',
            value: summary.rejectedCount.toString(),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.customerStatusDetail,
              arguments: CustomerStatusKind.rejected,
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _CustomerSummaryRow extends StatelessWidget {
  const _CustomerSummaryRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      borderRadius: 20,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 20 : 0),
            topRight: Radius.circular(isFirst ? 20 : 0),
            bottomLeft: Radius.circular(isLast ? 20 : 0),
            bottomRight: Radius.circular(isLast ? 20 : 0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 34,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerPendingPreviewCard extends StatelessWidget {
  const _CustomerPendingPreviewCard({
    required this.items,
  });

  final List<DispatchRecord> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SoftCard(
        child: Text('Hozircha kutilayotgan jo‘natmalar yo‘q.'),
      );
    }
    return SoftCard(
      padding: EdgeInsets.zero,
      borderWidth: 1.35,
      borderRadius: 20,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF212121),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              'Kutilayotgan jo‘natmalar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (int index = 0; index < items.length; index++) ...[
            _CustomerPreviewRow(
              record: items[index],
              isLast: index == items.length - 1,
            ),
            if (index != items.length - 1)
              const Divider(height: 1, thickness: 1),
          ],
        ],
      ),
    );
  }
}

class _CustomerPreviewRow extends StatelessWidget {
  const _CustomerPreviewRow({
    required this.record,
    required this.isLast,
  });

  final DispatchRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isLast ? 20 : 0),
          bottomRight: Radius.circular(isLast ? 20 : 0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.itemName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  record.itemCode,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.sentQty.toStringAsFixed(0)} ${record.uom}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                record.createdLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
