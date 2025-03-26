import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'models/identity_model.dart';
import 'environment.dart';
import 'services/api_service.dart';
import 'widgets/identity_dialog.dart';

class AuthRepository extends ChangeNotifier {
  String? _token;
  String? _displayName;
  String? _avatarUrl;

  String? get displayName => _displayName;
  String? get avatarUrl => _avatarUrl;

  Future<String?> login(
      String username, String password, BuildContext context) async {
    final url =
        '${Environment.SSO_URL}/realms/${Environment.REALM}/protocol/openid-connect/token';

    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': 'KEYCLOAK_LOCALE=fr_FR',
    };

    Map<String, String> data = {
      'client_id': Environment.CLIENT_ID,
      'client_secret': Environment.CLIENT_SECRET,
      'username': username,
      'password': password,
      'grant_type': 'password',
    };

    try {
      print('Tentative de connexion à Keycloak...');
      print('URL: $url');
      print('Data: $data');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: data,
      );

      print('Réponse Keycloak - Statut: ${response.statusCode}');
      print('Réponse Keycloak - Corps: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['access_token'] as String;
        print('Access token obtenu: ${_token!.substring(0, 20)}...');

        // Récupérer les informations d'identité
        if (_token != null && context.mounted) {
          try {
            print(
                'Récupération des informations d\'identité avec access_token...');
            final identity = await ApiService.fetchIdentity(_token!);
            _displayName = identity.displayName;
            _avatarUrl = identity.avatarUrl;
            print('DisplayName récupéré: $_displayName');
            print('AvatarUrl récupéré: $_avatarUrl');
            notifyListeners();
          } catch (e) {
            print('Erreur lors de la récupération de l\'identité: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Erreur lors de la récupération de l\'identité: $e'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }

        return _token;
      } else if (response.statusCode == 401) {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['error_description'] ?? 'NOT_AUTHORIZED');
      } else if (response.statusCode == 400) {
        throw Exception('NEED_EMAIL_VERIFICATION');
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _displayName = null;
    _avatarUrl = null;
    notifyListeners();
  }
}
