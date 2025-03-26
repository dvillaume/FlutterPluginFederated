import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/identity_model.dart';
import '../environment.dart';
import 'package:flutter/material.dart';

class ApiService {
  static Future<Identity> fetchIdentity(String token) async {
    // TODO: Implémenter la nouvelle requête API
    throw UnimplementedError('Nouvelle requête API à implémenter');
  }

  static Future<void> _fetchDokoConfig(String identityId, String token) async {
    final url =
        Uri.parse('http://172.16.37.209:9000/api/v1/doko/config').replace(
      queryParameters: {
        'identity_id': identityId,
        'voice_account_type': 'CENTREX',
        'organization_id': '3c371765-049a-4f75-b216-803072d92d2c',
      },
    );

    print('Appel de l\'API Doko avec l\'ID: $identityId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Statut de la réponse Doko: ${response.statusCode}');
    print('Corps de la réponse Doko: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _showDokoConfigDialog(data);
    } else {
      print('Erreur HTTP Doko: ${response.statusCode} - ${response.body}');
      throw Exception('Échec de la requête Doko: ${response.statusCode}');
    }
  }

  static void _showDokoConfigDialog(Map<String, dynamic> config) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configuration Doko'),
          content: SingleChildScrollView(
            child: Text(
              const JsonEncoder.withIndent('  ').convert(config),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Clé globale pour accéder au contexte de navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
