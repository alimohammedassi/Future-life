import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final baseUrl = 'http://www.futurelife.somee.com';
  final token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjMiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9lbWFpbGFkZHJlc3MiOiJ0ZXN0QGZ1dHVyZWxpZmUuY29tIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6Ik1vaGFtbWVkIFNhZWFkIiwiZXhwIjoxNzczMTg3ODQ4LCJpc3MiOiJGdXR1cmVMaWZlLkFQSSIsImF1ZCI6IkZ1dHVyZUxpZmUuQ2xpZW50In0.6fLF6WIIUvN7ATphQvHx5rKxUBYICk6sFEF0En1H1wg';

  print('Testing get history...');
  final historyResponse = await http.get(
    Uri.parse('$baseUrl/api/simulation/history'),
    headers: {'Authorization': 'Bearer $token'},
  );
  print('History: ${historyResponse.statusCode}');
  print('Body: ${historyResponse.body}');

  if (historyResponse.statusCode == 200) {
    final List items = jsonDecode(historyResponse.body)['data'] ?? [];
    print('History length: ${items.length}');
  }

  print('Testing delete /api/simulation/all ...');
  final delAllResponse = await http.delete(
    Uri.parse('$baseUrl/api/simulation/all'),
    headers: {'Authorization': 'Bearer $token'},
  );
  print('Del ALL status: ${delAllResponse.statusCode}');
  print('Del ALL body: ${delAllResponse.body}');

  print('Testing delete /api/simulation/history ...');
  final delHistResponse = await http.delete(
    Uri.parse('$baseUrl/api/simulation/history'),
    headers: {'Authorization': 'Bearer $token'},
  );
  print('Del history status: ${delHistResponse.statusCode}');
  print('Del history body: ${delHistResponse.body}');
}
