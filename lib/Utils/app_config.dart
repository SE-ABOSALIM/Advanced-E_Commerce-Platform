class AppConfig {
  // Backend API Configuration
  static const String backendIP = '10.0.2.2';
  static const int backendPort = 8000;
  
  // Base URL'ler
  static String get baseUrl => 'http://$backendIP:$backendPort';
  static String get uploadImageUrl => '$baseUrl/upload-image';
  
  // Image URL'ler için helper fonksiyon
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return '$baseUrl$imagePath';
  }
  
  // Debug bilgisi
  static void printConfig() {
    print('🔧 App Config:');
    print('   Backend IP: $backendIP');
    print('   Backend Port: $backendPort');
    print('   Base URL: $baseUrl');
    print('   Upload URL: $uploadImageUrl');
  }
  
  // Test fonksiyonu
  static void testConfig() {
    printConfig();
    print('🧪 Test Results:');
    print('   Image URL Test: ${getImageUrl("/uploads/Product_Image/test.jpg")}');
    print('   Empty Image Test: ${getImageUrl("")}');
    print('   Full URL Test: ${getImageUrl("https://example.com/image.jpg")}');
  }
}
