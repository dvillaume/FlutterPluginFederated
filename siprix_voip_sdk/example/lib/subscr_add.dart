import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/subscriptions_model.dart';
import 'accouns_model_app.dart';
import 'subscr_model_app.dart';

////////////////////////////////////////////////////////////////////////////////////////
//SubscrAddPage - allows enter extension and account for creating BLF subscriptions

class SubscrAddPage extends StatefulWidget {
  const SubscrAddPage({super.key});
  static const routeName = '/subscr_add';

  @override
  State<SubscrAddPage> createState() => _SubscrAddPageState();
}

class _SubscrAddPageState extends State<SubscrAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _subscr = AppBlfSubscrModel("", 0);

  // Couleurs principales de l'application
  static const Color primaryColor = Color(0xFF2A3990);
  static const Color accentColor = Color(0xFF4481EB);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color subtitleColor = Color(0xFF677294);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        title: const Text(
          'Ajouter une souscription BLF',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCard([
                  _buildAccountDropdown(),
                  const SizedBox(height: 16),
                  _buildLabelField(),
                  const SizedBox(height: 16),
                  _buildExtensionField(),
                ]),
                const SizedBox(height: 24),
                _buildAddButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildAccountDropdown() {
    final accounts = context.watch<AppAccountsModel>();
    if (accounts.length == 0) {
      return const Text('Aucun compte disponible');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionner un compte',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<int>(
            value: _subscr.fromAccId,
            items: [
              for (var i = 0; i < accounts.length; i++)
                accMenuItem(accounts[i], i)
            ],
            onChanged: (int? value) {
              setState(() {
                if (value != null) _subscr.fromAccId = value;
              });
            },
            validator: (value) {
              return (value == null)
                  ? 'Veuillez sélectionner un compte.'
                  : null;
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              border: InputBorder.none,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<int> accMenuItem(AccountModel acc, int index) {
    return DropdownMenuItem<int>(
      value: acc.myAccId,
      child: Text(
        acc.uri,
        style: const TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLabelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Libellé du contact',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Entrez un libellé',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: textColor,
          ),
          validator: (value) {
            return (value == null || value.isEmpty)
                ? 'Veuillez entrer un libellé.'
                : null;
          },
          onChanged: (String? value) {
            setState(() {
              if (value != null && value.isNotEmpty) _subscr.label = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExtensionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extension à surveiller',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Entrez une extension',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          validator: (value) {
            return (value == null || value.isEmpty)
                ? 'Veuillez entrer une extension.'
                : null;
          },
          onChanged: (String? value) {
            setState(() {
              if (value != null && value.isNotEmpty) _subscr.toExt = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Container(
      height: 56,
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
          onTap: _addSubscription,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Text(
              'Ajouter la souscription',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addSubscription() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final subscriptions = context.read<SubscriptionsModel>();
    subscriptions.addSubscription(_subscr);
    Navigator.pop(context);
  }
}
