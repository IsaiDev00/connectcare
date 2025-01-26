import 'package:connectcare/presentation/screens/admin/completed_transfer_requests_history.dart';
import 'package:connectcare/presentation/screens/admin/discharges_history.dart';
import 'package:connectcare/presentation/screens/admin/medical_instructions_history.dart';
import 'package:connectcare/presentation/screens/admin/nursing_sheet_history.dart';
import 'package:connectcare/presentation/screens/admin/progress_note_history.dart';
import 'package:connectcare/presentation/screens/admin/scheduled_procedures_history.dart';
import 'package:connectcare/presentation/screens/admin/triage_history.dart';
import 'package:connectcare/presentation/widgets/custom_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MovementHistory extends StatelessWidget {
  final String clues;

  const MovementHistory({super.key, required this.clues});

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00A0A6)),
          const SizedBox(width: 8),
          Text(
            title.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 1.5,
      color: Colors.blueGrey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movement history'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Enfermeros', Icons.monitor_heart),
              CustomButton2(
                text: 'Nursing Sheet'.tr(),
                icon: Icons.receipt_outlined,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NursingSheetHistory(hospitalId: clues),
                      ));
                },
              ),
              _buildDivider(),
              _buildSectionTitle('Médicos', Icons.monitor_heart),
              CustomButton2(
                text: 'Triage'.tr(),
                icon: Icons.health_and_safety_outlined,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TriageHistory(hospitalId: clues),
                      ));
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
                            ProgressNoteHistory(hospitalId: clues),
                      ));
                },
              ),
              CustomButton2(
                text: 'Medical Instructions'.tr(),
                icon: Icons.description_outlined,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicalInstructionsHistory(hospitalId: clues),
                      ));
                },
              ),
              CustomButton2(
                text: 'Scheduled procedures'.tr(),
                icon: Icons.description_outlined,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ScheduledProceduresHistory(hospitalId: clues),
                      ));
                },
              ),
              CustomButton2(
                text: 'Discharges'.tr(),
                icon: Icons.exit_to_app_outlined,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DischargesHistory(hospitalId: clues),
                      ));
                },
              ),
              _buildDivider(),
              _buildSectionTitle('Camilleros', Icons.monitor_heart),
              CustomButton2(
                text: 'Completed transfer requests'.tr(),
                icon: Icons.transfer_within_a_station,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CompletedTransferRequestsHistory(hospitalId: clues),
                      ));
                },
              ),
              _buildDivider(),
              _buildSectionTitle('Recursos humanos', Icons.monitor_heart),
              CustomButton2(
                text: 'Work schedules'.tr(),
                icon: Icons.schedule,
                onPressed: () {},
              ),
              _buildDivider(),
              _buildSectionTitle('Social worker', Icons.monitor_heart),
              CustomButton2(
                text: 'Family links'.tr(),
                icon: Icons.diversity_1,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
