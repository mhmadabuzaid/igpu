import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/admin_provider.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();
  final _typeController = TextEditingController(); // e.g., GPU, CPU
  final _descController = TextEditingController();

  File? _selectedImage;

  // Function to Pick Image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Submit Form
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    // Call Provider
    await ref
        .read(adminProvider.notifier)
        .addItem(
          name: _nameController.text,
          price: double.parse(_priceController.text),
          brand: _brandController.text,
          type: _typeController.text,
          description: _descController.text,
          imageFile: _selectedImage!,
        );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item Published!')));
      Navigator.pop(context); // Go back to Home
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(adminProvider);
    final neonColor = Colors.cyanAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(
          'ADMIN TERMINAL',
          style: TextStyle(color: neonColor, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: neonColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. IMAGE PICKER
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: neonColor.withOpacity(0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: neonColor),
                            const SizedBox(height: 10),
                            Text(
                              'TAP TO UPLOAD IMAGE',
                              style: TextStyle(color: neonColor),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. FORM FIELDS
              _buildField(_nameController, 'Component Name', Icons.memory),
              _buildField(
                _brandController,
                'Brand (e.g. Nvidia)',
                Icons.branding_watermark,
              ),
              _buildField(
                _typeController,
                'Type (GPU, CPU...)',
                Icons.category,
              ),
              _buildField(
                _priceController,
                'Price (JOD)',
                Icons.attach_money,
                isNumber: true,
              ),
              _buildField(
                _descController,
                'Description',
                Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              // 3. SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: neonColor))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonColor,
                        ),
                        onPressed: _submit,
                        child: const Text(
                          'PUBLISH TO DATABASE',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (val) => val!.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}
