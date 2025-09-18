import 'package:flutter/material.dart';
import '../API/api_service.dart';
import '../Widgets/custom_dialog.dart';
import '../Utils/language_manager.dart';

class AddAddressPage extends StatefulWidget {
  final bool fromCheckout;
  
  const AddAddressPage({Key? key, this.fromCheckout = false}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _neighbourhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingNumberController = TextEditingController();
  final _apartmentNumberController = TextEditingController();
  final _addressNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cityController.dispose();
    _districtController.dispose();
    _neighbourhoodController.dispose();
    _streetController.dispose();
    _buildingNumberController.dispose();
    _apartmentNumberController.dispose();
    _addressNameController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.addAddress({
        'city': _cityController.text,
        'district': _districtController.text,
        'neighbourhood': _neighbourhoodController.text,
        'street_name': _streetController.text,
        'building_number': _buildingNumberController.text,
        'apartment_number': _apartmentNumberController.text,
        'address_name': _addressNameController.text,
      });

      if (mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: LanguageManager.translate('Başarılı!'),
          message: LanguageManager.translate('Adres başarıyla eklendi'),
          buttonText: LanguageManager.translate('Tamam'),
          onButtonPressed: () {
            if (widget.fromCheckout) {
              // Checkout sayfasından geldiyse true döndür
              Navigator.pop(context, true);
            } else {
              // Normal sayfadan geldiyse sadece kapat
              Navigator.pop(context);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(
          context: context,
          title: LanguageManager.translate('Hata'),
          message: LanguageManager.translate('Adres eklenirken hata oluştu. Lütfen bilgilerinizi kontrol edip tekrar deneyin.'),
          buttonText: LanguageManager.translate('Tamam'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager.translate('Adres Ekle')),
        backgroundColor: const Color(0xFF6B73FF),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: LanguageManager.translate('Şehir'),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LanguageManager.translate('Şehir zorunludur');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _districtController,
                              decoration: InputDecoration(
                                labelText: LanguageManager.translate('İlçe'),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LanguageManager.translate('İlçe zorunludur');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _neighbourhoodController,
                              decoration: InputDecoration(
                                labelText: LanguageManager.translate('Mahalle'),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LanguageManager.translate('Mahalle zorunludur');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _streetController,
                              decoration: InputDecoration(
                                labelText: LanguageManager.translate('Sokak'),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LanguageManager.translate('Sokak zorunludur');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _buildingNumberController,
                                    decoration: InputDecoration(
                                      labelText: LanguageManager.translate('Bina No'),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return LanguageManager.translate('Bina no zorunludur');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _apartmentNumberController,
                                    decoration: InputDecoration(
                                      labelText: LanguageManager.translate('Daire No'),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return LanguageManager.translate('Daire no zorunludur');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressNameController,
                              decoration: InputDecoration(
                                labelText: LanguageManager.translate('Adres Adı (Ev, İş vb.)'),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return LanguageManager.translate('Adres adı zorunludur');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        LanguageManager.translate('Adresi Kaydet'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 