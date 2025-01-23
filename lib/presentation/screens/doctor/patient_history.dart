import 'package:connectcare/presentation/screens/doctor/discharge_details_screen.dart';
import 'package:connectcare/presentation/screens/doctor/medical_instruccions_details_screen.dart';
import 'package:connectcare/presentation/screens/doctor/nursing_sheet_details_screen.dart';
import 'package:connectcare/presentation/screens/doctor/progress_notes_details_Screen.dart';
import 'package:connectcare/presentation/screens/doctor/triage_details_screen.dart';
import 'package:connectcare/presentation/widgets/custom_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientHistory extends StatelessWidget {
  final String nssPaciente;

  const PatientHistory({super.key, required this.nssPaciente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient History'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomButton2(
              text: 'Triage'.tr(),
              icon: Icons.health_and_safety_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TriageDetailsScreen(nssPaciente: nssPaciente),
                  ),
                );
              },
            ),
            CustomButton2(
              text: 'Nursing Sheets'.tr(),
              icon: Icons.receipt_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NursingSheetDetailsScreen(nssPaciente: nssPaciente),
                  ),
                );
              },
            ),
            CustomButton2(
              text: 'Progress Notes'.tr(),
              icon: Icons.notes_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProgressNotesScreen(nssPaciente: nssPaciente),
                  ),
                );
              },
            ),
            CustomButton2(
              text: 'Medical Instructions'.tr(),
              icon: Icons.description_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicalInstructionsDetailsScreen(
                        nssPaciente: nssPaciente),
                  ),
                );
              },
            ),
            CustomButton2(
              text: 'Discharge Records'.tr(),
              icon: Icons.exit_to_app_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DischargeDetailsScreen(nssPaciente: nssPaciente),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
