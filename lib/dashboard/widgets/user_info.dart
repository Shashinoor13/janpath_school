import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:intl/intl.dart';
import 'package:janpath_school/dashboard/widgets/info_row.dart';

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({super.key});

  String _getSystemInfo() {
    if (kIsWeb) {
      // On web, Platform info is not available, you may inject via JS if needed
      return "Web Browser";
    }
    return "${Platform.operatingSystem} ${Platform.operatingSystemVersion}";
  }

  @override
  Widget build(BuildContext context) {
    // Nepali date (BS)
    final nepaliDate = NepaliDateTime.now();
    final formattedNepaliDate = NepaliDateFormat(
      "yyyy-MM-dd",
    ).format(nepaliDate);

    // Local Nepali time
    final localTime = DateFormat("HH:mm:ss").format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRow(
          label: 'आजको मिति (Bikram Sambat):',
          value: formattedNepaliDate,
        ),
        const SizedBox(height: 8),
        InfoRow(label: 'स्थानीय समय:', value: localTime),
        const SizedBox(height: 8),
        InfoRow(
          label: 'सिस्टम:',
          value: _getSystemInfo(),
          valueColor: Colors.grey[600],
        ),
      ],
    );
  }
}
