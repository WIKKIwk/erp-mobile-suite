import '../../../core/api/mobile_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/models/app_models.dart';
import 'dart:async';

import 'package:flutter/material.dart';

class AdminCustomerDetailScreen extends StatefulWidget {
  const AdminCustomerDetailScreen({
    super.key,
    required this.customerRef,
    this.detailLoader,
  });

  final String customerRef;
  final Future<AdminCustomerDetail> Function(String ref)? detailLoader;

  @override
  State<AdminCustomerDetailScreen> createState() =>
      _AdminCustomerDetailScreenState();
}

class _AdminCustomerDetailScreenState extends State<AdminCustomerDetailScreen> {
  AdminCustomerDetail? _detail;
  Object? _loadError;
  bool _loading = true;
  int _retryAfterSec = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<AdminCustomerDetail> _loadDetail() async {
    final loadDetail =
        widget.detailLoader ?? MobileApi.instance.adminCustomerDetail;
    final detail = await loadDetail(widget.customerRef).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Customer detail timeout'),
    );
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
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final detail = await _loadDetail();
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _loadError = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = null;
        _loadError = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AdminCustomerDetail detail = _detail ??
        AdminCustomerDetail(
          ref: widget.customerRef,
          name: _loading ? 'Yuklanmoqda...' : 'Customer',
          phone: _loading ? 'Yuklanmoqda...' : 'Kiritilmagan',
          code: _loading ? 'Yuklanmoqda...' : 'Hali generatsiya qilinmagan',
          codeLocked: false,
          codeRetryAfterSec: _retryAfterSec,
        );

    return Scaffold(
      backgroundColor: AppTheme.shellStart(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Customer',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _AdminCustomerDetailCard(
              detail: detail,
              statusLabel: _loading
                  ? 'Yuklanmoqda'
                  : _loadError != null
                      ? 'Xato'
                      : _detail == null
                          ? 'Bo‘sh'
                          : 'Tayyor',
            ),
            if (_loadError != null) ...[
              const SizedBox(height: 12),
              _AdminCustomerNoticeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Customer detail yuklanmadi',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('$_loadError'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminCustomerDetailCard extends StatelessWidget {
  const _AdminCustomerDetailCard({
    required this.detail,
    required this.statusLabel,
  });

  final AdminCustomerDetail detail;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
                _StatusChip(label: statusLabel),
              ],
            ),
            const SizedBox(height: 18),
            Text('Ref', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            _DetailField(value: detail.ref),
            const SizedBox(height: 14),
            Text('Telefon', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            _DetailField(value: detail.phone),
            const SizedBox(height: 14),
            Text('Code', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            _DetailField(value: detail.code),
            if (detail.codeRetryAfterSec > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Keyingi code uchun ${detail.codeRetryAfterSec} soniya kuting.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminCustomerNoticeCard extends StatelessWidget {
  const _AdminCustomerNoticeCard({required this.child});

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

class _DetailField extends StatelessWidget {
  const _DetailField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        value.trim().isEmpty ? 'Kiritilmagan' : value,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
