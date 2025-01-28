import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/screens/admin/manage_medicaments_screen.dart';
import 'package:connectcare/presentation/screens/admin/movement_history.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Management extends StatefulWidget {
  const Management({super.key});

  @override
  ManagementState createState() => ManagementState();
}

class ManagementState extends State<Management> {
  final UserService _userService = UserService();
  String clues = '';
  @override
  void initState() {
    super.initState();
    _loadData();
    _notifications();
  }

  Future<void> _loadData() async {
    final data = await _userService.loadUserData();
    setState(() {
      clues = (data['clues'] ?? '');
    });
  }

  Future<void> _notifications() async {
    final userService = UserService();
    await userService.updateFirebaseTokenAndSendNotification();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text('Management',
                    style: theme.textTheme.headlineLarge!.copyWith(
                      color: theme.colorScheme.onSurface,
                    )),
                SizedBox(
                  height: 210,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/manageServiceScreen');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text('Services'.tr()),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/manageRoomScreen');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text('Rooms'.tr()),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/manageProcedureScreen');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text('Procedures'.tr()),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManageMedications()));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text('Medications'.tr()),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MovementHistory(
                                        clues: clues,
                                      )));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text('Historial'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
