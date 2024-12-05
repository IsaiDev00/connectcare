import 'package:connectcare/presentation/screens/admin/admin_home_screen.dart';
import 'package:connectcare/presentation/screens/admin/daily_reports.dart';
import 'package:connectcare/presentation/screens/admin/manage_staff_users.dart';
import 'package:connectcare/presentation/screens/admin/principal/management.dart';
import 'package:connectcare/presentation/screens/general/settings/settings_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class WrapperAdmin extends StatefulWidget {
  final int index;
  const WrapperAdmin({required this.index, super.key});

  @override
  State<WrapperAdmin> createState() => _WrapperAdmin();
}

class _WrapperAdmin extends State<WrapperAdmin> {
  late int _pageIndex;

  @override
  void initState() {
    setIndex(widget.index);
    super.initState();
  }

  void setIndex(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  final List<Widget> _pages = [
    const AdminHomeScreen(),
    const Management(),
    const ManageStaffUsers(),
    const DailyReports(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          _pages[_pageIndex],
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        items: [
          TabItem(
            icon: Icons.home,
            title: 'Home',
          ),
          TabItem(
            icon: Icons.business_center,
            title: 'Control',
          ),
          TabItem(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Staff',
          ),
          TabItem(
            icon: Icons.stacked_bar_chart_rounded,
            title: 'Daily Info',
          ),
          TabItem(
            icon: Icons.settings,
            title: 'Settings',
          ),
        ],
        color: theme.colorScheme.onPrimary,
        activeColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.secondary,
        shadowColor: Colors.black.withOpacity(0.3),
        height: 70,
        curveSize: 110,
        top: -10,
        elevation: 30,
        style: TabStyle.reactCircle,
        initialActiveIndex: _pageIndex,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
