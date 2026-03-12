import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../shared/models/app_models.dart';
import 'werka_status_breakdown_screen.dart';
import 'widgets/werka_dock.dart';
import 'package:flutter/material.dart';

class WerkaStatusDetailScreen extends StatefulWidget {
  const WerkaStatusDetailScreen({
    super.key,
    required this.args,
  });

  final WerkaStatusDetailArgs args;

  @override
  State<WerkaStatusDetailScreen> createState() =>
      _WerkaStatusDetailScreenState();
}

class _WerkaStatusDetailScreenState extends State<WerkaStatusDetailScreen> {
  late Future<List<DispatchRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = MobileApi.instance.werkaStatusDetails(
      kind: widget.args.kind,
      supplierRef: widget.args.supplierRef,
    );
  }

  Future<void> _reload() async {
    final future = MobileApi.instance.werkaStatusDetails(
      kind: widget.args.kind,
      supplierRef: widget.args.supplierRef,
    );
    setState(() {
      _future = future;
    });
    await future;
  }

  String get _title {
    switch (widget.args.kind) {
      case WerkaStatusKind.pending:
        return '${widget.args.supplierName} • Jarayonda';
      case WerkaStatusKind.confirmed:
        return '${widget.args.supplierName} • Tasdiqlangan';
      case WerkaStatusKind.returned:
        return '${widget.args.supplierName} • Qaytarilgan';
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
      bottom: const WerkaDock(activeTab: null),
      child: FutureBuilder<List<DispatchRecord>>(
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
                    Text('Receiptlar yuklanmadi: ${snapshot.error}'),
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

          final items = snapshot.data ?? const <DispatchRecord>[];
          if (items.isEmpty) {
            return const Center(
              child: SoftCard(
                child: Text('Bu supplierda hozircha receipt yo‘q.'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = items[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    if (widget.args.kind == WerkaStatusKind.pending) {
                      Navigator.of(context).pushNamed(
                        AppRoutes.werkaDetail,
                        arguments: record,
                      );
                      return;
                    }
                    Navigator.of(context).pushNamed(
                      AppRoutes.notificationDetail,
                      arguments: record.id,
                    );
                  },
                  child: SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.itemCode,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text('${record.itemCode} • ${record.itemName}'),
                        const SizedBox(height: 10),
                        Text(
                          '${record.sentQty.toStringAsFixed(0)} ${record.uom}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (record.acceptedQty > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Qabul: ${record.acceptedQty.toStringAsFixed(0)} ${record.uom}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (record.note.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            record.note,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          record.createdLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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
