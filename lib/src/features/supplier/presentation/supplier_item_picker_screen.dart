import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../shared/models/app_models.dart';
import 'package:flutter/material.dart';

class SupplierItemPickerScreen extends StatefulWidget {
  const SupplierItemPickerScreen({super.key});

  @override
  State<SupplierItemPickerScreen> createState() =>
      _SupplierItemPickerScreenState();
}

class _SupplierItemPickerScreenState extends State<SupplierItemPickerScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Mahsulot tanlash',
      subtitle: 'Faqat sizga biriktirilgan itemlar ko‘rinadi.',
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Kod yoki nom bo‘yicha qidiring',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<SupplierItem>>(
              future: MobileApi.instance
                  .supplierItems(query: controller.text.trim()),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: SoftCard(
                      child: Text('Mahsulotlar yuklanmadi: ${snapshot.error}'),
                    ),
                  );
                }
                final filtered = snapshot.data ?? <SupplierItem>[];
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final SupplierItem item = filtered[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.supplierQty, arguments: item),
                      child: SoftCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.code,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  const SizedBox(height: 6),
                                  Text(item.name),
                                  const SizedBox(height: 10),
                                  Text('${item.uom}  •  ${item.warehouse}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
