import 'package:flutter/material.dart';
import '../api_client/apiClient.dart';
import '../constants/end_points.dart';
import '../models/enroll_investment_plans.dart';

class EnrollInvestmentProvider with ChangeNotifier {

  final ApiClient apiClient = ApiClient();
  EnrollInvestmentPlans? get enrollResponse =>_enrollResponse;
  EnrollInvestmentPlans? _enrollResponse;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> enrollInvestment(Map<String, dynamic> fields) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await apiClient.PostMethod(enrollInvestments, fields);

      print("📩 Enroll Investment Response: $response");
      print("📤 Fields Sent: $fields");

      if (response != null) {
        _enrollResponse = EnrollInvestmentPlans.fromJson(response);
        debugPrint("✅ Enrollment Status: ${enrollResponse?.status}");
      } else {
        _enrollResponse = null;
      }
    } catch (e) {
      debugPrint("❌ ERROR: $e");
      _enrollResponse;
    }

    _loading = false;
    notifyListeners();
  }
}
