import 'package:flutter/material.dart';
import 'seller_login.dart';
import 'seller_signup.dart';
import 'home.dart';
import '../Utils/language_manager.dart';

class SellerAuthPage extends StatefulWidget {
  const SellerAuthPage({super.key});

  @override
  State<SellerAuthPage> createState() => _SellerAuthPageState();
}

class _SellerAuthPageState extends State<SellerAuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1877F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: Text(
          LanguageManager.translate('Satıcı Paneli'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Logo ve Başlık
              const Icon(
                Icons.store,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
            Text(
              LanguageManager.translate('Satıcı Paneli'),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            Text(
              LanguageManager.translate('Giriş yapmak için bir yöntem seçin'),
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 48),
            
            // Giriş Yap Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
          context,
          MaterialPageRoute(
                      builder: (context) => const SellerLoginPage(),
                    ),
                  );
                },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1877F2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
                child: Text(
                      LanguageManager.translate('Giriş Yap'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
            
            const SizedBox(height: 16),
            
            // Kayıt Ol Butonu
          SizedBox(
            width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
          context,
          MaterialPageRoute(
                      builder: (context) => const SellerSignupPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
                child: Text(
                      LanguageManager.translate('Kayıt Ol'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
        ),
      ),
    );
  }
} 