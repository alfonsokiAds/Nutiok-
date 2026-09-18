import 'package:flutter/material.dart';
import 'package:nutiok_app/widgets/bottom_nav_bar.dart';

import 'package:nutiok_app/screens/home/home_screen.dart';
import 'package:nutiok_app/screens/recipes/recipe_search_screen.dart';
import 'package:nutiok_app/screens/reminders/reminders_screen.dart';
import 'package:nutiok_app/screens/map/map_screen.dart';
import 'package:nutiok_app/screens/profile/profile_screen.dart';

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
