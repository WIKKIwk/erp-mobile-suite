import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../shared/models/app_models.dart';
import 'widgets/customer_dock.dart';
import 'package:flutter/material.dart';

class CustomerStatusDetailScreen extends StatefulWidget {
  const CustomerStatusDetailScreen({
    super.key,
    required this.kind,
  });

  final CustomerStatusKind kind;

  @override
  State<CustomerStatusDetailScreen> createState() =>
      _CustomerStatusDetailScreenState();
}

class _CustomerStatusDetailScreenState
    extends State<CustomerStatusDetailScreen> {
  late Future<List<DispatchRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = MobileApi.instance.customerStatusDetails(widget.kind);
  }

  Future<void> _reload() async {
    final future = MobileApi.instance.customerStatusDetails(widget.kind);
    setState(() => _future = future);
    await future;
  }

  String get _title {
    switch (widget.kind) {
      case CustomerStatusKind.pending:
        return 'Kutilmoqda';
      case CustomerStatusKind.confirmed:
        return 'Tasdiqlangan';
      case CustomerStatusKind.rejected:
        return 'Rad etilgan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: _title,
      subtitle: '',
      leading: AppShellIconAction(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      bottom: const CustomerDock(activeTab: null),
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
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = items[index];
                return SoftCard(
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
                      const SizedBox(height: 12),
                      Text(
                        '${record.sentQty.toStringAsFixed(0)} ${record.uom}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.createdLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
