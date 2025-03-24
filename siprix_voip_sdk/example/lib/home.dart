import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'dart:io' show Platform;

import 'package:siprix_voip_sdk/network_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';

import 'calls_model_app.dart';
import 'messages.dart';
import 'subscr_list.dart';
import 'accounts_list.dart';
import 'settings.dart';
import 'calls_list.dart';

////////////////////////////////////////////////////////////////////////////////////////
//HomePage

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = "/home";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController();
  int _selectedPageIndex = 0;

  // Couleurs principales de l'application
  static const Color primaryColor = Color(0xFF2A3990);
  static const Color accentColor = Color(0xFF4481EB);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color subtitleColor = Color(0xFF677294);

  @override
  void initState() {
    super.initState();
    //Switch tab when incoming call received
    context.read<AppCallsModel>().onNewIncomingCall = () {
      if (_selectedPageIndex != 1) _onTabTapped(1);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        centerTitle: false,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildLogoWidget(),
        ),
        title: ListTile(
          title: const Text(
            'Octovia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: const Text(
            'Solution VoIP Professionnelle',
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 16),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: primaryColor,
              onPressed: _onShowSettings,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (context.watch<NetworkModel>().networkLost)
            _networkLostIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                AccountsListPage(),
                CallsListPage(),
                SubscrListPage(),
                MessagesListPage(),
                LogsPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLogoWidget() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.headset_mic_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.people_outline_rounded, 'Comptes'),
              _buildNavItem(1, Icons.phone_rounded, 'Appels',
                  hasBadge: context.watch<AppCallsModel>().length > 0),
              _buildNavItem(2, Icons.grid_view_rounded, 'BLF'),
              _buildNavItem(3, Icons.chat_rounded, 'Messages'),
              _buildNavItem(4, Icons.description_outlined, 'Logs'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label,
      {bool hasBadge = false}) {
    final isSelected = _selectedPageIndex == index;

    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryColor : subtitleColor,
                  size: 24,
                ),
                if (hasBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardColor, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                      child: Text(
                        '${context.watch<AppCallsModel>().length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? primaryColor : subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkLostIndicator() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.signal_wifi_off, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Text(
            "Connexion internet perdue",
            style: TextStyle(
              color: Colors.red.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _onShowSettings() {
    Navigator.of(context).pushNamed(SettingsPage.routeName);
  }
}

////////////////////////////////////////////////////////////////////////////////////////
//LogsPage - represents diagnostic messages

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.text_snippet_outlined,
                  color: _HomePageState.primaryColor),
              SizedBox(width: 8),
              Text(
                "Journaux système",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _HomePageState.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Consumer<LogsModel>(
                builder: (context, logsModel, child) {
                  return SingleChildScrollView(
                    child: SelectableText(
                      logsModel.logStr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color(0xFF333333),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
