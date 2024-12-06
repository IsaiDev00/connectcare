import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/doctor/doctor_home_screen.dart';
import 'package:connectcare/presentation/screens/family/main_family/main_family_member_home_screen.dart';
import 'package:connectcare/presentation/screens/family/patient_link_screen.dart';
import 'package:connectcare/presentation/screens/family/regular_family/regular_family_member_home_screen.dart';
import 'package:connectcare/presentation/screens/general/main_screen_staff.dart';
import 'package:connectcare/presentation/screens/human_resources/human_resources_home_screen.dart';
import 'package:connectcare/presentation/screens/nurse/nurse_home_screen.dart';
import 'package:connectcare/presentation/screens/social_worker/social_worker_home_screen.dart';
import 'package:connectcare/presentation/screens/stretcher_bearer/stretcher_bearer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:connectcare/presentation/screens/general/settings/settings_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class DynamicWrapper extends StatefulWidget {
  final int? index;

  const DynamicWrapper({this.index, super.key});

  @override
  State<DynamicWrapper> createState() => _DynamicWrapperState();
}

class _DynamicWrapperState extends State<DynamicWrapper> {
  late int _pageIndex;
  late String userType;
  late bool hasClues;
  late bool hasPatients;

  final List<Widget> _pages = [];
  final List<TabItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.index ?? 0;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService().loadUserData();
    setState(() {
      userType = userData['userType']?.trim().toLowerCase() ?? '';
      hasClues = (userData['clues'] ?? '').isNotEmpty;
      hasPatients = (userData['patients'] ?? '').isNotEmpty;
    });

    _configurePages();
    /*print('User Type: $userType');
    print('Pages: $_pages');
    print('Nav Items: $_navItems');*/
  }

  void _configurePages() {
    _pages.clear();
    _navItems.clear();

    _pages.add(const SettingsScreen());
    _navItems.add(TabItem(icon: Icons.settings, title: 'Settings'));

    if (userType == 'main') {
      _pages.insert(0, const MainFamilyMemberHomeScreen());
      _pages.insert(1, const PatientLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.home, title: 'Home'));
      _navItems.insert(1, TabItem(icon: Icons.link, title: 'Link'));
    } else if (userType == 'regular') {
      _pages.insert(0, const RegularFamilyMemberHomeScreen());
      _pages.insert(1, const PatientLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.home, title: 'Home'));
      _navItems.insert(1, TabItem(icon: Icons.link, title: 'Link'));
    } else if (userType == 'stretcher bearer') {
      _pages.insert(0, const StretcherBearerHomeScreen());
      _navItems.insert(0,
          TabItem(icon: Icons.transfer_within_a_station, title: 'Stretcher'));
    } else if (userType == 'doctor') {
      _pages.insert(0, const DoctorHomeScreen());
      _navItems.insert(
          0, TabItem(icon: Icons.medical_services, title: 'Doctor'));
    } else if (userType == 'nurse') {
      _pages.insert(0, const NurseHomeScreen());
      _navItems.insert(0, TabItem(icon: Icons.local_hospital, title: 'Nurse'));
    } else if (userType == 'social worker') {
      _pages.insert(0, const SocialWorkerHomeScreen());
      _navItems.insert(0, TabItem(icon: Icons.people, title: 'Social Worker'));
    } else if (userType == 'human resources') {
      _pages.insert(0, const HumanResourcesHomeScreen());
      _navItems.insert(0, TabItem(icon: Icons.people_alt, title: 'HR'));
    } else {
      _pages.insert(0, const MainScreenStaff());
      _navItems.insert(0, TabItem(icon: Icons.dashboard, title: 'Dashboard'));
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: _pages.isNotEmpty
          ? Stack(
              children: [
                _pages[_pageIndex],
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: _navItems.isNotEmpty
          ? ConvexAppBar(
              items: _navItems,
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
            )
          : null,
    );
  }
}
