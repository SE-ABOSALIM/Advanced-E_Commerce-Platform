import 'package:shared_preferences/shared_preferences.dart';

class PrivacyManager {
  static const String _privacyKey = 'privacy_enabled';

  static Future<bool> isPrivacyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyKey) ?? false;
  }

  static Future<void> setPrivacyEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyKey, enabled);
  }

  static String maskUserName(String userName) {
    if (userName.isEmpty) return 'Anonim';
    
    final words = userName.split(' ');
    if (words.length >= 2) {
      // İlk adın ilk 2 harfi + *** + soyadın ilk 2 harfi + ***
      final firstName = words[0];
      final lastName = words[words.length - 1];
      
      String maskedFirstName = firstName.length >= 2 ? '${firstName.substring(0, 2)}***' : '${firstName}***';
      String maskedLastName = lastName.length >= 2 ? '${lastName.substring(0, 2)}***' : '${lastName}***';
      
      return '$maskedFirstName $maskedLastName';
    } else if (words.length == 1) {
      // Tek kelime ise ilk 2 harfi + ***
      final word = words[0];
      return word.length >= 2 ? '${word.substring(0, 2)}***' : '${word}***';
    }
    return 'Anonim';
  }
}
