import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
  TextEditingController(text: "namo@gmail.com");
  final TextEditingController usernameController =
  TextEditingController(text: "namotosan");
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "กรุณากรอก $fieldName";
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    if (value == null || value.isEmpty) {
      return "กรุณากรอกเบอร์โทรศัพท์";
    } else if (!phoneRegex.hasMatch(value)) {
      return "รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง (xxx-xxx-xxxx)";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar:   Container(
        color: Colors.grey[100],
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width-23,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // ถ้าผ่านการตรวจสอบ ให้ดำเนินการบันทึก
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "บันทึก",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(

            children: [
              const SizedBox(height: 0),
              // Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Center(
                    child: Text(
                      "แก้ไขข้อมูลบัญชี",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Form Fields
              _buildTextField("email", emailController, isReadOnly: true),
              _buildTextField("username", usernameController, isReadOnly: true),
              _buildTextField("ชื่อจริง", firstNameController,
                  validator: (value) => _validateRequired(value, "ชื่อจริง")),
              _buildTextField("นามสกุล", lastNameController,
                  validator: (value) => _validateRequired(value, "นามสกุล")),
              _buildTextField(
                "เบอร์โทรศัพท์",
                phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, _PhoneNumberFormatter()],
                validator: _validatePhoneNumber,
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool isReadOnly = false,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// Custom InputFormatter สำหรับเบอร์โทร (xxx-xxx-xxxx)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), ''); // ลบตัวอักษรที่ไม่ใช่ตัวเลข
    String formatted = '';

    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '-';
      }
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


