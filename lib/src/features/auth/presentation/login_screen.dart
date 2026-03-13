import '../../../app/app_router.dart';
import '../../../core/api/mobile_api.dart';
import '../../../core/notifications/push_messaging_service.dart';
import '../../../core/security/security_controller.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/motion_widgets.dart';
import '../../shared/models/app_models.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode codeFocusNode = FocusNode();
  String? errorText;
  bool loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    phoneFocusNode.dispose();
    codeFocusNode.dispose();
    super.dispose();
  }

  void submitLogin(BuildContext context) {
    if (loading) {
      return;
    }
    final String phone = phoneController.text.trim();
    final String code = codeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      setState(() => errorText = 'Telefon raqam va code ni kiriting');
      return;
    }
    setState(() {
      errorText = null;
      loading = true;
    });

    MobileApi.instance
        .login(phone: phone, code: code)
        .then((SessionProfile profile) {
      if (!context.mounted) {
        return;
      }
      PushMessagingService.instance.syncCurrentToken();
      SecurityController.instance.unlockAfterLogin();
      final String route = profile.role == UserRole.supplier
          ? AppRoutes.supplierHome
          : profile.role == UserRole.werka
              ? AppRoutes.werkaHome
              : AppRoutes.adminHome;
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    }).catchError((_) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        errorText = 'Login muvaffaqiyatsiz';
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Login',
      subtitle: '',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutofillGroup(
                        child: Column(
                          children: [
                            SmoothAppear(
                              delay: const Duration(milliseconds: 30),
                              child: TextField(
                                controller: phoneController,
                                focusNode: phoneFocusNode,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                autocorrect: false,
                                enableSuggestions: true,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Telefon raqam',
                                  hintText: 'Masalan: +998901234567',
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SmoothAppear(
                              delay: const Duration(milliseconds: 40),
                              child: TextField(
                                controller: codeController,
                                focusNode: codeFocusNode,
                                textInputAction: TextInputAction.done,
                                autocorrect: false,
                                enableSuggestions: true,
                                autofillHints: const [AutofillHints.username],
                                onSubmitted: (_) {
                                  if (!loading) {
                                    submitLogin(context);
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Code',
                                  hintText: 'Masalan: 10XXXXXXXXXX',
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 14),
                        SmoothAppear(
                          delay: const Duration(milliseconds: 120),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0B0B),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0xFF2A2A2A)),
                            ),
                            child: Text(
                              errorText!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              loading ? null : () => submitLogin(context),
                          child: Text(loading ? 'Kuting...' : 'Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
