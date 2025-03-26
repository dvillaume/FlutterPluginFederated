import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/identity_model.dart';
import '../environment.dart';

class IdentityService {
  static Future<Identity> fetchIdentity(String token) async {
    print(
        'Envoi de la requête à l\'API logme avec le token: ${token.substring(0, 20)}...');

    final response = await http.get(
      Uri.parse('http://172.16.37.209:9000/api/v1/logme'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Statut de la réponse API: ${response.statusCode}');
    print('Corps de la réponse API: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final identity = Identity.fromJson(data);
      print('Identité récupérée: ${identity.displayName}');
      return identity;
    } else {
      print('Erreur HTTP: ${response.statusCode} - ${response.body}');
      throw Exception('Échec de la requête API: ${response.statusCode}');
    }
  }
}
