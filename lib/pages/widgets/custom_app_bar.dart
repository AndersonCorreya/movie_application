import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(title),
      titleTextStyle: TextStyle(
        color:
            theme.appBarTheme.titleTextStyle?.color ??
            theme.colorScheme.onBackground,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Playair',
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
