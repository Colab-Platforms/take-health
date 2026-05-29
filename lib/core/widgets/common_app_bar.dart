import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/home/domain/entities/user_profile_provider.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;

  const CommonAppBar({super.key, required this.onProfileTap});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>();

    ImageProvider avatarImage;
    if (profile.localImagePath != null) {
      avatarImage = FileImage(File(profile.localImagePath!));
    } else if (profile.profilePictureUrl != null &&
        profile.profilePictureUrl!.isNotEmpty) {
      avatarImage = NetworkImage(profile.profilePictureUrl!);
    } else {
      avatarImage = const NetworkImage('https://i.pravatar.cc/300');
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.green.shade50,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 75,
      leading: Padding(
        padding: const EdgeInsets.only(left: 18, top: 5, bottom: 5),
        child: GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(backgroundImage: avatarImage),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_greeting()}, ${profile.name}!',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Stay healthy today 🌿',
            style: TextStyle(
              color: Color(0xff5D8B74),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xff5D8B74),
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}