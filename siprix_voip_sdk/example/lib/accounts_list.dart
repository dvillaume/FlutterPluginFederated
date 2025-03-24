import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:siprix_voip_sdk/accounts_model.dart';
import 'accouns_model_app.dart';
import 'account_add.dart';

////////////////////////////////////////////////////////////////////////////////////////
//AccountsListPage - represents list of accounts

class AccountsListPage extends StatefulWidget {
  const AccountsListPage({super.key});

  @override
  State<AccountsListPage> createState() => _AccountsListPageState();
}

enum AccAction { delete, unregister, register, edit }

class _AccountsListPageState extends State<AccountsListPage> {
  // Couleurs principales de l'application
  static const Color primaryColor = Color(0xFF2A3990);
  static const Color accentColor = Color(0xFF4481EB);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color subtitleColor = Color(0xFF677294);

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AppAccountsModel>();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Comptes SIP",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 24),
              accounts.length > 0
                  ? Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        itemCount: accounts.length,
                        itemBuilder: (context, index) =>
                            _buildAccountCard(accounts, index),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                      ),
                    )
                  : _buildEmptyAccountsList(),
            ],
          ),
        ),
        if (accounts.length > 0)
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _addAccount,
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyAccountsList() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo Octovia
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cercle externe
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Cercle intermédiaire
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Cercle interne avec dégradé
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            accentColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Icône stylisée au centre
                    const Icon(
                      Icons.headset_mic_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    // Cercle décoratif en haut à droite
                    Positioned(
                      top: 30,
                      right: 30,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Texte Octovia
            const Text(
              "Bienvenue sur Octovia",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Aucun compte SIP configuré",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 280,
              child: const Text(
                "Ajoutez un compte pour commencer à passer et recevoir des appels professionnels",
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Bouton d'action principal
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _addAccount,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Configurer un compte',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(AccountsModel accounts, int index) {
    AccountModel acc = accounts[index];
    final isSelected = accounts.selAccountId == acc.myAccId;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
      ),
      child: InkWell(
        onTap: () => onTapAccListTile(acc.myAccId),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getAccStatusIndicator(acc.regState),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          acc.uri,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${acc.myAccId} • ${_getRegStatusText(acc.regState)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildAccountActionsMenu(acc, index),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRegStatusText(RegState state) {
    switch (state) {
      case RegState.success:
        return 'Enregistré';
      case RegState.failed:
        return 'Échec d\'enregistrement';
      case RegState.inProgress:
        return 'Enregistrement en cours';
      default:
        return 'Non enregistré';
    }
  }

  Widget _getAccStatusIndicator(RegState s) {
    Color color;
    IconData icon;

    switch (s) {
      case RegState.success:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case RegState.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
      case RegState.inProgress:
        color = Colors.orange;
        icon = Icons.access_time;
        break;
      default:
        color = Colors.grey;
        icon = Icons.remove_circle_outline;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildAccountActionsMenu(AccountModel acc, int index) {
    return PopupMenuButton<AccAction>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_vert,
          color: primaryColor,
        ),
      ),
      onSelected: (AccAction action) {
        _doAccountAction(action, index);
      },
      itemBuilder: (BuildContext context) => [
        _buildPopupMenuItem(
          AccAction.edit,
          'Modifier',
          Icons.edit_outlined,
          true,
        ),
        _buildPopupMenuItem(
          AccAction.register,
          'Enregistrer',
          Icons.refresh_outlined,
          acc.regState != RegState.inProgress,
        ),
        _buildPopupMenuItem(
          AccAction.unregister,
          'Désenregistrer',
          Icons.cancel_outlined,
          acc.regState != RegState.inProgress &&
              acc.regState != RegState.removed,
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          AccAction.delete,
          'Supprimer',
          Icons.delete_outline,
          true,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<AccAction> _buildPopupMenuItem(
    AccAction value,
    String text,
    IconData icon,
    bool enabled, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<AccAction>(
      value: value,
      enabled: enabled,
      height: 48,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? Colors.red : subtitleColor,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDestructive ? Colors.red : textColor,
            ),
          ),
        ],
      ),
    );
  }

  void onTapAccListTile(int accId) {
    context.read<AppAccountsModel>().setSelectedAccountById(accId);
  }

  void _addAccount() {
    Navigator.of(context)
        .pushNamed(AccountPage.routeName, arguments: AccountModel());
  }

  void _editAccount(int index) {
    final accModel = context.read<AppAccountsModel>();
    Navigator.of(context)
        .pushNamed(AccountPage.routeName, arguments: accModel[index]);
  }

  void _doAccountAction(AccAction action, int index) {
    final accModel = context.read<AppAccountsModel>();
    Future<void> f;
    switch (action) {
      case AccAction.delete:
        f = accModel.deleteAccount(index);
        break;
      case AccAction.unregister:
        f = accModel.unregisterAccount(index);
        break;
      case AccAction.register:
        f = accModel.registerAccount(index);
        break;
      case AccAction.edit:
        _editAccount(index);
        return;
    }
    f.catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red.shade800,
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }
}
