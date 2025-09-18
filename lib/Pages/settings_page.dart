import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/language_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = LanguageManager.currentLanguage;
  bool _isPrivacyEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadLanguageSettings();
    _loadPrivacySettings();
  }

  Future<void> _loadLanguageSettings() async {
    setState(() {
      _selectedLanguage = LanguageManager.currentLanguage;
    });
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPrivacyEnabled = prefs.getBool('privacy_enabled') ?? false;
    });
  }

  Future<void> _saveLanguageSettings(String language) async {
    await LanguageManager.setLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _savePrivacySettings(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_enabled', enabled);
    setState(() {
      _isPrivacyEnabled = enabled;
    });
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.language, color: Color(0xFF1877F2), size: 32),
                  const SizedBox(width: 12),
                  Text(
                    LanguageManager.translate('Dil Seçimi'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1877F2)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...LanguageManager.availableLanguages.map((language) {
                final isSelected = _selectedLanguage == language;
                return GestureDetector(
                  onTap: () {
                    _saveLanguageSettings(language);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1877F2).withOpacity(0.08) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1877F2).withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? const Color(0xFF1877F2) : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          language,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? const Color(0xFF1877F2) : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1877F2),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFF1877F2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    LanguageManager.translate('İptal'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageManager.translate('Ayarlar'),
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1877F2),
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LanguageManager.translate('Genel Ayarlar'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1877F2),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Color(0xFF1877F2),
                ),
                title: Text(LanguageManager.translate('Dil')),
                subtitle: Text(_selectedLanguage),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLanguageDialog,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              LanguageManager.translate('Gizlilik'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1877F2),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.security,
                  color: Color(0xFF1877F2),
                ),
                            title: Text(LanguageManager.translate('Kullanıcı Adı Gizleme')),
            subtitle: Text(LanguageManager.translate('Yorumlarda kullanıcı adınızı gizler')),
                trailing: Switch(
                  value: _isPrivacyEnabled,
                  onChanged: _savePrivacySettings,
                  activeColor: const Color(0xFF1877F2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              LanguageManager.translate('Uygulama Hakkında'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1877F2),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.info,
                  color: Color(0xFF1877F2),
                ),
                title: Text(LanguageManager.translate('Versiyon')),
                subtitle: const Text('1.0.0'),
                onTap: () {
                  // Versiyon bilgisi göster
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                  color: Color(0xFF1877F2),
                ),
                title: Text(LanguageManager.translate('Gizlilik Politikası')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Gizlilik politikası sayfasına yönlendir
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.description,
                  color: Color(0xFF1877F2),
                ),
                title: Text(LanguageManager.translate('Kullanım Şartları')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Kullanım şartları sayfasına yönlendir
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
