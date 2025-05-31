import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/phone.dart';
import '../api/api_service.dart';

class AddEditPhoneScreen extends StatefulWidget {
  final Phone? phone;

  const AddEditPhoneScreen({super.key, this.phone});

  @override
  State<AddEditPhoneScreen> createState() => _AddEditPhoneScreenState();
}

class _AddEditPhoneScreenState extends State<AddEditPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _specificationController;
  late TextEditingController _priceController;

  bool _isLoading = false;
  bool get _isEditMode => widget.phone != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.phone?.name ?? '');
    _brandController = TextEditingController(text: widget.phone?.brand ?? '');
    _specificationController = TextEditingController(
      text: widget.phone?.specification ?? '',
    );
    _priceController = TextEditingController(
      text: widget.phone?.price.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _specificationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final phoneDataFromForm = Phone(
        id: widget.phone?.id ?? 0,
        name: _nameController.text,
        brand: _brandController.text,
        price: int.tryParse(_priceController.text) ?? 0,
        specification: _specificationController.text,
        imgUrl: widget.phone?.imgUrl ?? '',
      );

      try {
        if (!_isEditMode) {
          await _apiService.createPhone(phoneDataFromForm);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Ponsel berhasil ditambahkan! Daftar akan diperbarui.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await _apiService.updatePhone(
            widget.phone!.id.toString(),
            phoneDataFromForm,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ponsel berhasil diperbarui!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan ponsel: $e'),
              backgroundColor: Colors.red,
            ),
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
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText + (isOptional ? " (Opsional)" : ""),
          hintText: "Masukkan $labelText...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          filled: true,
          fillColor: Colors.white.withAlpha(((0.95 * 255).round())),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        validator:
            isOptional
                ? null
                : (validator ??
                    (value) {
                      if (value == null || value.isEmpty) {
                        return '$labelText tidak boleh kosong';
                      }
                      return null;
                    }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Ponsel' : 'Tambah Ponsel Baru'),
        elevation: 1,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  _buildTextFormField(
                    controller: _nameController,
                    labelText: 'Nama Ponsel',
                    icon: Icons.phone_android_rounded,
                  ),
                  _buildTextFormField(
                    controller: _brandController,
                    labelText: 'Merek',
                    icon: Icons.label_important_outline_rounded,
                  ),
                  _buildTextFormField(
                    controller: _priceController,
                    labelText: 'Harga',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      final price = int.tryParse(value);
                      if (price == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (price <= 0) {
                        return 'Harga harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  _buildTextFormField(
                    controller: _specificationController,
                    labelText: 'Spesifikasi',
                    icon: Icons.settings_input_component_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(
                      _isEditMode
                          ? Icons.save_as_outlined
                          : Icons.add_circle_outline_rounded,
                    ),
                    label: Text(
                      _isEditMode ? 'Simpan Perubahan' : 'Tambah Ponsel',
                    ),
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(((0.5 * 255).round())),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
