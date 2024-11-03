import 'package:connectcare/presentation/screens/principal/main_screen.dart';
import 'package:connectcare/presentation/screens/principal/management.dart';
import 'package:connectcare/presentation/screens/principal/profile_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Wrapper extends StatefulWidget {
  final int index;
  const Wrapper({required this.index, super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
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
    const MainScreen(),
    const Management(),
    const ProfileScreen(),
    const MainScreen(),
    const MainScreen(),
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
            icon: Icons.menu_open_sharp,
            title: 'Main menu',
          ),
          TabItem(
            icon: Icons.manage_accounts_outlined,
            title: 'Management',
          ),
          TabItem(
            icon: Icons.design_services_outlined,
            title: 'service',
          ),
          TabItem(
            icon: Icons.design_services_outlined,
            title: 'service',
          ),
          TabItem(
            icon: Icons.design_services_outlined,
            title: 'service',
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
