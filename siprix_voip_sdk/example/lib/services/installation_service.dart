import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class InstallationService {
  static const String _installationIdKey = 'installation_id';
  static String? _installationId;

  static Future<String> getInstallationId() async {
    if (_installationId != null) {
      return _installationId!;
    }

    final prefs = await SharedPreferences.getInstance();
    _installationId = prefs.getString(_installationIdKey);

    if (_installationId == null) {
      _installationId = const Uuid().v4();
      await prefs.setString(_installationIdKey, _installationId!);
    }

    return _installationId!;
  }
}
