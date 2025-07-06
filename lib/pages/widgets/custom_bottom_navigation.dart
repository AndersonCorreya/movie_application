import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/icons8-home.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              selectedIndex == 0
                  ? theme.bottomNavigationBarTheme.selectedItemColor ??
                      Colors.blue
                  : theme.bottomNavigationBarTheme.unselectedItemColor ??
                      Colors.grey,
              BlendMode.srcIn,
            ),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/icons8-search.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              selectedIndex == 1
                  ? theme.bottomNavigationBarTheme.selectedItemColor ??
                      Colors.blue
                  : theme.bottomNavigationBarTheme.unselectedItemColor ??
                      Colors.grey,
              BlendMode.srcIn,
            ),
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.bookmark_outline,
            size: 22,
            color:
                selectedIndex == 2
                    ? theme.bottomNavigationBarTheme.selectedItemColor ??
                        Colors.blue
                    : theme.bottomNavigationBarTheme.unselectedItemColor ??
                        Colors.grey,
          ),
          label: 'Watchlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings_outlined,
            color:
                selectedIndex == 3
                    ? theme.bottomNavigationBarTheme.selectedItemColor ??
                        Colors.blue
                    : theme.bottomNavigationBarTheme.unselectedItemColor ??
                        Colors.grey,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}
