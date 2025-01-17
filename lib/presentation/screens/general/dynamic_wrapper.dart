import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/admin/admin_start_screen.dart';
import 'package:connectcare/presentation/screens/admin/daily_reports.dart';
import 'package:connectcare/presentation/screens/admin/denied_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/register_hospital_screen.dart';
import 'package:connectcare/presentation/screens/admin/hospital_reg/waiting_confirmation_screen.dart';
import 'package:connectcare/presentation/screens/admin/manage_staff_users.dart';
import 'package:connectcare/presentation/screens/admin/principal/management.dart';

import 'package:connectcare/presentation/screens/chiefs/assign_tasks_screen.dart';
import 'package:connectcare/presentation/screens/doctor/documents.dart/patient_reg_screen.dart';
import 'package:connectcare/presentation/screens/doctor/doctor_home_screen.dart';
import 'package:connectcare/presentation/screens/doctor/schedule_procedures.dart';
import 'package:connectcare/presentation/screens/family/family_link_screen.dart';
import 'package:connectcare/presentation/screens/family/main_family/main_family_member_home_screen.dart';
import 'package:connectcare/presentation/screens/family/regular_family/regular_family_member_home_screen.dart';
import 'package:connectcare/presentation/screens/general/auth/register/choose_role_screen.dart';
import 'package:connectcare/presentation/screens/general/main_screen_staff.dart';
import 'package:connectcare/presentation/screens/general/settings/settings_screen.dart';
import 'package:connectcare/presentation/screens/human_resources/manage_chiefs.dart';
import 'package:connectcare/presentation/screens/human_resources/manage_shifts.dart';
import 'package:connectcare/presentation/screens/nurse/nurse_home_screen.dart';
import 'package:connectcare/presentation/screens/patient/nfc_bracelet_screen.dart';
import 'package:connectcare/presentation/screens/social_worker/social_worker_home_screen.dart';
import 'package:connectcare/presentation/screens/stretcher_bearer/stretcher_bearer_home_screen.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DynamicWrapper extends StatefulWidget {
  final int? index;

  const DynamicWrapper({this.index, super.key});

  @override
  State<DynamicWrapper> createState() => _DynamicWrapperState();
}

class _DynamicWrapperState extends State<DynamicWrapper> {
  late int _pageIndex;
  String userType = '';
  String userId = '';
  bool hasClues = false;
  bool hasPatients = false;
  bool isStaff = false;
  String? userStatus;
  String? userSchedule;
  bool isWithinSchedule = true;
  bool hasServices = false;

  final List<Widget> _pages = [];
  final List<TabItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.index ?? 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService().loadUserData();

      setState(() {
        userId = userData['userId']?.trim() ?? '';
        userType = userData['userType']?.trim() ?? '';
        userStatus = userData['status']?.trim();
        userSchedule = userData['schedule']?.trim();
        hasClues = (userData['clues'] ?? '').isNotEmpty;
        hasPatients = (userData['patients'] ?? '').isNotEmpty;
        hasServices = (userData['services'] ?? '').isNotEmpty;

        isStaff = [
          'stretcher bearer',
          'doctor',
          'nurse',
          'social worker',
          'human resources',
          'administrator'
        ].contains(userType);
      });

      // Actualizar token de Firebase y enviar notificación, sin importar el tipo de usuario
      await UserService().updateFirebaseTokenAndSendNotification();

      _validateUserStatus();
      _validateUserSchedule();

      // IMPORTANTE: hacemos await para que se termine de configurar
      await _configurePages(userData['clues'] ?? '');
      setState(() {}); // refresca la interfaz
    } catch (e) {
      setState(() {
        userType = '';
      });
      _navigateToChooseRoleScreen();
    }
  }

  void _validateUserStatus() {
    if (userStatus == 'inactive' ||
        userStatus == 'suspended' ||
        userStatus == 'deleted') {
      _showErrorAndExit(tr('user_not_active'));
    }
  }

  void _showErrorAndExit(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr('access_denied')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChooseRoleScreen()),
                  (route) => false,
                );
              },
              child: Text(tr('ok')),
            ),
          ],
        ),
      );
    });
  }

  void _validateUserSchedule() {
    if (userSchedule != null && userSchedule!.isNotEmpty) {
      final now = DateTime.now();
      final currentHour = now.hour;

      switch (userSchedule) {
        case 'morning':
          isWithinSchedule = currentHour >= 7 && currentHour < 13;
          break;
        case 'afternoon':
          isWithinSchedule = currentHour >= 13 && currentHour < 23;
          break;
        case 'night':
          isWithinSchedule = currentHour >= 23 || currentHour < 7;
          break;
        case 'fulltime':
          isWithinSchedule = true;
          break;
        default:
          isWithinSchedule = true;
      }
    }

    if (!isWithinSchedule) {
      _showErrorAndExit(tr('user_not_in_schedule'));
    }
  }

  /// Verifica si el CLUES está en la tabla solicitud_de_hospital.
  /// Devuelve true si está (status=1), false si no está (status=0).
  Future<bool> _checkSolicitudHospital(String clues) async {
    if (clues.isEmpty) return false;

    final url = Uri.parse('$baseUrl/hospital/solicitudHospital/$clues');
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        // Por ejemplo: { "status": 1 } si sí está, { "status": 0 } si no está
        final data = jsonDecode(resp.body);
        return (data['status'] == 1);
      }
      // Si no regresa 200, o no es JSON
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si hay pisos en la tabla Piso para ese CLUES.
  /// Devuelve true si hay resultados (200 OK), false si 404 o error.
  Future<bool> _checkFloors(String clues) async {
    if (clues.isEmpty) return false;

    final url = Uri.parse('$baseUrl/piso/clues/$clues');
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        // Significa que encontró al menos un piso
        return true;
      } else {
        // 404 -> no floors
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// NUEVO: Verifica si el hospital fue aceptado o denegado en la tabla HOSPITAL_RESPONSES.
  /// Retorna un mapa con { 'aceptada_denegada': 1 o 0, 'mensaje': '...', 'fecha': '...'} si existe,
  /// o null si no existe respuesta o hay error.
  Future<Map<String, dynamic>?> _checkHospitalResponse(
      String userId, String clues) async {
    if (userId.isEmpty || clues.isEmpty) return null;

    // Ajusta la ruta de tu endpoint según tu backend
    final url =
        Uri.parse('$baseUrl/administrador/hospitalResponse/$userId/$clues');
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // Se espera algo como: { "aceptada_denegada": 1, "mensaje": "texto", "fecha": "2024-11-10" }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Configura las páginas y navegación según el tipo de usuario y otros atributos.
  Future<void> _configurePages(String userClues) async {
    _pages.clear();
    _navItems.clear();

    if (!isWithinSchedule ||
        userStatus == 'inactive' ||
        userStatus == 'suspended' ||
        userStatus == 'deleted') {
      return;
    }

    // Añadimos siempre Settings en la última posición:
    _pages.add(const SettingsScreen());
    _navItems.add(TabItem(icon: Icons.settings, title: 'Settings'.tr()));

    // Si userId está vacío, mandamos a ChooseRole
    if (userId.isEmpty) {
      _navigateToChooseRoleScreen();
      return;
    }

    // ----------------------------------------------------------------
    // Caso 1: Admin sin CLUES
    if (userType == 'administrator' && isStaff && !hasClues) {
      _pages.insert(0, const RegisterHospitalScreen());
      _pages.insert(1, const MainScreenStaff());
      _navItems.insert(
          0, TabItem(icon: Icons.dashboard, title: 'Register'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.send, title: 'Request'.tr()));
      return;
    }

    // Caso 2: Staff sin CLUES (no es admin)
    if (isStaff && !hasClues && userType != 'administrator') {
      _pages.insert(0, const MainScreenStaff());
      _navItems.insert(0, TabItem(icon: Icons.send, title: 'Request'.tr()));
      return;
    }

    // Caso 3: No es staff y no tiene pacientes => FamilyLink
    if (!isStaff && !hasPatients) {
      _pages.insert(0, const FamilyLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.add_link, title: 'Link'.tr()));
      return;
    }

    // ----------------------------------------------------------------
    // Otros tipos de usuario: main, regular, ocassional, doctor, nurse, etc.
    if (userType == 'main') {
      _pages.insert(0, const MainFamilyMemberHomeScreen());
      _pages.insert(1, const FamilyLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.home, title: 'Home'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.link, title: 'Link'.tr()));
    } else if (userType == 'regular') {
      _pages.insert(0, const RegularFamilyMemberHomeScreen());
      _pages.insert(1, const FamilyLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.home, title: 'Home'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.link, title: 'Link'.tr()));
    } else if (userType == 'ocassional') {
      _pages.insert(0, const RegularFamilyMemberHomeScreen());
      _pages.insert(1, const FamilyLinkScreen());
      _navItems.insert(0, TabItem(icon: Icons.home, title: 'Home'.tr()));
      _navItems.insert(1, TabItem(icon: Icons.link, title: 'Link'.tr()));
    } else if (userType == 'stretcher bearer' && hasServices) {
      _pages.insert(0, const StretcherBearerHomeScreen());
      _pages.insert(1, const AssignTasksScreen());
      _navItems.insert(
        0,
        TabItem(icon: Icons.transfer_within_a_station, title: 'Home'.tr()),
      );
      _navItems.insert(
        1,
        TabItem(icon: Icons.task, title: 'assign_tasks'.tr()),
      );
    } else if (userType == 'stretcher bearer') {
      _pages.insert(0, const StretcherBearerHomeScreen());
      _navItems.insert(
        0,
        TabItem(icon: Icons.transfer_within_a_station, title: 'Home'.tr()),
      );
    } else if (userType == 'doctor' && hasServices) {
      _pages.insert(0, const DoctorHomeScreen());
      _pages.insert(1, const AssignTasksScreen());
      _pages.insert(2, const PatientRegScreen());
      _pages.insert(3, const NfcBraceletScreen());
      _navItems.insert(
        0,
        TabItem(icon: Icons.medical_services, title: 'Home'.tr()),
      );
      _navItems.insert(
        1,
        TabItem(icon: Icons.task, title: 'assign_tasks'.tr()),
      );
      _navItems.insert(
        2,
        TabItem(icon: Icons.assignment, title: 'Triage'.tr()),
      );
      _navItems.insert(3, TabItem(icon: Icons.nfc, title: 'NFC'));
    } else if (userType == 'doctor') {
      _pages.insert(0, const DoctorHomeScreen());
      _pages.insert(1, const PatientRegScreen());
      _pages.insert(2, const NfcBraceletScreen());
      _pages.insert(3, const ProcedureScheduleScreen());
      _navItems.insert(
        0,
        TabItem(icon: Icons.medical_services, title: 'Home'.tr()),
      );
      _navItems.insert(
        1,
        TabItem(icon: Icons.assignment, title: 'Triage'.tr()),
      );
      _navItems.insert(2, TabItem(icon: Icons.nfc, title: 'NFC'));
      _navItems.insert(
        3,
        TabItem(icon: Icons.access_time_filled_sharp, title: 'Procedures'),
      );
    } else if (userType == 'nurse' && hasServices) {
      _pages.insert(0, const NurseHomeScreen());
      _pages.insert(1, const AssignTasksScreen());
      _pages.insert(2, const NfcBraceletScreen());
      _navItems.insert(
        0,
        TabItem(icon: Icons.local_hospital, title: 'Home'.tr()),
      );
      _navItems.insert(
        1,
        TabItem(icon: Icons.task, title: 'assign_tasks'.tr()),
      );
      _navItems.insert(2, TabItem(icon: Icons.nfc, title: 'NFC'));
    } else if (userType == 'nurse') {
      _pages.insert(0, const NurseHomeScreen());
      _pages.insert(1, const NfcBraceletScreen());
      _navItems.insert(
        0,
        TabItem(icon: Icons.local_hospital, title: 'Home'.tr()),
      );
      _navItems.insert(1, TabItem(icon: Icons.nfc, title: 'NFC'));
    } else if (userType == 'social worker') {
      _pages.insert(0, const SocialWorkerHomeScreen());
      _navItems.insert(0, TabItem(icon: Icons.people, title: 'Home'.tr()));
    } else if (userType == 'human resources') {
      _pages.insert(0, const ManageShifts());
      _pages.insert(1, const ManageChiefs());
      _navItems.insert(
        0,
        TabItem(icon: Icons.people_alt, title: 'Shifts'.tr()),
      );
      _navItems.insert(1, TabItem(icon: Icons.people, title: 'Chiefs'.tr()));
    }

    // ----------------------------------------------------------------
    // *********** NUEVA LÓGICA DE ADMIN (TIENE CLUES) ***********
    else if (userType == 'administrator' && isStaff && hasClues) {
      // 1) Checar si CLUES está en solicitud_de_hospital
      final cluesInSolicitud = await _checkSolicitudHospital(userClues);

      if (cluesInSolicitud) {
        // CLUES sí está en solicitud_de_hospital => WaitingConfirmation
        _pages.insert(0, const WaitingConfirmationScreen());
        _navItems.insert(
          0,
          TabItem(icon: Icons.hourglass_top, title: 'Waiting'.tr()),
        );
      } else {
        // 1.1) NO está en solicitud_de_hospital
        //      Verificamos si ya hay un registro en HOSPITAL_RESPONSES
        final responseData = await _checkHospitalResponse(userId, userClues);

        if (responseData != null &&
            responseData.containsKey('aceptada_denegada')) {
          final aceptadaDenegada = responseData['aceptada_denegada'];
          final mensaje = responseData['mensaje'] ?? '';
          final fecha = responseData['fecha'] ?? '';

          if (aceptadaDenegada == 0) {
            // Denegado => mandar a DeniedHospitalScreen
            // Para un flujo más restringido, podemos hacer un pushAndRemoveUntil
            // para que no pueda volver atrás.

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DeniedHospitalScreen(mensaje: mensaje, fecha: fecha),
                ),
                (route) => false,
              );
            });
            return;
          } else if (aceptadaDenegada == 1) {
            // Aceptado => continúa con la validación de pisos
            //   (same as "floorsFound" flow)
            final floorsFound = await _checkFloors(userClues);
            if (!floorsFound) {
              // No hay pisos => AdminStartScreen
              _pages.insert(0, const AdminStartScreen());
              _navItems.insert(
                  0, TabItem(icon: Icons.meeting_room, title: 'Start'.tr()));
            } else {
              // Sí hay pisos => flujo normal de administrador
              _pages.insert(0, const Management());
              _pages.insert(1, const ManageStaffUsers());
              _pages.insert(2, const DailyReports());

              _navItems.insert(0,
                  TabItem(icon: Icons.business_center, title: 'Control'.tr()));
              _navItems.insert(
                  1, TabItem(icon: Icons.business_center, title: 'Staff'.tr()));
              _navItems.insert(
                  2,
                  TabItem(
                      icon: Icons.stacked_bar_chart_rounded,
                      title: 'Reports'.tr()));
            }
          } else {
            // Si no es 0 ni 1, tal vez la respuesta no está bien definida
            // Continuamos a checar floors
            final floorsFound = await _checkFloors(userClues);
            if (!floorsFound) {
              _pages.insert(0, const AdminStartScreen());
              _navItems.insert(
                  0, TabItem(icon: Icons.meeting_room, title: 'Start'.tr()));
            } else {
              _pages.insert(0, const Management());
              _pages.insert(1, const ManageStaffUsers());
              _pages.insert(2, const DailyReports());

              _navItems.insert(0,
                  TabItem(icon: Icons.business_center, title: 'Control'.tr()));
              _navItems.insert(
                  1, TabItem(icon: Icons.business_center, title: 'Staff'.tr()));
              _navItems.insert(
                  2,
                  TabItem(
                      icon: Icons.stacked_bar_chart_rounded,
                      title: 'Reports'.tr()));
            }
          }
        } else {
          // No hay respuesta => checar pisos
          final floorsFound = await _checkFloors(userClues);
          if (!floorsFound) {
            _pages.insert(0, const AdminStartScreen());
            _navItems.insert(
                0, TabItem(icon: Icons.meeting_room, title: 'Start'.tr()));
          } else {
            _pages.insert(0, const Management());
            _pages.insert(1, const ManageStaffUsers());
            _pages.insert(2, const DailyReports());

            _navItems.insert(
                0, TabItem(icon: Icons.business_center, title: 'Control'.tr()));
            _navItems.insert(
                1, TabItem(icon: Icons.business_center, title: 'Staff'.tr()));
            _navItems.insert(
                2,
                TabItem(
                    icon: Icons.stacked_bar_chart_rounded,
                    title: 'Reports'.tr()));
          }
        }
      }
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
