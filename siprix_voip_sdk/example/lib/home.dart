import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'dart:io' show Platform;

import 'package:siprix_voip_sdk/network_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/subscriptions_model.dart';

import 'calls_model_app.dart';
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
  int _selectedIndex = 1;
  static const Color primaryColor = Color(0xFF2A3990);
  static const Color subtitleColor = Color(0xFF677294);
  static const Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    //Switch tab when incoming call received
    context.read<AppCallsModel>().onNewIncomingCall = () {
      if (_selectedIndex != 1) _onTabTapped(1);
    };
  }

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
            icon: const Icon(Icons.settings),
            color: const Color(0xFF2A3990),
            onPressed: () {
              Navigator.pushNamed(context, SettingsPage.routeName);
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.person, "Comptes"),
              _buildNavItem(1, Icons.call, "Appels"),
              _buildNavItem(2, Icons.grid_view, "BLF"),
              _buildNavItem(4, Icons.description, "Logs"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const AccountsListPage();
      case 1:
        return const CallsListPage();
      case 2:
        return const SubscrListPage();
      case 4:
        return const LogsPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    final bool hasBadge =
        index == 1 && context.watch<AppCallsModel>().length > 0;

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
              color: isSelected ? primaryColor : subtitleColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
