import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'http://www.futurelife.somee.com';
  final token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjMiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9lbWFpbGFkZHJlc3MiOiJ0ZXN0QGZ1dHVyZWxpZmUuY29tIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6Ik1vaGFtbWVkIFNhZWFkIiwiZXhwIjoxNzczMTg3ODQ4LCJpc3MiOiJGdXR1cmVMaWZlLkFQSSIsImF1ZCI6IkZ1dHVyZUxpZmUuQ2xpZW50In0.6fLF6WIIUvN7ATphQvHx5rKxUBYICk6sFEF0En1H1wg';

  print('1. Testing Save Simulation...');
  final saveResponse = await http.post(
    Uri.parse('$baseUrl/api/simulation'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode({
      "name": "My 2026 Plan",
      "result": {
        "id": 0, // Int testing
        "name": "My 2026 Plan",
        "savings1Y": 12852.0, "savings5Y": 73918.0, "savings10Y": 172740.0,
        "monthlySavings": 1000.0, "netWorth10Y": 172740.0, "currency": "USD",
        "studyHours1Y": 730.0, "studyHours5Y": 3650.0, "studyHours10Y": 7300.0,
        "healthScore1Y": 57.1, "healthScore5Y": 55.6, "healthScore10Y": 54.3,
        "careerGrowthIndex": 0.7, "salaryMultiplier": 5.2,
        "promotionProbability": 0.44,
        "socialBalanceScore": 37.5, "isolationRisk": 0.625,
        "lifeStrategyScore": 42.5,
        "energyScore1Y": 60.0, "energyScore5Y": 55.8, "energyScore10Y": 50.8,
        "burnoutRisk": 0.3,
        "financialCollapseRisk": 0.6, "careerStagnationRisk": 0.3,
        "energyDepletionRisk": 0.46, "overallRiskIndex": 0.47,
        "yearlySnapshots": [],
        "monthlySnapshots": [],
        "createdAt": "2026-03-04T00:00:00Z"
      }
    }),
  );

  print('Save status: ${saveResponse.statusCode}');
  print('Save Response: ${saveResponse.body}');
}
