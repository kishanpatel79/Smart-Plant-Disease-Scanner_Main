// rental_data.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RentalEntry {
  final String toolName;
  final int days;
  final String deliveryAddress;
  final double dailyRate;
  final bool isLateReturn;
  final bool deliveryRequired;
  final DateTime rentalDate;

  RentalEntry({
    required this.toolName,
    required this.days,
    required this.deliveryAddress,
    required this.dailyRate,
    this.isLateReturn = false,
    this.deliveryRequired = false,
    DateTime? rentalDate,
  }) : rentalDate = rentalDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'toolName': toolName,
    'days': days,
    'deliveryAddress': deliveryAddress,
    'dailyRate': dailyRate,
    'isLateReturn': isLateReturn,
    'deliveryRequired': deliveryRequired,
    'rentalDate': rentalDate.toIso8601String(),
  };

  factory RentalEntry.fromJson(Map<String, dynamic> json) => RentalEntry(
    toolName: json['toolName'],
    days: json['days'],
    deliveryAddress: json['deliveryAddress'],
    dailyRate: json['dailyRate'],
    isLateReturn: json['isLateReturn'],
    deliveryRequired: json['deliveryRequired'],
    rentalDate: DateTime.parse(json['rentalDate']),
  );

  double calculateBaseCost() => days * dailyRate;

  double get discount => days > 7 ? calculateBaseCost() * 0.10 : 0.0;

  double get lateReturnPenalty => isLateReturn ? 100.0 * (days - 1) : 0.0;

  double get deliveryCharge => deliveryRequired ? 200.0 : 0.0;

  double get totalCost => calculateBaseCost() - discount + lateReturnPenalty + deliveryCharge;

  String get costSummary => '''
Base: ₹${calculateBaseCost().toStringAsFixed(2)}
Discount: ₹${discount.toStringAsFixed(2)}
Late Penalty: ₹${lateReturnPenalty.toStringAsFixed(2)}
Delivery: ₹${deliveryCharge.toStringAsFixed(2)}
Total: ₹${totalCost.toStringAsFixed(2)}
''';
}

class RentalData {
  static List<RentalEntry> rentalEntries = [];

  static Future<void> loadRentals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rentalsJson = prefs.getString('rentals');
    if (rentalsJson != null) {
      final List<dynamic> decoded = json.decode(rentalsJson);
      rentalEntries = decoded.map((e) => RentalEntry.fromJson(e)).toList();
      print('\n=== Loaded Rental History ===');
      print('Number of rentals: ${rentalEntries.length}');
      print('============================\n');
    }
  }

  static Future<void> addRental(RentalEntry entry) async {
    rentalEntries.add(entry);
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(rentalEntries.map((e) => e.toJson()).toList());
    await prefs.setString('rentals', encoded);
    print('\n=== New Rental Added ===');
    print('Tool: ${entry.toolName}');
    print('Days: ${entry.days}');
    print('Total Cost: ₹${entry.totalCost.toStringAsFixed(2)}');
    print('======================\n');
  }

  static Future<void> clearRentals() async {
    rentalEntries.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rentals');
    print('\n=== Cleared Rental History ===');
    print('All rental data has been cleared');
    print('==============================\n');
  }
}
