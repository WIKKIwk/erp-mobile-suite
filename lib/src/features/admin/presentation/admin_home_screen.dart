import '../../../app/app_router.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/notifications/refresh_hub.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_retry_state.dart';
import '../../../core/widgets/motion_widgets.dart';
import '../state/admin_store.dart';
import 'widgets/admin_dock.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _refreshVersion = 0;

  @override
  void initState() {
    super.initState();
    AdminStore.instance.bootstrapSummary();
    RefreshHub.instance.addListener(_handlePushRefresh);
  }

  @override
  void dispose() {
    RefreshHub.instance.removeListener(_handlePushRefresh);
    super.dispose();
  }

  void _handlePushRefresh() {
    if (!mounted || RefreshHub.instance.topic != 'admin') {
      return;
    }
    if (_refreshVersion == RefreshHub.instance.version) {
      return;
    }
    _refreshVersion = RefreshHub.instance.version;
    _reload();
  }

  Future<void> _reload() async {
    await AdminStore.instance.refreshSummary();
  }

  Future<void> _openAndReload(String routeName) async {
    await Navigator.of(context).pushNamed(routeName);
    if (!mounted) {
      return;
    }
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom + 136.0;
    return AppShell(
      title: context.l10n.adminRoleName,
      subtitle: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 0, 14, 0),
      bottom: const AdminDock(activeTab: AdminDockTab.home),
      child: AnimatedBuilder(
        animation: AdminStore.instance,
        builder: (context, _) {
          final store = AdminStore.instance;
          if (store.loadingSummary && !store.loadedSummary) {
            return const Center(child: AppLoadingIndicator());
          }
          if (store.summaryError != null && !store.loadedSummary) {
            return AppRetryState(onRetry: _reload);
          }

          final summaryValue = store.summary;
          return AppRefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: EdgeInsets.only(bottom: bottomPadding),
              children: [
                SmoothAppear(
                  delay: const Duration(milliseconds: 20),
                  child: _AdminModulesSection(
                    onTapSettings: () =>
                        _openAndReload(AppRoutes.adminSettings),
                    onTapSuppliers: () =>
                        _openAndReload(AppRoutes.adminSuppliers),
                    onTapWerka: () => _openAndReload(AppRoutes.adminWerka),
                  ),
                ),
                if (summaryValue.blockedSuppliers > 0) ...[
                  const SizedBox(height: 12),
                  SmoothAppear(
                    delay: const Duration(milliseconds: 60),
                    child: _AdminBlockedSuppliersCard(
                      count: summaryValue.blockedSuppliers,
                      onTap: () =>
                          _openAndReload(AppRoutes.adminInactiveSuppliers),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminModulesSection extends StatelessWidget {
  const _AdminModulesSection({
    required this.onTapSettings,
    required this.onTapSuppliers,
    required this.onTapWerka,
  });

  final VoidCallback onTapSettings;
  final VoidCallback onTapSuppliers;
  final VoidCallback onTapWerka;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Card.filled(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Modullar',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 14),
            Card.filled(
              margin: EdgeInsets.zero,
              color: isDark ? const Color(0xFF2A2931) : scheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _AdminModuleRow(
                    title: context.l10n.adminErpSettingsTitle,
                    subtitle: context.l10n.erpConnectionSubtitle,
                    onTap: onTapSettings,
                    highlighted: true,
                    isFirst: true,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: scheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                  _AdminModuleRow(
                    title: 'Suppliers',
                    subtitle: 'List, mahsulot biriktirish va block nazorati',
                    onTap: onTapSuppliers,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: scheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                  _AdminModuleRow(
                    title: context.l10n.adminCreateWerkaTitle,
                    subtitle: context.l10n.adminCreateWerkaSubtitle,
                    onTap: onTapWerka,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminModuleRow extends StatelessWidget {
  const _AdminModuleRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? 24 : 0),
      topRight: Radius.circular(isFirst ? 24 : 0),
      bottomLeft: Radius.circular(isLast ? 24 : 0),
      bottomRight: Radius.circular(isLast ? 24 : 0),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.smooth,
          color: highlighted ? scheme.surfaceContainerHigh : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (highlighted) ...[
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminBlockedSuppliersCard extends StatelessWidget {
  const _AdminBlockedSuppliersCard({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Card.filled(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Blok nazorati',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 14),
            Card.filled(
              margin: EdgeInsets.zero,
              color: isDark ? const Color(0xFF2A2931) : scheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.block_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bloklangan supplierlar: $count ta',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
