import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/identity_service.dart';
import 'widgets/identity_dialog.dart';
import 'environment.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:siprix_voip_sdk/network_model.dart';
import 'accouns_model_app.dart';
import 'models/identity_model.dart';

class AuthRepository extends ChangeNotifier {
  String? _token;
  String? _displayName;
  String? _avatarUrl;

  String? get token => _token;
  String? get displayName => _displayName;
  String? get avatarUrl => _avatarUrl;

  Future<String?> login(
      String username, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${Environment.SSO_URL}/realms/${Environment.REALM}/protocol/openid-connect/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'locale=fr',
        },
        body: {
          'client_id': Environment.CLIENT_ID,
          'client_secret': Environment.CLIENT_SECRET,
          'username': username,
          'password': password,
          'grant_type': 'password',
        },
      );

      print('URL de la requête: ${response.request?.url}');
      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        print('Token obtenu: ${_token?.substring(0, 20)}...');

        // Récupérer l'identité avec le nouveau service
        final identity = await IdentityService.fetchIdentity(_token!);
        _displayName = identity.displayName;
        _avatarUrl = identity.avatarUrl;
        print('DisplayName récupéré: $_displayName');
        print('AvatarUrl récupéré: $_avatarUrl');
        notifyListeners();

        // Créer le compte SIP
        await _createSipAccount(context, identity);

        return _token;
      } else {
        print('Erreur d\'authentification: ${response.statusCode}');
        print('Corps de l\'erreur: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception lors de l\'authentification: $e');
      return null;
    }
  }

  Future<void> _createSipAccount(
      BuildContext context, Identity identity) async {
    try {
      final accountsModel = context.read<AppAccountsModel>();

      // Créer un nouveau compte SIP
      final account = AccountModel();
      account.sipServer = identity.domain;
      account.sipExtension = identity.alternateLogin;
      account.sipPassword = identity.accountSipPassword;
      account.sipAuthId = '${identity.accountLogin}@${identity.domain}';
      account.sipProxy = identity.sipAccessFqdn;
      account.transport = SipTransport.udp;
      account.expireTime = 300; // 5 minutes par défaut

      // Ajouter le compte
      await accountsModel.addAccount(account);
      print('Compte SIP créé avec succès');
    } catch (e) {
      print('Erreur lors de la création du compte SIP: $e');
      throw Exception('Impossible de créer le compte SIP: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _displayName = null;
    _avatarUrl = null;
    notifyListeners();
  }
}
