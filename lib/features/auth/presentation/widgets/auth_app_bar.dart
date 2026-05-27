import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;

  const AuthAppBar({super.key, this.onBackPressed});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 80,
      leading: context.canPop()
          ? Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBackPressed ?? () => context.pop(),
            child: const Icon(
              Icons.arrow_back,
              size: 28,
              color: Colors.grey,
            ),
          ),
        ),
      )
          : null,
      centerTitle: true,
      title: Image.asset(
        'assets/images/logo.png',
        height: 100,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}