import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../modules/user_module.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color bgColor = Color(0xFF0A0E14);
  static const Color surfaceColor = Color(0xFF1C222B);
  static const Color accentNeon = Color(0xFFCCFF00);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  String? selectedGender;
  String? selectedGoal;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = UserModel();
    _nameController.text = user.name ?? "";
    _ageController.text = user.age?.toString() ?? "";
    _weightController.text = user.weight?.toString() ?? "";
    _heightController.text = user.height?.toString() ?? "";
    selectedGender = user.gender;
    selectedGoal = user.goal;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      
      // Show loading indicator or handle it in save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploading image...")),
      );
      
      final url = await DatabaseService().uploadProfilePicture(_image!);
      if (url != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image uploaded successfully!")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image.")),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = UserModel();
    user.name = _nameController.text;
    user.age = int.tryParse(_ageController.text);
    user.weight = double.tryParse(_weightController.text);
    user.height = double.tryParse(_heightController.text);
    user.gender = selectedGender;
    user.goal = selectedGoal;

    try {
      await DatabaseService().saveUserProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Edit Profile", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: surfaceColor,
                      backgroundImage: _image != null 
                          ? FileImage(_image!) 
                          : (UserModel().profileImageUrl != null && UserModel().profileImageUrl!.startsWith('http')
                              ? NetworkImage(UserModel().profileImageUrl!) as ImageProvider
                              : null),
                      child: _image == null && (UserModel().profileImageUrl == null || !UserModel().profileImageUrl!.startsWith('http'))
                          ? const Icon(Icons.person, size: 60, color: accentNeon)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: accentNeon,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            _buildTextField("Name", _nameController, TextInputType.name),
            const SizedBox(height: 20),
            _buildTextField("Age", _ageController, TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField("Weight (lbs)", _weightController, TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField("Height (cm)", _heightController, TextInputType.number),
            const SizedBox(height: 20),
            
            _buildDropdown("Gender", ["Male", "Female", "Other"], selectedGender, (val) {
              setState(() => selectedGender = val);
            }),
            const SizedBox(height: 20),
            
            _buildDropdown("Primary Goal", ["Lose Weight", "Build Muscle", "Keep Fit", "Get Stronger"], selectedGoal, (val) {
              setState(() => selectedGoal = val);
            }),
            
            const SizedBox(height: 50),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentNeon,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  "SAVE CHANGES",
                  style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: surfaceColor,
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
