import 'package:collegeapplication/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogout;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Provider.of<AppState>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
