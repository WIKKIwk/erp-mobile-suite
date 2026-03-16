import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
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
  bool _savingStatus = false;
  bool _savingPhone = false;
  bool _regeneratingCode = false;
  bool _removing = false;
  int _retryAfterSec = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<AdminSupplierDetail> _loadDetail() async {
    final detail =
        await MobileApi.instance.adminSupplierDetail(widget.supplierRef);
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
      setState(() {
        _detailFuture = Future<AdminSupplierDetail>.value(updated);
      });
    } finally {
      if (mounted) {
        setState(() => _savingStatus = false);
      }
    }
  }

  Future<void> _addPhone(AdminSupplierDetail detail) async {
    final controller = TextEditingController();
    final phone = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Telefon raqam qo‘shish'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '+998901234567',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (phone == null || phone.trim().isEmpty) {
      return;
    }

    setState(() => _savingPhone = true);
    try {
      final updated = await MobileApi.instance.adminUpdateSupplierPhone(
        ref: detail.ref,
        phone: phone,
      );
      setState(() {
        _detailFuture = Future<AdminSupplierDetail>.value(updated);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telefon saqlanmadi: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _savingPhone = false);
      }
    }
  }

  Future<void> _regenerateCode() async {
    setState(() => _regeneratingCode = true);
    try {
      final updated = await MobileApi.instance
          .adminRegenerateSupplierCode(widget.supplierRef);
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.shellStart(context),
      body: SafeArea(
        child: FutureBuilder<AdminSupplierDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                _SupplierDetailHeader(theme: theme),
                const SizedBox(height: 20),
                _SupplierDetailNoticeCard(
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
              ],
            );
          }

          final detail = snapshot.data!;
          final hasPhone = detail.phone.trim().isNotEmpty;
          final scheme = theme.colorScheme;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              _SupplierDetailHeader(theme: theme),
              const SizedBox(height: 20),
              Card.filled(
                margin: EdgeInsets.zero,
                color: scheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              detail.name,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          _SupplierStatusChip(
                            label: detail.blocked ? 'Blocked' : 'Tayyor',
                            error: detail.blocked,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Ref', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 6),
                      _SupplierDetailField(value: detail.ref),
                      const SizedBox(height: 14),
                      Text('Telefon', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 6),
                      _SupplierDetailField(
                        value: hasPhone ? detail.phone : 'Kiritilmagan',
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: _savingPhone ? null : () => _addPhone(detail),
                          child: Text(
                            _savingPhone
                                ? 'Saqlanmoqda...'
                                : 'Telefonni yangilash',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Code', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 6),
                      _SupplierDetailField(
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                detail.code,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _copyCode(detail.code),
                              icon: const Icon(Icons.content_copy_outlined),
                            ),
                            IconButton(
                              onPressed:
                                  _regeneratingCode || _retryAfterSec > 0
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
                      ),
                      if (_retryAfterSec > 0) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Keyingi code uchun $_retryAfterSec soniya kuting.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _savingStatus
                              ? null
                              : () => _toggleBlocked(detail),
                          child: Text(
                            _savingStatus
                                ? 'Saqlanmoqda...'
                                : detail.blocked
                                    ? 'Unblock qilish'
                                    : 'Block qilish',
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Biriktirilgan mahsulotlar',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        detail.assignedItems.isEmpty
                            ? 'Hozircha mahsulot biriktirilmagan.'
                            : '${detail.assignedItems.length} ta mahsulot biriktirilgan.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pushNamed(
                                AppRoutes.adminSupplierItemsView,
                                arguments: widget.supplierRef,
                              ),
                              child: const Text('Ko‘rish'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pushNamed(
                                AppRoutes.adminSupplierItemsAdd,
                                arguments: widget.supplierRef,
                              ),
                              child: const Text('Qo‘shish'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _removing ? null : _removeSupplier,
                          child: Text(
                            _removing
                                ? 'Chiqarilmoqda...'
                                : 'Tizimdan chiqarish',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _SupplierDetailHeader extends StatelessWidget {
  const _SupplierDetailHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 52,
          width: 52,
          child: IconButton.filledTonal(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Supplier',
            style: theme.textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }
}

class _SupplierStatusChip extends StatelessWidget {
  const _SupplierStatusChip({
    required this.label,
    this.error = false,
  });

  final String label;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: error ? scheme.errorContainer : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: error ? scheme.onErrorContainer : scheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SupplierDetailField extends StatelessWidget {
  const _SupplierDetailField({
    this.value,
    this.child,
  });

  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child ??
          Text(
            (value ?? '').trim().isEmpty ? 'Kiritilmagan' : value!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
    );
  }
}

class _SupplierDetailNoticeCard extends StatelessWidget {
  const _SupplierDetailNoticeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}
