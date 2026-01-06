import 'package:flutter/material.dart';
import 'phone_verification_page.dart';

class TestPhoneVerificationPage extends StatefulWidget {
  const TestPhoneVerificationPage({super.key});

  @override
  State<TestPhoneVerificationPage> createState() => _TestPhoneVerificationPageState();
}

class _TestPhoneVerificationPageState extends State<TestPhoneVerificationPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telefon Doğrulama Test'),
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_android,
              size: 80,
              color: Color(0xFF1877F2),
            ),
            const SizedBox(height: 24),
            const Text(
              'Telefon Doğrulama Sistemi Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Test için bir telefon numarası girin ve doğrulama sayfasını açın',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6C757D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası',
                hintText: '+90 555 123 45 67',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_phoneController.text.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PhoneVerificationPage(
                        phoneNumber: _phoneController.text,
                        userType: 'user',
                        userData: {
                          'name_surname': 'Test User',
                          'password': 'test123',
                          'email': 'test@example.com',
                          'phone_number': _phoneController.text,
                        },
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Doğrulama Sayfasını Aç',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_phoneController.text.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PhoneVerificationPage(
                        phoneNumber: _phoneController.text,
                        userType: 'seller',
                        userData: {
                          'name': 'Test Seller',
                          'email': 'seller@example.com',
                          'password': 'test123',
                          'phone': _phoneController.text,
                          'store_name': 'Test Store',
                          'cargo_company': 'Araskargo',
                        },
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28A745),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Satıcı Doğrulama Sayfasını Aç',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2196F3)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Test Notları',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• API çalışır durumda olmalı\n'
                    '• Telefon numarası formatı: +90 5XX XXX XX XX\n'
                    '• Doğrulama kodu 6 haneli olmalı\n'
                    '• Test için gerçek telefon numarası kullanın',
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
