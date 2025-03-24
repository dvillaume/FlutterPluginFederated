import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';

////////////////////////////////////////////////////////////////////////////////////////
//SettingsPage - represents platfrom specific settings

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

typedef OnChangedCallback = void Function(int?);

class _SettingsPageState extends State<SettingsPage> {
  // Couleurs principales de l'application
  static const Color primaryColor = Color(0xFF2A3990);
  static const Color accentColor = Color(0xFF4481EB);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color subtitleColor = Color(0xFF677294);

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DevicesModel>();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildBody(devices),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(DevicesModel devices) {
    if (Platform.isIOS) {
      return [
        _buildInfoCard('Les paramètres iOS ne sont pas encore disponibles')
      ];
    } else if (Platform.isAndroid) {
      return [
        _buildSwitchCard(
          'Exécuter le service téléphonique en mode premier plan',
          devices.foregroundModeEnabled,
          onSetForegroundMode,
        ),
      ];
    } else {
      return [
        _buildDeviceSection('Périphériques audio/vidéo', [
          _buildPlayoutDevicesDropDown(devices),
          const SizedBox(height: 16),
          _buildRecordingDevicesDropDown(devices),
          const SizedBox(height: 16),
          _buildVideoDevicesDropDown(devices),
        ]),
      ];
    }
  }

  Widget _buildInfoCard(String message) {
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
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSwitchCard(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
            activeTrackColor: const Color(0xFFD4D9F6),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection(String title, List<Widget> children) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  DropdownMenuItem<int> mediaDeviceItem(MediaDevice dvc) {
    return DropdownMenuItem<int>(
      value: dvc.index,
      child: Text(
        dvc.name,
        style: const TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMediaDevicesDropDown(
    String labelText,
    List<MediaDevice> dvcList,
    int selIndex,
    OnChangedCallback onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
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
            value: (selIndex < 0) ? null : selIndex,
            onChanged: onChanged,
            items: dvcList.map((element) => mediaDeviceItem(element)).toList(),
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

  Widget _buildPlayoutDevicesDropDown(DevicesModel devices) {
    return _buildMediaDevicesDropDown(
      'Périphérique de sortie audio',
      devices.playout,
      devices.playoutIndex,
      onSetPlayoutDevice,
    );
  }

  Widget _buildRecordingDevicesDropDown(DevicesModel devices) {
    return _buildMediaDevicesDropDown(
      'Périphérique d\'enregistrement',
      devices.recording,
      devices.recordingIndex,
      onSetRecordingDevice,
    );
  }

  Widget _buildVideoDevicesDropDown(DevicesModel devices) {
    return _buildMediaDevicesDropDown(
      'Périphérique vidéo',
      devices.video,
      devices.videoIndex,
      onSetVideoDevice,
    );
  }

  void onSetPlayoutDevice(int? index) {
    context
        .read<DevicesModel>()
        .setPlayoutDevice(index)
        .catchError(showSnackBar);
  }

  void onSetRecordingDevice(int? index) {
    context
        .read<DevicesModel>()
        .setRecordingDevice(index)
        .catchError(showSnackBar);
  }

  void onSetVideoDevice(int? index) {
    context.read<DevicesModel>().setVideoDevice(index).catchError(showSnackBar);
  }

  void onSetForegroundMode(bool enable) {
    context
        .read<DevicesModel>()
        .setForegroundMode(enable)
        .catchError(showSnackBar);
  }

  void showSnackBar(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red.shade400,
    ));
  }
}
