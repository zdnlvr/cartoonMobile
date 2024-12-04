import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'https://api.sampleapis.com/cartoons/cartoons2D';

  Future<List<dynamic>> fetchCartoons() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> cartoons = json.decode(response.body);
        return cartoons;
      } else {
        throw Exception('Failed to load cartoons');
      }
    } catch (e) {
      throw Exception('Failed to load cartoons: $e');
    }
  }
}
