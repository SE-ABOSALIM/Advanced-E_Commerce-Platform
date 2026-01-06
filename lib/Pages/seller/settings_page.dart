import 'package:flutter/material.dart';
import 'edit_profile.dart';
import '../../Utils/language_manager.dart';
import '../../Models/seller.dart';

class SellerSettingsPage extends StatefulWidget {
  final Seller? seller;
  
  const SellerSettingsPage({Key? key, this.seller}) : super(key: key);

  @override
  State<SellerSettingsPage> createState() => _SellerSettingsPageState();
}

class _SellerSettingsPageState extends State<SellerSettingsPage> {
  String _selectedLanguage = LanguageManager.currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguageSettings();
  }

  Future<void> _loadLanguageSettings() async {
    setState(() {
      _selectedLanguage = LanguageManager.currentLanguage;
    });
  }

  Future<void> _saveLanguageSettings(String language) async {
    await LanguageManager.setLanguage(language);
    setState(() {
      _selectedLanguage = language;
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageManager.translate('Uygulama Hakkında')),
        content: Text('v1.0.0'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageManager.translate('Tamam')),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageManager.translate('Gizlilik Politikası')),
        content: Text(LanguageManager.translate('Gizlilik politikası içeriği burada yer alacak.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageManager.translate('Tamam')),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageManager.translate('Kullanım Şartları')),
        content: Text(LanguageManager.translate('Kullanım şartları içeriği burada yer alacak.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageManager.translate('Tamam')),
          ),
        ],
      ),
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
              LanguageManager.translate('Profil'),
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
                  Icons.edit,
                  color: Color(0xFF1877F2),
                ),
                title: Text(LanguageManager.translate('Profili Düzenle')),
                subtitle: Text(LanguageManager.translate('Kişisel bilgileri güncelle')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  if (widget.seller != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerEditProfilePage(seller: widget.seller!),
                      ),
                    );
                    // Profil düzenleme sayfasından döndükten sonra sayfayı yenile
                    if (result != null) {
                      Navigator.pop(context, result); // Ana sayfaya güncellenmiş seller'ı gönder
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
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
              LanguageManager.translate('Hakkında'),
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
                title: Text(LanguageManager.translate('Uygulama Hakkında')),
                subtitle: Text(LanguageManager.translate('Versiyon') + ' 1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showAboutDialog,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              LanguageManager.translate('Yasal'),
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
                  Icons.privacy_tip,
                  color: Color(0xFF1877F2),
                ),
                title: Text(LanguageManager.translate('Gizlilik Politikası')),
                subtitle: Text(LanguageManager.translate('Gizlilik şartları')),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showPrivacyDialog,
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
                subtitle: Text(LanguageManager.translate('Kullanım koşulları')),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showTermsDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
