import '../../../../app/app_router.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/logout_prompt.dart';
import 'package:flutter/material.dart';

enum CustomerDockTab {
  home,
  notifications,
  profile,
}

class CustomerDock extends StatelessWidget {
  const CustomerDock({
    super.key,
    required this.activeTab,
  });

  final CustomerDockTab? activeTab;

  @override
  Widget build(BuildContext context) {
    return ActionDock(
      liftCenter: false,
      leading: [
        DockButton(
          iconWidget: const DockSvgIcon(
            fillAsset: 'assets/icons/home-fill.svg',
            lineAsset: 'assets/icons/home-line.svg',
            primary: false,
          ),
          active: activeTab == CustomerDockTab.home,
          onTap: () {
            if (activeTab == CustomerDockTab.home) return;
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.customerHome,
              (route) => false,
            );
          },
        ),
      ],
      center: DockButton(
        iconWidget: const DockSvgIcon(
          fillAsset: 'assets/icons/notification-3-fill.svg',
          lineAsset: 'assets/icons/notification-3-line.svg',
          primary: false,
        ),
        active: activeTab == CustomerDockTab.notifications,
        primary: false,
        onTap: () {
          if (activeTab == CustomerDockTab.notifications) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.customerNotifications,
            (route) => false,
          );
        },
      ),
      trailing: [
        DockButton(
          iconWidget: const DockSvgIcon(
            fillAsset: 'assets/icons/account-circle-fill.svg',
            lineAsset: 'assets/icons/account-circle-line.svg',
            primary: false,
          ),
          active: activeTab == CustomerDockTab.profile,
          onHoldComplete: activeTab == CustomerDockTab.profile
              ? () => showLogoutPrompt(context)
              : null,
          onTap: () {
            if (activeTab == CustomerDockTab.profile) return;
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.profile,
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
