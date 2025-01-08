import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/admin/admin_home_screen.dart';
import 'package:connectcare/presentation/screens/admin/daily_reports.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_staff_users.dart';
import 'package:connectcare/presentation/screens/admin/principal/management.dart';
import 'package:connectcare/presentation/screens/doctor/doctor_home_screen.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/hoja_enfermeria_screen.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/patient_reg_screen.dart';
import 'package:connectcare/presentation/screens/family/main_family/main_family_member_home_screen.dart';
import 'package:connectcare/presentation/screens/family/patient_link_screen.dart';
import 'package:connectcare/presentation/screens/family/regular_family/regular_family_member_home_screen.dart';
import 'package:connectcare/presentation/screens/general/auth/register/choose_role_screen.dart';
import 'package:connectcare/presentation/screens/general/main_screen_staff.dart';
import 'package:connectcare/presentation/screens/human_resources/human_resources_home_screen.dart';
import 'package:connectcare/presentation/screens/nurse/nurse_home_screen.dart';
import 'package:connectcare/presentation/screens/social_worker/social_worker_home_screen.dart';
import 'package:connectcare/presentation/screens/stretcher_bearer/stretcher_bearer_home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
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
  String userType = '';
  bool hasClues = false;
  bool hasPatients = false;
  bool isStaff = false;

  final List<Widget> _pages = [];
  final List<TabItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.index ?? 0;
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configurePages();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService().loadUserData();

      print("User data loaded:");
      print("userType: ${userData['userType']}");
      print("hasClues: ${userData['clues']}");
      print("hasPatients: ${userData['patients']}");

      setState(() {
        userType = userData['userType']?.trim() ?? '';
        hasClues = (userData['clues'] ?? '').isNotEmpty;
        hasPatients = (userData['patients'] ?? '').isNotEmpty;
        isStaff = [
          'stretcher bearer',
          'doctor',
          'nurse',
          'social worker',
          'human resources',
          'administrator'
        ].contains(userType);
      });

      if (userType.isEmpty) {
        _navigateToChooseRoleScreen();
      } else {
        _configurePages();
      }
    } catch (e) {
      //print("Error loading user data: $e");
      setState(() {
        userType = '';
      });
      _navigateToChooseRoleScreen();
    }
  }

  void _configurePages() {
    _pages.clear();
    _navItems.clear();

    if (userType.isEmpty) return;

    _pages.add(const SettingsScreen());
    _navItems.add(TabItem(icon: Icons.settings, title: 'Settings'.tr()));

    if (userType == 'administrator' && isStaff && !hasClues) {
      _pages.insert(0, const RegisterHospitalScreen());
      _navItems.insert(
          0, TabItem(icon: Icons.dashboard, title: 'Register'.tr()));
    } else if (isStaff && !hasClues) {
      _pages.insert(0, const MainScreenStaff());
      _navItems.insert(0, TabItem(icon: Icons.send, title: 'Request'.tr()));
    } else if (!isStaff && !hasPatients) {
      _pages.insert(0, const PatientLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.add_link, title: 'Link'.tr()));
    } else if (userType == 'main') {
      _pages.insert(0, const MainFamilyMemberHomeScreen());
      _pages.insert(1, const PatientLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.home, title: 'Home'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.link, title: 'Link'.tr()));
    } else if (userType == 'regular') {
      _pages.insert(0, const RegularFamilyMemberHomeScreen());
      _pages.insert(1, const PatientLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.home, title: 'Home'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.link, title: 'Link'.tr()));
    } else if (userType == 'stretcher bearer') {
      _pages.insert(0, const StretcherBearerHomeScreen());
      _pages.insert(1, const MainScreenStaff());
      _navItems.insert(
          0,
          TabItem(
              icon: Icons.transfer_within_a_station, title: 'Stretcher'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.send, title: 'Request'.tr()));
    } else if (userType == 'doctor') {
      _pages.insert(0, const DoctorHomeScreen());
      _pages.insert(1, const MainScreenStaff());
      _pages.insert(2, const PatientRegScreen());
      _pages.insert(3, const HojaEnfermeriaScreen());
      _navItems.insert(
          0, TabItem(icon: Icons.medical_services, title: 'Doctor'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.send, title: 'Request'.tr()));
      _navItems.insert(
          2, TabItem(icon: Icons.person_add, title: ('Triage'.tr())));
      _navItems.insert(
          3, TabItem(icon: Icons.assignment, title: "Nursing".tr()));
    } else if (userType == 'nurse') {
      _pages.insert(0, const NurseHomeScreen());
      _pages.insert(1, const MainScreenStaff());
      _pages.insert(2, const HojaEnfermeriaScreen());
      _navItems.insert(
          0, TabItem(icon: Icons.local_hospital, title: 'Nurse'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.send, title: 'Request'.tr()));
      _navItems.insert(
          2, TabItem(icon: Icons.assignment, title: "Nursing".tr()));
    } else if (userType == 'social worker') {
      _pages.insert(0, const SocialWorkerHomeScreen());
      _pages.insert(1, const MainScreenStaff());
      _navItems.insert(
          0, TabItem(icon: Icons.people, title: 'Social Worker'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.send, title: 'Request'.tr()));
    } else if (userType == 'human resources') {
      _pages.insert(0, const HumanResourcesHomeScreen());
      _pages.insert(1, const MainScreenStaff());
      _navItems.insert(0, TabItem(icon: Icons.people_alt, title: 'HR'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.send, title: 'Request'.tr()));
    } else if (userType == 'administrator') {
      _pages.insert(0, const AdminHomeScreen());
      _pages.insert(1, const Management());
      _pages.insert(2, const ManageStaffUsers());
      _pages.insert(3, const DailyReports());
      _navItems.insert(0, TabItem(icon: Icons.home, title: 'Home'.tr()));
      _navItems.insert(
          1, TabItem(icon: Icons.business_center, title: 'Control'.tr()));
      _navItems.insert(
          2, TabItem(icon: Icons.business_center, title: 'Staff'.tr()));
      _navItems.insert(
          3,
          TabItem(
              icon: Icons.stacked_bar_chart_rounded, title: 'Reports'.tr()));
    }
  }

  void _navigateToChooseRoleScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ChooseRoleScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Builder(
      builder: (context) {
        return Scaffold(
          body: _pages.isNotEmpty
              ? _pages[_pageIndex]
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
      },
    );
  }
}
