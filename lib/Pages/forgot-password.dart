import 'package:flutter/material.dart';
import 'login.dart';
import '../Models/User.dart';
import '../API/api_service.dart';
import '../Widgets/custom_dialog.dart';
import '../Utils/language_manager.dart';

// Tema ve stil sabitleri
class ForgotPasswordTheme {
  static const Color primaryColor = Color(0xFF1877F2);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color greyColor = Color(0xFF6C757D);
  static const Color lightGreyColor = Color(0xFFE9ECEF);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color successColor = Color(0xFF28A745);
  
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins',
    color: blackColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: greyColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    color: whiteColor,
  );

  static const TextStyle linkTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: primaryColor,
  );
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Focus nodes for validation
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  // Form validation states
  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isPhoneValid = true;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Add focus listeners for validation
    _nameFocusNode.addListener(_onNameFocusChange);
    _emailFocusNode.addListener(_onEmailFocusChange);
    _phoneFocusNode.addListener(_onPhoneFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);

  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}');
    return passwordRegex.hasMatch(password);
  }

  bool _isValidPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length == 11;
  }

  void _onNameFocusChange() {
    if (!_nameFocusNode.hasFocus && _nameController.text.trim().isNotEmpty) {
      setState(() {
        _isNameValid = _nameController.text.trim().length >= 2;
      });
    } else if (_nameFocusNode.hasFocus) {
      setState(() {
        _isNameValid = true;
      });
    }
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus && _emailController.text.trim().isNotEmpty) {
      setState(() {
        _isEmailValid = _isValidEmail(_emailController.text.trim());
      });
    } else if (_emailFocusNode.hasFocus) {
      setState(() {
        _isEmailValid = true;
      });
    }
  }

  void _onPhoneFocusChange() {
    if (!_phoneFocusNode.hasFocus && _phoneController.text.trim().isNotEmpty) {
      setState(() {
        _isPhoneValid = _isValidPhone(_phoneController.text.trim());
      });
    } else if (_phoneFocusNode.hasFocus) {
      setState(() {
        _isPhoneValid = true;
      });
    }
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocusNode.hasFocus && _newPasswordController.text.isNotEmpty) {
      setState(() {
        _isPasswordValid = _isValidPassword(_newPasswordController.text);
      });
    } else if (_passwordFocusNode.hasFocus) {
      setState(() {
        _isPasswordValid = true;
      });
    }
  }

  bool _isFormValid() {
    return _isNameValid && _isEmailValid && _isPasswordValid && _isPhoneValid &&
           _nameController.text.trim().isNotEmpty &&
           _emailController.text.trim().isNotEmpty &&
           _newPasswordController.text.isNotEmpty &&
           _phoneController.text.trim().isNotEmpty;
  }

  void _handleResetPassword() async {
    if (!_isFormValid()) {
      CustomDialog.showError(
        context: context,
        title: LanguageManager.translate('Form Hatası'),
        message: LanguageManager.translate('Lütfen tüm alanları doğru şekilde doldurunuz!'),
        buttonText: LanguageManager.translate('Tamam'),
      );
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      CustomDialog.showError(
        context: context,
        title: LanguageManager.translate('Hata'),
        message: LanguageManager.translate('Geçerli bir e-posta adresi giriniz!'),
        buttonText: LanguageManager.translate('Tamam'),
      );
      return;
    }

    if (!_isValidPassword(_newPasswordController.text)) {
      CustomDialog.showError(
        context: context,
        title: LanguageManager.translate('Hata'),
        message: LanguageManager.translate('Şifre en az 8 karakter, bir büyük harf, bir küçük harf ve bir rakam içermelidir!'),
        buttonText: LanguageManager.translate('Tamam'),
      );
      return;
    }

    if (!_isValidPhone(_phoneController.text.trim())) {
      CustomDialog.showError(
        context: context,
        title: LanguageManager.translate('Hata'),
        message: LanguageManager.translate('Telefon numarası 11 haneli olmalıdır!'),
        buttonText: LanguageManager.translate('Tamam'),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await ApiService.fetchUsers();
      final userJson = users.firstWhere(
        (u) => u['email'] == _emailController.text.trim(),
        orElse: () => null,
      );
      
      if (userJson != null &&
          userJson['name_surname'] == _nameController.text.trim() &&
          userJson['phone_number'] == _phoneController.text.trim()) {
        // Bilgiler doğru, şifreyi güncelle
        final updatedUser = User(
          id: userJson['id'],
          nameSurname: userJson['name_surname'],
          password: _newPasswordController.text,
          email: userJson['email'],
          phoneNumber: userJson['phone_number'],
        );
        await ApiService.updateUser(updatedUser.id!, {
          'name_surname': updatedUser.nameSurname,
          'password': updatedUser.password,
          'email': updatedUser.email,
          'phone_number': updatedUser.phoneNumber,
        });
        
        setState(() {
          _isLoading = false;
        });
        
        CustomDialog.showSuccess(
          context: context,
          title: LanguageManager.translate('Başarılı!'),
          message: LanguageManager.translate('Şifreniz başarıyla değiştirildi. Yeni şifrenizle giriş yapabilirsiniz.'),
          buttonText: LanguageManager.translate('Giriş Yap'),
          onButtonPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: LanguageManager.translate('Bilgiler eşleşmiyor! Lütfen girdiğiniz bilgileri kontrol edin.'),
          buttonText: LanguageManager.translate('Tamam'),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CustomDialog.showError(
        context: context,
        title: LanguageManager.translate('Hata'),
        message: LanguageManager.translate('Şifre değiştirme sırasında bir hata oluştu. Lütfen tekrar deneyin.'),
        buttonText: LanguageManager.translate('Tamam'),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForgotPasswordTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
        ),
        title: Text(
          LanguageManager.translate("Şifre Sıfırlama"),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor: ForgotPasswordTheme.primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ForgotPasswordTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 40,
                    color: ForgotPasswordTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LanguageManager.translate("Şifre Sıfırlama"),
                  style: ForgotPasswordTheme.titleStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageManager.translate("Bilgilerinizi girerek şifrenizi sıfırlayın"),
                  style: ForgotPasswordTheme.subtitleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Form
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ForgotPasswordTheme.whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                                                 Column(
                           children: [
                                                              _buildTextField(
                                  controller: _nameController,
                                  hintText: LanguageManager.translate("Ad Soyad"),
                                  icon: Icons.person_outline,
                                  focusNode: _nameFocusNode,
                                  isValid: _isNameValid,
                                  errorText: LanguageManager.translate("Ad soyad en az 2 karakter olmalıdır"),
                                ),
                              const SizedBox(height: 12),
                                                              _buildTextField(
                                  controller: _emailController,
                                  hintText: LanguageManager.translate("E-posta"),
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: _emailFocusNode,
                                  isValid: _isEmailValid,
                                  errorText: LanguageManager.translate("Geçerli bir e-posta adresi giriniz"),
                                ),
                              const SizedBox(height: 12),
                                                              _buildTextField(
                                  controller: _phoneController,
                                  hintText: LanguageManager.translate("Telefon Numarası"),
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  focusNode: _phoneFocusNode,
                                  isValid: _isPhoneValid,
                                  errorText: LanguageManager.translate("Telefon numarası 11 haneli olmalıdır"),
                                  maxLength: 11,
                                ),
                              const SizedBox(height: 12),
                                                              _buildTextField(
                                  controller: _newPasswordController,
                                  hintText: LanguageManager.translate("Yeni Şifre"),
                                  icon: Icons.lock_outlined,
                                  isPassword: true,
                                  focusNode: _passwordFocusNode,
                                  isValid: _isPasswordValid,
                                  errorText: LanguageManager.translate("Şifre en az 8 karakter, bir büyük harf, bir küçük harf ve bir rakam içermelidir"),
                                ),
                              const SizedBox(height: 20),
                              
                              // Şifre sıfırlama butonu - yukarı taşındı
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading || !_isFormValid() ? null : _handleResetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ForgotPasswordTheme.primaryColor,
                                    foregroundColor: ForgotPasswordTheme.whiteColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: ForgotPasswordTheme.whiteColor,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          LanguageManager.translate("Şifreyi Sıfırla"),
                                          style: ForgotPasswordTheme.buttonTextStyle,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                        
                        const SizedBox(height: 16),
                        
                        // Giriş sayfasına dön linki
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LanguageManager.translate("Geri dönmek istiyor musunuz? "),
                              style: ForgotPasswordTheme.subtitleStyle,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(-1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              child: Text(
                                LanguageManager.translate("Giriş Yap"),
                                style: ForgotPasswordTheme.linkTextStyle.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    bool isValid = true,
    String? errorText,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: focusNode?.hasFocus == true ? ForgotPasswordTheme.whiteColor : ForgotPasswordTheme.lightGreyColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isValid ? Colors.transparent : ForgotPasswordTheme.errorColor,
              width: 1,
            ),
          ),
                     child: TextField(
             controller: controller,
             focusNode: focusNode,
             obscureText: isPassword ? _obscurePassword : false,
             keyboardType: keyboardType,
             maxLength: maxLength,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: ForgotPasswordTheme.greyColor,
                fontFamily: 'Poppins',
              ),
              filled: true,
              fillColor: Colors.transparent,
              prefixIcon: Icon(icon, color: ForgotPasswordTheme.primaryColor),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: ForgotPasswordTheme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: isValid ? ForgotPasswordTheme.primaryColor : ForgotPasswordTheme.errorColor, 
                  width: 2
                ),
              ),
                             contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
               counterText: "", // Hide character counter
            ),
          ),
        ),
        if (!isValid && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText,
              style: TextStyle(
                color: ForgotPasswordTheme.errorColor,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }
}
