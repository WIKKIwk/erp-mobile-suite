import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../shared/models/app_models.dart';
import 'widgets/admin_dock.dart';
import 'widgets/admin_supplier_list_module.dart';
import 'package:flutter/material.dart';

class AdminSuppliersScreen extends StatefulWidget {
  const AdminSuppliersScreen({super.key});

  @override
  State<AdminSuppliersScreen> createState() => _AdminSuppliersScreenState();
}

class _AdminSuppliersScreenState extends State<AdminSuppliersScreen> {
  late Future<List<AdminSupplier>> _future;

  @override
  void initState() {
    super.initState();
    _future = MobileApi.instance.adminSuppliers();
  }

  Future<void> _reload() async {
    final future = MobileApi.instance.adminSuppliers();
    setState(() {
      _future = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Suppliers',
      subtitle: 'Supplierlar ro‘yxati.',
      bottom: const AdminDock(activeTab: AdminDockTab.suppliers),
      child: FutureBuilder<List<AdminSupplier>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: SoftCard(
                child: Text('Suppliers yuklanmadi: ${snapshot.error}'),
              ),
            );
          }
          final items = snapshot.data ?? const <AdminSupplier>[];
          return RefreshIndicator(
            onRefresh: _reload,
            child: AdminSupplierListModule(
              items: items,
              onTapSupplier: (item) async {
                await Navigator.of(context).pushNamed(
                  AppRoutes.adminSupplierDetail,
                  arguments: item.ref,
                );
                await _reload();
              },
            ),
          );
        },
      ),
    );
  }
}
