import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Display names, icons and colours for backend enum values.
class Labels {
  static const List<String> categories = [
    'DRINKING_WATER', 'ROAD', 'DRAINAGE', 'STREETLIGHT', 'GARBAGE', 'ELECTRICITY',
    'STRAY_CATTLE', 'HEALTH', 'SCHOOL', 'RATION', 'PENSION_HOUSING', 'OTHER',
  ];

  static String category(String c, bool hindi) {
    final pair = switch (c) {
      'DRINKING_WATER' => ('Drinking water', 'पीने का पानी'),
      'ROAD' => ('Road', 'सड़क'),
      'DRAINAGE' => ('Drainage', 'नाली'),
      'STREETLIGHT' => ('Street light', 'स्ट्रीट लाइट'),
      'GARBAGE' => ('Garbage', 'कूड़ा'),
      'ELECTRICITY' => ('Electricity', 'बिजली'),
      'STRAY_CATTLE' => ('Stray cattle', 'छुट्टा पशु'),
      'HEALTH' => ('Health', 'स्वास्थ्य'),
      'SCHOOL' => ('School', 'स्कूल'),
      'RATION' => ('Ration', 'राशन'),
      'PENSION_HOUSING' => ('Pension / housing', 'पेंशन / आवास'),
      _ => ('Other', 'अन्य'),
    };
    return hindi ? pair.$2 : pair.$1;
  }

  static IconData categoryIcon(String c) => switch (c) {
        'DRINKING_WATER' => Icons.water_drop_outlined,
        'ROAD' => Icons.add_road,
        'DRAINAGE' => Icons.waves,
        'STREETLIGHT' => Icons.lightbulb_outline,
        'GARBAGE' => Icons.delete_outline,
        'ELECTRICITY' => Icons.bolt,
        'STRAY_CATTLE' => Icons.pets,
        'HEALTH' => Icons.local_hospital_outlined,
        'SCHOOL' => Icons.school_outlined,
        'RATION' => Icons.storefront_outlined,
        'PENSION_HOUSING' => Icons.home_work_outlined,
        _ => Icons.more_horiz,
      };

  static const List<String> statuses = ['REPORTED', 'IN_PROGRESS', 'RESOLVED'];

  static String status(String s, bool hindi) => switch (s) {
        'REPORTED' => hindi ? 'काम शुरू नहीं' : 'Not started',
        'IN_PROGRESS' => hindi ? 'काम जारी' : 'In progress',
        _ => hindi ? 'पूरा हुआ' : 'Completed',
      };

  static Color statusColor(String s) => switch (s) {
        'REPORTED' => JaColors.red,
        'IN_PROGRESS' => JaColors.yellow,
        _ => JaColors.green,
      };

  static Color ratingColor(String r) => switch (r) {
        'GREEN' => JaColors.green,
        'YELLOW' => JaColors.yellow,
        'RED' => JaColors.red,
        _ => JaColors.grey,
      };
}
