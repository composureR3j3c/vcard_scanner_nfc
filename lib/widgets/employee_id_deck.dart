import 'package:flutter/material.dart';

import '../employee_profile.dart';
import 'employee_id_back.dart';
import 'employee_id_front.dart';

class EmployeeIdDeck extends StatelessWidget {
  const EmployeeIdDeck({
    super.key,
    required this.profile,
    required this.qrData,
  });

  final EmployeeProfile profile;
  final String qrData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmployeeIdFront(profile: profile),
        const SizedBox(height: 18),
        EmployeeIdBack(profile: profile, qrData: qrData),
      ],
    );
  }
}
