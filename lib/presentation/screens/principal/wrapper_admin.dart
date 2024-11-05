import 'package:connectcare/presentation/screens/admin/admin_home_screen.dart';
import 'package:connectcare/presentation/screens/principal/management.dart';
import 'package:connectcare/presentation/screens/principal/profile_screen.dart';
import 'package:connectcare/presentation/screens/settings/settings_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WrapperAdmin extends StatefulWidget {
  final int index;
  const WrapperAdmin({required this.index, super.key});

  @override
  _WrapperAdmin createState() => _WrapperAdmin();
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
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:
              brightness == Brightness.dark ? Colors.transparent : Colors.white,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          _pages[_pageIndex],
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        items: [
          TabItem(
            icon: Icons.home,
            title: 'Main page',
          ),
          TabItem(
            icon: Icons.business_center ,
            title: 'Management',
          ),
          TabItem(
            icon: Icons.person,
            title: 'Profile',
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
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
