import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/subscriptions_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:siprix_voip_sdk/network_model.dart';

import 'accouns_model_app.dart';
import 'calls_model_app.dart';
import 'subscr_model_app.dart';

import 'account_add.dart';
import 'subscr_add.dart';
import 'settings.dart';
import 'home.dart';
import 'login_page.dart';
import 'auth_repository.dart';
import 'services/api_service.dart' as api;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SiprixVoipSdk().initialize(InitData());
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Erreur lors de l\'initialisation: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Erreur d\'initialisation: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static String _ringtonePath = "";

  static String getRingtonePath() => _ringtonePath;

  Future<void> writeRingtoneAsset() async {
    try {
      _ringtonePath = await writeAssetAndGetFilePath("ringtone.mp3");
    } catch (e) {
      debugPrint('Erreur lors de l\'écriture de la sonnerie: $e');
    }
  }

  static Future<String> writeAssetAndGetFilePath(String assetsFileName) async {
    try {
      var homeFolder = await SiprixVoipSdk().homeFolder();
      var filePath = '$homeFolder$assetsFileName';

      var file = File(filePath);
      var exists = file.existsSync();
      debugPrint("writeAsset: '$filePath' exists:$exists");
      if (exists) return filePath;

      final byteData = await rootBundle.load('assets/$assetsFileName');
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return filePath;
    } catch (e) {
      debugPrint('Erreur lors de l\'écriture du fichier: $e');
      rethrow;
    }
  }

  static Future<String> getRecFilePath(String recFileName) async {
    try {
      var homeFolder = await SiprixVoipSdk().homeFolder();
      var filePath = '$homeFolder$recFileName';
      return filePath;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du chemin: $e');
      rethrow;
    }
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.writeRingtoneAsset();
  }

  @override
  Widget build(BuildContext context) {
    // Personnalisation du widget d'erreur
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          'Une erreur est survenue: ${details.exception}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        ChangeNotifierProvider(create: (_) => DevicesModel()),
      ],
      child: MaterialApp(
        navigatorKey: api.navigatorKey,
        title: 'Siprix VoIP SDK Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: LoginPage(),
      ),
    );
  }

  static void _initializeSiprix([LogsModel? logsModel]) async {
    debugPrint('_initializeSiprix');

    // Vérifier si on est sur le web
    if (kIsWeb) {
      debugPrint('Exécution en mode web - utilisation du mode démonstration');

      // En mode web, nous n'initialisons pas réellement le SDK car il utilise des fonctionnalités natives
      // qui ne sont pas disponibles sur le web. À la place, nous simulons l'initialisation.

      // Afficher un message au lieu d'initialiser le SDK
      if (logsModel != null) {
        logsModel.print(
            "INFO: Le SDK Octovia fonctionne en mode démonstration sur le web.");
        logsModel.print(
            "INFO: Les fonctionnalités natives comme les appels SIP ne sont pas disponibles.");
        logsModel.print(
            "INFO: Veuillez utiliser l'application native pour les fonctionnalités complètes.");
      }

      // Notifier l'interface utilisateur que nous sommes en mode démonstration web
      // avec un léger délai pour simuler l'initialisation
      await Future.delayed(const Duration(seconds: 1));

      return;
    }

    // Code existant pour les plateformes natives
    InitData iniData = InitData();
    iniData.license = "...license-credentials...";
    iniData.logLevelFile = LogLevel.debug;
    iniData.logLevelIde = LogLevel.info;
    //- uncomment if required -//
    //iniData.listenTelState = true;
    //iniData.singleCallMode = false;
    //iniData.tlsVerifyServer = false;
    //iniData.enableCallKit = true;
    //iniData.enablePushKit = true;
    await SiprixVoipSdk().initialize(iniData, logsModel);

    //Set video params (if required)
    //VideoData vdoData = VideoData();
    //vdoData.noCameraImgPath = await MyApp.writeAssetAndGetFilePath("noCamera.jpg");
    //vdoData.bitrateKbps = 800;
    //SiprixVoipSdk().setVideoParams(vdoData);
  }

  void _readSavedState() {
    debugPrint('_readSavedState');
    SharedPreferences.getInstance().then((prefs) {
      String accJsonStr = prefs.getString('accounts') ?? '';
      String subsJsonStr = prefs.getString('subscriptions') ?? '';
      String cdrsJsonStr = prefs.getString('cdrs') ?? '';
      _loadModels(accJsonStr, cdrsJsonStr, subsJsonStr);
    });
  }

  void _loadModels(String accJsonStr, String cdrsJsonStr, String subsJsonStr) {
    //Accounts
    AppAccountsModel accsModel = context.read<AppAccountsModel>();
    accsModel.onSaveChanges = _saveAccountChanges;

    //Subscriptions
    SubscriptionsModel subs = context.read<SubscriptionsModel>();
    subs.onSaveChanges = _saveSubscriptionChanges;

    //CDRs (Call Details Records)
    CdrsModel cdrs = context.read<CdrsModel>();
    cdrs.onSaveChanges = _saveCdrsChanges;

    //Load accounts, then other models
    accsModel.loadFromJson(accJsonStr).then((val) {
      subs.loadFromJson(subsJsonStr);
      cdrs.loadFromJson(cdrsJsonStr);
    });

    //Assign contact name resolver
    context.read<AppCallsModel>().onResolveContactName = _resolveContactName;

    //Load devices
    context.read<DevicesModel>().load();
  }

  void _saveCdrsChanges(String cdrsJsonStr) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('cdrs', cdrsJsonStr);
    });
  }

  void _saveAccountChanges(String accountsJsonStr) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('accounts', accountsJsonStr);
    });
  }

  void _saveSubscriptionChanges(String subscrJsonStr) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('subscriptions', subscrJsonStr);
    });
  }

  String _resolveContactName(String phoneNumber) {
    return ""; //TODO add own implementation
    //if(phoneNumber=="100") { return "MyFriend100"; } else
    //if(phoneNumber=="101") { return "MyFriend101"; }
    //else                  { return "";        }
  }
}

/// Page de démonstration pour le web, qui explique les limitations
class WebDemoPage extends StatelessWidget {
  const WebDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(
              Icons.headset_mic_rounded,
              color: Color(0xFF2A3990),
            ),
            SizedBox(width: 12),
            Text(
              'Octovia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A3990),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: const Color(0xFF2A3990),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Octovia',
                applicationVersion: 'Version Web',
                applicationLegalese: '© 2025 Octovia. Tous droits réservés.',
                applicationIcon: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF2A3990), Color(0xFF4481EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.headset_mic_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A3990), Color(0xFF4481EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4481EB).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.headset_mic,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Mode de démonstration web',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3990),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Certaines fonctionnalités ne sont pas disponibles dans la version web',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildInfoItem(
                      icon: Icons.mic_off,
                      title: 'Fonctionnalités audio',
                      description:
                          'Les appels audio SIP nécessitent l\'application native',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      icon: Icons.videocam_off,
                      title: 'Fonctionnalités vidéo',
                      description:
                          'Les appels vidéo nécessitent l\'application native',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      icon: Icons.perm_device_information,
                      title: 'Accès aux périphériques',
                      description:
                          'L\'accès aux microphones et caméras est limité sur le web',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Pour profiter de toutes les fonctionnalités, veuillez télécharger l\'application native pour votre plateforme.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF677294),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDownloadButton(
                    icon: Icons.apple,
                    text: 'iOS',
                    onPressed: () {
                      // Lien vers App Store
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildDownloadButton(
                    icon: Icons.android,
                    text: 'Android',
                    onPressed: () {
                      // Lien vers Play Store
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildDownloadButton(
                    icon: Icons.desktop_windows,
                    text: 'Desktop',
                    onPressed: () {
                      // Lien vers la version desktop
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3990).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2A3990),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF677294),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2A3990),
        side: const BorderSide(color: Color(0xFF2A3990)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/*
//=======================================//
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';

void main() async {
  AccountsModel accountsModel = AccountsModel();
  CallsModel callsModel = CallsModel(accountsModel);
  runApp(
    MultiProvider(providers:[
      ChangeNotifierProvider(create: (context) => accountsModel),
      ChangeNotifierProvider(create: (context) => callsModel),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeSiprix();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siprix VoIP app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(body:buildBody())
    );
  }

  Widget buildBody() {
    final accounts = context.watch<AppAccountsModel>();
    final calls = context.watch<AppCallsModel>();
    return Column(children: [
      ListView.separated(
        shrinkWrap: true,
        itemCount: accounts.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          AccountModel acc = accounts[index];
          return
            ListTile(title: Text(acc.uri, style: Theme.of(context).textTheme.titleSmall),
                subtitle: Text(acc.regText),
                tileColor: Colors.blue
            );
        },
      ),
      ElevatedButton(onPressed: _addAccount, child: const Icon(Icons.add_card)),
      const Divider(height: 1),
      ListView.separated(
        shrinkWrap: true,
        itemCount: calls.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          CallModel call = calls[index];
          return
            ListTile(title: Text(call.nameAndExt, style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text(call.state.name), tileColor: Colors.amber,
              trailing: IconButton(
                onPressed: (){ call.bye(); },
                icon: const Icon(Icons.call_end))
            );
        },
      ),
      ElevatedButton(onPressed: _addCall, child: const Icon(Icons.add_call)),
      const Spacer(),
    ]);
  }

  void _initializeSiprix([LogsModel? logsModel]) async {
    InitData iniData = InitData();
    iniData.license  = "...license-credentials...";
    iniData.logLevelFile = LogLevel.info;
    SiprixVoipSdk().initialize(iniData, logsModel);
  }

  void _addAccount() {
    AccountModel account = AccountModel();
    account.sipServer = "192.168.0.122";
    account.sipExtension = "1016";
    account.sipPassword = "12345";
    account.expireTime = 300;
    context.read<AppAccountsModel>().addAccount(account)
      .catchError(showSnackBar);
  }

  void _addCall() {
    final accounts = context.read<AppAccountsModel>();
    if(accounts.selAccountId==null) return;

    CallDestination dest = CallDestination("1012", accounts.selAccountId!, false);

    context.read<AppCallsModel>().invite(dest)
      .catchError(showSnackBar);
  }

  void showSnackBar(dynamic err) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  }
}
*/
