import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';

import 'accouns_model_app.dart';
import 'main.dart';

////////////////////////////////////////////////////////////////////////////////////////
//AccountPage - represents fields of selected account. Used for adding/editing accounts

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  static const routeName = '/addAccount';

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  AccountModel _account = AccountModel();
  String _errText = "";

  // Tracking expanded sections
  bool _isTransportExpanded = false;
  bool _isProxyExpanded = false;
  bool _isSecurityExpanded = false;
  bool _isAdvancedExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _account = ModalRoute.of(context)!.settings.arguments as AccountModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2A3990),
        title: Text(
          isAddMode() ? 'Nouveau compte' : 'Modifier compte',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2A3990)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Base Account Info Card
                _buildCard(
                  title: "Informations du compte",
                  icon: Icons.account_circle_outlined,
                  children: [
                    const SizedBox(height: 8),
                    _buildTextField(
                      label: 'Serveur SIP',
                      hint: 'sip.example.com',
                      onChanged: (value) {
                        if (value.isNotEmpty) _account.sipServer = value;
                      },
                      initialValue: _account.sipServer,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Veuillez saisir un domaine'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Extension SIP',
                      hint: 'utilisateur ou numéro',
                      onChanged: (value) {
                        if (value.isNotEmpty) _account.sipExtension = value;
                      },
                      initialValue: _account.sipExtension,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Veuillez saisir un nom d\'utilisateur'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Mot de passe SIP',
                      hint: '••••••••',
                      obscureText: true,
                      onChanged: (value) {
                        if (value.isNotEmpty) _account.sipPassword = value;
                      },
                      initialValue: _account.sipPassword,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Veuillez saisir un mot de passe'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'ID d\'authentification (optionnel)',
                      hint: 'utilisé si différent de l\'extension',
                      onChanged: (value) {
                        _account.sipAuthId = value.isEmpty ? null : value;
                      },
                      initialValue: _account.sipAuthId,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Nom d\'affichage (optionnel)',
                      hint: 'Nom affiché aux correspondants',
                      onChanged: (value) {
                        _account.displName = value.isEmpty ? null : value;
                      },
                      initialValue: _account.displName,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'User-Agent (optionnel)',
                      hint: 'En-tête User-Agent SIP',
                      onChanged: (value) {
                        _account.userAgent = value.isEmpty ? null : value;
                      },
                      initialValue: _account.userAgent ?? "siprix",
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Délai d\'expiration (secondes)',
                      hint: '300',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isNotEmpty)
                          _account.expireTime = int.parse(value);
                      },
                      initialValue: _account.expireTime?.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Transport Section
                _buildExpandableCard(
                  title: "Transport",
                  icon: Icons.sync_alt_rounded,
                  isExpanded: _isTransportExpanded,
                  onTap: () => setState(
                      () => _isTransportExpanded = !_isTransportExpanded),
                  children: [
                    const SizedBox(height: 8),
                    _buildDropdown<SipTransport>(
                      label: 'Protocole de transport',
                      value: _account.transport ?? SipTransport.udp,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            _account.transport = value;
                          }
                        });
                      },
                      items: SipTransport.values
                          .map((t) => DropdownMenuItem<SipTransport>(
                                value: t,
                                child: Text(t.name.toUpperCase()),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Port local',
                      hint: '0 = aléatoire',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        _account.port = value.isEmpty ? null : int.parse(value);
                      },
                      initialValue: _account.port?.toString(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Chemin du certificat CA (TLS)',
                      hint: 'Chemin vers le fichier CA',
                      onChanged: (value) {
                        _account.tlsCaCertPath = value.isEmpty ? null : value;
                      },
                      initialValue: _account.tlsCaCertPath,
                    ),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label: 'Utiliser "sip:" au lieu de "sips:" avec TLS',
                      value: _account.tlsUseSipScheme,
                      onChanged: (value) {
                        setState(() {
                          _account.tlsUseSipScheme = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSwitch(
                      label: 'Activer RTCP Mux (même port pour RTP/RTCP)',
                      value: _account.rtcpMuxEnabled,
                      onChanged: (value) {
                        setState(() {
                          _account.rtcpMuxEnabled = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Proxy Section
                _buildExpandableCard(
                  title: "Proxy",
                  icon: Icons.router_outlined,
                  isExpanded: _isProxyExpanded,
                  onTap: () =>
                      setState(() => _isProxyExpanded = !_isProxyExpanded),
                  children: [
                    const SizedBox(height: 8),
                    _buildTextField(
                      label: 'Proxy SIP',
                      hint: 'proxy.example.com',
                      onChanged: (value) {
                        _account.sipProxy = value.isEmpty ? null : value;
                      },
                      initialValue: _account.sipProxy,
                    ),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label:
                          'Forcer l\'utilisation du proxy pour toutes les requêtes',
                      value: _account.forceSipProxy,
                      onChanged: (value) {
                        setState(() {
                          _account.forceSipProxy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSwitch(
                      label: 'Réécrire l\'adresse IP du Contact',
                      value: _account.rewriteContactIp,
                      onChanged: (value) {
                        setState(() {
                          _account.rewriteContactIp = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Security Section
                _buildExpandableCard(
                  title: "Sécurité et médias",
                  icon: Icons.security_outlined,
                  isExpanded: _isSecurityExpanded,
                  onTap: () => setState(
                      () => _isSecurityExpanded = !_isSecurityExpanded),
                  children: [
                    const SizedBox(height: 8),
                    _buildDropdown<SecureMedia>(
                      label: 'Chiffrement audio/vidéo',
                      value: _account.secureMedia ?? SecureMedia.Disabled,
                      onChanged: (value) {
                        setState(() {
                          _account.secureMedia = value;
                        });
                      },
                      items: SecureMedia.values
                          .map((s) => DropdownMenuItem<SecureMedia>(
                                value: s,
                                child: Text(s.name),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      label: 'Vérifier SDP des appels entrants',
                      value: _account.verifyIncomingCall,
                      onChanged: (value) {
                        setState(() {
                          _account.verifyIncomingCall = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Advanced Section
                _buildExpandableCard(
                  title: "Avancé",
                  icon: Icons.tune_outlined,
                  isExpanded: _isAdvancedExpanded,
                  onTap: () => setState(
                      () => _isAdvancedExpanded = !_isAdvancedExpanded),
                  children: [
                    const SizedBox(height: 8),
                    _buildTextField(
                      label: 'ID d\'instance unique (RFC 5626)',
                      hint: 'Identificateur unique',
                      onChanged: (value) {
                        _account.instanceId = value.isEmpty ? null : value;
                      },
                      initialValue: _account.instanceId,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Délai Keep-Alive (secondes)',
                      hint: '30',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        _account.keepAliveTime =
                            value.isEmpty ? null : int.parse(value);
                      },
                      initialValue: _account.keepAliveTime?.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(),

                if (!kIsWeb && _errText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errText,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),

      // Affiche un message informatif pour la version web
      bottomSheet: kIsWeb ? _buildWebNotification() : null,
    );
  }

  Widget _buildCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF2A3990),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A3990),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Container(
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
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF2A3990),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A3990),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF2A3990),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) const Divider(height: 1),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    String? initialValue,
    bool enabled = true,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF677294),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF2A3990), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required Function(T?)? onChanged,
    required List<DropdownMenuItem<T>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF677294),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            onChanged: onChanged,
            items: items,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              border: InputBorder.none,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2A3990)),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    // Ensure value is not null for the switch
    final switchValue = value ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Switch(
            value: switchValue,
            onChanged: onChanged,
            activeColor: const Color(0xFF2A3990),
            activeTrackColor: const Color(0xFFD4D9F6),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _submit,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A3990), Color(0xFF4481EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4481EB).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            height: 56,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isAddMode() ? Icons.add_circle_outline : Icons.update,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  isAddMode() ? 'Ajouter le compte' : 'Mettre à jour',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isAddMode() {
    return (_account.myAccId == 0);
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    // Si nous sommes sur le web, afficher un message d'information au lieu d'ajouter réellement le compte
    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Mode démo web'),
            content: const Text(
              'La fonctionnalité d\'ajout de compte SIP n\'est pas disponible dans la version web d\'Octovia. Veuillez utiliser l\'application native pour accéder à toutes les fonctionnalités.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Compris'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (isAddMode()) {
      _account.ringTonePath = MyApp.getRingtonePath();
      context.read<AppAccountsModel>().addAccount(_account).then((_) {
        Navigator.pop(context, true);
      }).catchError((error) {
        setState(() {
          _errText = error.toString();
        });
      });
    } else {
      context.read<AppAccountsModel>().updateAccount(_account).then((_) {
        Navigator.pop(context, true);
      }).catchError((error) {
        setState(() {
          _errText = error.toString();
        });
      });
    }
  }

  // Notification pour la version web
  Widget _buildWebNotification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Version web limitée : certaines fonctionnalités ne sont pas disponibles",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF994C00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
