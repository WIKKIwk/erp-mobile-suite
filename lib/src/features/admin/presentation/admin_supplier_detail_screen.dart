import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/models/app_models.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminSupplierDetailScreen extends StatefulWidget {
  const AdminSupplierDetailScreen({
    super.key,
    required this.supplierRef,
  });

  final String supplierRef;

  @override
  State<AdminSupplierDetailScreen> createState() =>
      _AdminSupplierDetailScreenState();
}

class _AdminSupplierDetailScreenState extends State<AdminSupplierDetailScreen> {
  late Future<AdminSupplierDetail> _detailFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _savingStatus = false;
  bool _savingItems = false;
  bool _regeneratingCode = false;
  bool _removing = false;
  bool _searching = false;
  bool _searchOpen = false;
  int _retryAfterSec = 0;
  List<SupplierItem> _searchResults = const <SupplierItem>[];
  final Map<String, SupplierItem> _selectedItems = <String, SupplierItem>{};
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<AdminSupplierDetail> _loadDetail() async {
    final detail =
        await MobileApi.instance.adminSupplierDetail(widget.supplierRef);
    _syncSelectedItems(detail.assignedItems);
    _setRetryAfter(detail.codeRetryAfterSec);
    return detail;
  }

  void _setRetryAfter(int seconds) {
    _retryTimer?.cancel();
    _retryAfterSec = seconds > 0 ? seconds : 0;
    if (_retryAfterSec <= 0) {
      return;
    }
    _retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _retryAfterSec <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() => _retryAfterSec = 0);
        }
        return;
      }
      setState(() => _retryAfterSec -= 1);
    });
  }

  void _syncSelectedItems(List<SupplierItem> items) {
    _selectedItems
      ..clear()
      ..addEntries(items.map((item) => MapEntry(item.code, item)));
  }

  Future<void> _reload() async {
    final future = _loadDetail();
    setState(() {
      _detailFuture = future;
    });
    await future;
  }

  Future<void> _toggleBlocked(AdminSupplierDetail detail) async {
    setState(() => _savingStatus = true);
    try {
      final updated = await MobileApi.instance.adminSetSupplierBlocked(
        ref: detail.ref,
        blocked: !detail.blocked,
      );
      _syncSelectedItems(updated.assignedItems);
      setState(() {
        _detailFuture = Future<AdminSupplierDetail>.value(updated);
      });
    } finally {
      if (mounted) {
        setState(() => _savingStatus = false);
      }
    }
  }

  Future<void> _regenerateCode() async {
    setState(() => _regeneratingCode = true);
    try {
      final updated = await MobileApi.instance
          .adminRegenerateSupplierCode(widget.supplierRef);
      _syncSelectedItems(updated.assignedItems);
      _setRetryAfter(updated.codeRetryAfterSec);
      setState(() {
        _detailFuture = Future<AdminSupplierDetail>.value(updated);
      });
    } finally {
      if (mounted) {
        setState(() => _regeneratingCode = false);
      }
    }
  }

  Future<void> _toggleItemSelection(SupplierItem item) async {
    if (_savingItems) {
      return;
    }
    final nextItems = Map<String, SupplierItem>.from(_selectedItems);
    if (nextItems.containsKey(item.code)) {
      nextItems.remove(item.code);
    } else {
      nextItems[item.code] = item;
    }

    setState(() {
      _savingItems = true;
      _selectedItems
        ..clear()
        ..addAll(nextItems);
    });
    try {
      final updated = await MobileApi.instance.adminUpdateSupplierItems(
        ref: widget.supplierRef,
        itemCodes: nextItems.keys.toList(),
      );
      _syncSelectedItems(updated.assignedItems);
      setState(() {
        _detailFuture = Future<AdminSupplierDetail>.value(updated);
      });
    } finally {
      if (mounted) {
        setState(() {
          _savingItems = false;
        });
      }
    }
  }

  Future<void> _searchItems() async {
    setState(() => _searching = true);
    try {
      final items = await MobileApi.instance.adminItems(
        query: _searchController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResults = items;
        _searchOpen = true;
      });
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _removeSupplier() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supplierni chiqarish'),
          content: const Text(
            'Bu supplier admin panel ro‘yxatidan chiqariladi va kira olmaydi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Chiqarish'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    setState(() => _removing = true);
    try {
      await MobileApi.instance.adminRemoveSupplier(widget.supplierRef);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _removing = false);
      }
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code nusxalandi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      leading: AppShellIconAction(
        icon: Icons.arrow_back_rounded,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      title: 'Supplier',
      subtitle: 'Mahsulot, code va status boshqaruvi.',
      child: FutureBuilder<AdminSupplierDetail>(
        future: _detailFuture,
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
                    Text('Supplier detail yuklanmadi: ${snapshot.error}'),
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

          final detail = snapshot.data!;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            detail.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        if (detail.blocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppTheme.cardBorder(context),
                              ),
                            ),
                            child: Text(
                              'Blocked',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(detail.phone,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 14),
                    Text('Code', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            detail.code,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyCode(detail.code),
                          icon: const Icon(Icons.content_copy_outlined),
                        ),
                        IconButton(
                          onPressed: _regeneratingCode || _retryAfterSec > 0
                              ? null
                              : _regenerateCode,
                          icon: _regeneratingCode
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    if (_retryAfterSec > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Keyingi code uchun $_retryAfterSec soniyadan keyin qayta urining.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            _savingStatus ? null : () => _toggleBlocked(detail),
                        child: Text(
                          _savingStatus
                              ? 'Saqlanmoqda...'
                              : detail.blocked
                                  ? 'Unblock qilish'
                                  : 'Block qilish',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biriktirilgan mahsulotlar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (_selectedItems.isEmpty)
                      Text(
                        'Hozircha mahsulot biriktirilmagan.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Column(
                        children: _selectedItems.values
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: _savingItems
                                            ? null
                                            : () => _toggleItemSelection(item),
                                        icon: const Icon(Icons.remove_rounded),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item.code} • ${item.uom}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      readOnly: false,
                      decoration: const InputDecoration(
                        labelText: 'Mahsulot qidirish',
                        hintText: 'Masalan: Rice yoki ITEM-001',
                      ),
                      onTap: _searchItems,
                      onChanged: (_) => _searchItems(),
                    ),
                    if (_searchOpen) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_searching)
                              const Padding(
                                padding: EdgeInsets.all(14),
                                child: CircularProgressIndicator(),
                              )
                            else if (_searchResults.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Text(
                                  'Mahsulot topilmadi.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              )
                            else
                              ..._searchResults.map(
                                (item) {
                                  final bool selected =
                                      _selectedItems.containsKey(item.code);
                                  return InkWell(
                                    onTap: _savingItems
                                        ? null
                                        : () => _toggleItemSelection(item),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            selected
                                                ? Icons.remove_rounded
                                                : Icons.add_rounded,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${item.code} • ${item.uom}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _removing ? null : _removeSupplier,
                  child: Text(
                    _removing ? 'Chiqarilmoqda...' : 'Tizimdan chiqarish',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
