import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../compenent/custom_style.dart';
import '../controllers/add_new_nominee.dart';

class AddNomineeScreen extends StatefulWidget {
  final Map<String, dynamic>? nominee;
  const AddNomineeScreen({super.key, this.nominee});

  @override
  State<AddNomineeScreen> createState() => _AddNomineeScreenState();
}

class _AddNomineeScreenState extends State<AddNomineeScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _aadhaarController;
  late final TextEditingController _ageController;
  late final TextEditingController _fathermother;

  File? _nomineePhotoFile;        // local image file
  String? _uploadedPhotoUrl;      // from backend (if editing)

  late bool _isEditing;
  int _selectedNavIndex = 3;

  late String _selectedRelation = "";

  final List<String> _relationItems = [
    'Father',
    'Wife',
    'Mother',
    'Spouse',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final nominee = widget.nominee;
    _isEditing = nominee != null;

    _nameController = TextEditingController(text: nominee?['name'] ?? '');
    _mobileController = TextEditingController(text: nominee?['contact_number'] ?? '');
    _aadhaarController = TextEditingController(text: nominee?['aadhar_number'] ?? '');
    _ageController = TextEditingController(text: nominee?['age']?.toString() ?? "");
    _fathermother=TextEditingController(text: "");
    _uploadedPhotoUrl = nominee?['profile_picture'];

    String relation = nominee?['relationship'] ?? "";
    if (relation == "Wife") relation = "Spouse";
    if (_relationItems.contains(relation)) _selectedRelation = relation;
  }

  Future<void> _pickNomineePhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _nomineePhotoFile = File(result.files.single.path!);
      _uploadedPhotoUrl = null; // override old
    });
  }

  void _saveNominee() async {
    final provider = Provider.of<NomineeProfileProvider>(context, listen: false);

    Map<String, String> fields = {
      "nominee_name": _nameController.text,
      "nominee_relationship": _selectedRelation,
      "nominee_mobile_number": _mobileController.text.toString(),
      "nominee_aadhar_number": _aadhaarController.text.toString(),
      "nominee_age": _ageController.text.toString(),
      // "nominee_father_husband_name":_fathermother.text,
    };

    Map<String, File> files = {};

    // only upload new photo
    if (_nomineePhotoFile != null) {
      files["nominee_profile_picture"] = _nomineePhotoFile!;
    }

    bool success = await provider.updateNominee(fields, files, _isEditing);
    print("nominnee update details ----------${success} === $files");
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Nominee updated successfully' : 'Nominee added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update nominee'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                ),
                child: ClipOval(
                  child: _nomineePhotoFile != null
                      ? Image.file(_nomineePhotoFile!, fit: BoxFit.cover)
                      : (_uploadedPhotoUrl != null
                      ? Image.network(_uploadedPhotoUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.person, size: 60, color: Color(0xFFFFD700))),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickNomineePhoto,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Icon(Icons.camera_alt, size: 22, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Upload nominee's photo", style: AppTextStyles.subHeading),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Information', style: AppTextStyles.heading),
        const SizedBox(height: 20),

        _buildTextField(
          label: "FULL NAME",
          controller: _nameController,
          hint: "Enter full name",
          icon: Icons.person,
        ),
        const SizedBox(height: 16),

        _buildRelationshipDropdown(),
        const SizedBox(height: 16),

        _buildTextField(
          label: "MOBILE NUMBER",
          controller: _mobileController,
          hint: "Enter mobile number",
          icon: Icons.phone_android,
          maxLength: 10,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: "NOMINEE AGE",
          controller: _ageController,
          hint: "Enter age",
          icon: Icons.person_add,
          maxLength: 3,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: "AADHAAR NUMBER",
          controller: _aadhaarController,
          hint: "Enter Aadhaar number",
          icon: Icons.credit_card,
          maxLength: 12,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // _buildTextField(
        //   label: "Relation Type",
        //   controller: _fathermother,
        //   hint: "Enter Relation Type",
        //   icon: Icons.person_pin_outlined,

        // ),
      ],
    );
  }

  Widget _buildRelationshipDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RELATIONSHIP', style: AppTextStyles.labelText),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.black87,
              isExpanded: true,
              value: _relationItems.contains(_selectedRelation) ? _selectedRelation : null,
              hint: Text("Select Relationship", style: AppTextStyles.labelText),
              items: _relationItems.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value, style: AppTextStyles.inputText.copyWith(color: Colors.white)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedRelation = newValue ?? "");
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelText),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: keyboardType,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
              hintText: hint,
              hintStyle: AppTextStyles.labelText,
              counterText: "",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildActionButtons() {

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _saveNominee,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          _isEditing ? "Save Changes" : "Add Nominee",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEditing ? 'Edit Nominee' : 'Add New Nominee', style: AppTextStyles.heading),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildPhotoSection(),
              const SizedBox(height: 30),
              _buildPersonalInformation(),
              const SizedBox(height: 40),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

extension on bool {
  void operator [](String other) {}
}
