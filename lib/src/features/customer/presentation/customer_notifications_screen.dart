import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../shared/models/app_models.dart';
import 'widgets/customer_dock.dart';
import 'package:flutter/material.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends State<CustomerNotificationsScreen> {
  late Future<List<DispatchRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = MobileApi.instance.customerHistory();
  }

  Future<void> _reload() async {
    final future = MobileApi.instance.customerHistory();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Bildirishnomalar',
      subtitle: '',
      bottom: const CustomerDock(activeTab: CustomerDockTab.notifications),
      child: FutureBuilder<List<DispatchRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: SoftCard(child: Text('${snapshot.error}')));
          }
          final items = snapshot.data ?? const <DispatchRecord>[];
          if (items.isEmpty) {
            return const Center(
              child: SoftCard(
                child: Text('Hozircha yozuv yo‘q.'),
              ),
            );
          }
          return RefreshIndicator.adaptive(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                SoftCard(
                  padding: EdgeInsets.zero,
                  borderWidth: 1.45,
                  borderRadius: 20,
                  child: Column(
                    children: [
                      for (int index = 0; index < items.length; index++) ...[
                        _CustomerFeedRow(
                          record: items[index],
                          isFirst: index == 0,
                          isLast: index == items.length - 1,
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

class _CustomerFeedRow extends StatelessWidget {
  const _CustomerFeedRow({
    required this.record,
    required this.isFirst,
    required this.isLast,
  });

  final DispatchRecord record;
  final bool isFirst;
  final bool isLast;

  IconData get _icon {
    switch (record.status) {
      case DispatchStatus.accepted:
        return Icons.done_all_rounded;
      case DispatchStatus.partial:
        return Icons.check_rounded;
      case DispatchStatus.rejected:
        return Icons.close_rounded;
      case DispatchStatus.cancelled:
        return Icons.remove_rounded;
      case DispatchStatus.draft:
        return Icons.schedule_rounded;
      case DispatchStatus.pending:
        return Icons.schedule_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 20 : 0),
          topRight: Radius.circular(isFirst ? 20 : 0),
          bottomLeft: Radius.circular(isLast ? 20 : 0),
          bottomRight: Radius.circular(isLast ? 20 : 0),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  record.itemCode,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Icon(
                  _icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            record.itemName,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${record.sentQty.toStringAsFixed(0)} ${record.uom} jo‘natildi',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
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
