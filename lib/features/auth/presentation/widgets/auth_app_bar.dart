import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const AuthAppBar({
    super.key,
    this.onBackPressed,
    this.showBackButton = true, // Default to true
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(
          Icons.arrow_back,
          size: 24,
          color: Colors.black87,
        ),
        onPressed: onBackPressed ?? () {
          if (context.canPop()) {
            context.pop();
          } else {
            // If can't pop, navigate to login or previous page
            context.go(AppRoutes.login);
          }
        },
        padding: const EdgeInsets.only(left: 16),
      )
          : null,
      centerTitle: true,
      title: Image.asset(
        'assets/images/logo.png',
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}