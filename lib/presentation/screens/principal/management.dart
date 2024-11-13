import 'package:flutter/material.dart';

class Management extends StatefulWidget {
  const Management({super.key});

  @override
  ManagementState createState() => ManagementState();
}

class ManagementState extends State<Management> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 180.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Management',
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: theme.colorScheme.onSurface,
                  )),
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
                      child: const Text('Services'),
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
                      child: const Text('Rooms'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.7,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/manageProcedureScreen');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Procedures'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.7,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/manageMedications');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Medications'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
