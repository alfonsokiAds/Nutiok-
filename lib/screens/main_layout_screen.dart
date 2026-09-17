import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

import 'sprint1/home_screen.dart';
import 'sprint2/recipe_search_screen.dart';
import 'sprint2/reminders_screen.dart';
import 'sprint4/map_screen.dart';
import 'sprint3/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RecipeSearchScreen(),
    const RemindersScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
