import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/common_widgets.dart';
import '../models/app_models.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.role,
    required this.name,
    required this.subtitle,
  });

  final UserRole role;
  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Profile',
      subtitle: 'Account va session boshqaruvi.',
      child: Column(
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontSize: 30)),
                const SizedBox(height: 10),
                Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text(
                  role == UserRole.supplier
                      ? 'Supplier account'
                      : 'Werka account',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Bu yerdan hisobdan chiqishingiz mumkin. Keyingi login bilan role qayta tanlanadi.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () async {
              await MobileApi.instance.logout();
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
