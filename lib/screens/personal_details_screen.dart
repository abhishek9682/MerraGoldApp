// personal_and_kyc_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/profile_details.dart';
import '../controllers/update_profile.dart';
import '../controllers/submit_kyc.dart';
import '../compenent/custom_style.dart';

// A combined screen that has two tabs: Personal Details and KYC
class PersonalAndKycScreen extends StatefulWidget {
  const PersonalAndKycScreen({super.key});

  @override
  State<PersonalAndKycScreen> createState() => _PersonalAndKycScreenState();
}

class _PersonalAndKycScreenState extends State<PersonalAndKycScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Personal detail controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  String _selectedGender = 'Male';
  File? _selectedProfileImage;

  // KYC dynamic maps
  // kycField maps fieldName -> picked File
  final Map<String, File> _kycFieldFiles = {};
  // kycIdFields maps form index keys required by backend (like kyc_ids[0]) -> id string
  final Map<String, String> _kycIdFields = {};
  int _kycIndexCounter = 0;

  // UI state
  bool _isLoading = true;
  bool _isUpdatingProfile = false;
  bool _isSubmittingKyc = false;

  // Validation state
  final Map<String, String?> _fieldErrors = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final profileProvider = Provider.of<ProfileDetailsProvider>(context, listen: false);
      await profileProvider.fetchProfile();

      final p = profileProvider.profileData?.data?.profile;
      if (p != null) {
        setState(() {
          _firstNameController.text = p.firstname ?? '';
          _lastNameController.text = p.lastname ?? '';
          _emailController.text = p.email ?? '';
          _phoneController.text = p.phone ?? '';
          // if your api stores DOB differently, adapt formatting:
          _dobController.text = p.dateOfBirth ?? '';
          _addressController.text = p.address ?? '';
          _cityController.text = p.city ?? '';
          _stateController.text = p.state ?? '';
          _pincodeController.text = p.zipCode ?? '';
          _panController.text = p.panNumber ?? '';
          _aadharController.text = p.aadharNumber ?? '';
          _selectedGender = (p.gender ?? 'male').toString().toLowerCase() == 'female' ? 'Female' : (p.gender ?? 'male').toString().toLowerCase() == 'other' ? 'Other' : 'Male';
        });
      }
    } catch (e) {
      _showErrorSnackbar("Failed to load profile data");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // -------------------------
  // VALIDATORS
  // -------------------------
  String? _validateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'This field is required';
    if (v.length < 2) return 'Must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!re.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? _validatePhone(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Phone is required';
    if (v.length != 10) return 'Enter 10 digit phone';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) return 'Enter valid digits';
    return null;
  }

  String? _validatePincode(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Pincode is required';
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(v)) return 'Enter valid 6-digit pincode';
    return null;
  }

  String? _validatePAN(String value) {
    final v = value.trim().toUpperCase();

    if (v.isEmpty) return 'PAN is required';

    // PAN is only 10 characters
    if (v.length != 10) return 'Enter 10 character PAN';

    // Correct PAN pattern: 5 letters, 4 digits, 1 letter
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(v)) {
      return 'Enter valid PAN';
    }

    return null;
  }


  String? _validateAadhar(String value) {
    final v = value.replaceAll(' ', '').trim();
    if (v.isEmpty) return 'Aadhar is required';
    if (!RegExp(r'^[0-9]{12}$').hasMatch(v)) return 'Enter 12 digit Aadhar';
    return null;
  }

  bool _validateAllFields() {
    _fieldErrors.clear();
    final fns = {
      'firstName': _validateName(_firstNameController.text),
      'lastName': _validateName(_lastNameController.text),
      'email': _validateEmail(_emailController.text),
      'phone': _validatePhone(_phoneController.text),
      'address': _addressController.text.trim().isEmpty ? 'Address required' : null,
      'city': _cityController.text.trim().isEmpty ? 'City required' : null,
      'state': _stateController.text.trim().isEmpty ? 'State required' : null,
      'pincode': _validatePincode(_pincodeController.text),
      'pan': _validatePAN(_panController.text),
      'aadhar': _validateAadhar(_aadharController.text),
    };

    fns.forEach((k, v) {
      if (v != null) _fieldErrors[k] = v;
    });

    setState(() {}); // to show errors
    return _fieldErrors.isEmpty;
  }

  // -------------------------
  // PICKERS
  // -------------------------
  Future<void> _pickProfileImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.single.path != null) {
      final picked = File(res.files.single.path!);
      setState(() => _selectedProfileImage = picked);
      _showSuccessSnackbar("Profile image selected");
      _showImagePreview(picked);
    }
  }

  Future<void> _pickKycFile(int kycId, String fieldName) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (res != null && res.files.single.path != null) {
      final picked = File(res.files.single.path!);
      // add id entry if not present
      // use backend expected key names: kyc_ids[0], kyc_ids[1], ...
      if (!_kycIdFields.values.contains(kycId.toString())) {
        final key = 'kyc_ids[${_kycIndexCounter}]';
        _kycIdFields[key] = kycId.toString();
        _kycIndexCounter++;
      }
      setState(() {
        _kycFieldFiles[fieldName] = picked;
      });
      _showSuccessSnackbar("Document selected");
      // show image preview for images
      final ext = res.files.single.extension?.toLowerCase() ?? '';
      // Preview only if it is NOT profile picture
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Image.file(picked),
          ),
        );
      }

    }
  }

  void _showImagePreview(File img) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.file(img, fit: BoxFit.contain),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // SUBMIT: Profile Update
  // -------------------------
  Future<void> _submitProfileUpdate() async {
    if (!_validateAllFields()) {
      _showErrorSnackbar("Please fix highlighted errors");
      return;
    }

    setState(() => _isUpdatingProfile = true);
    try {
      final UpdateProfiles updateProvider = context.read<UpdateProfiles>();

      // Format DOB to ISO if needed (example: dd-mm-yyyy -> yyyy-mm-dd)
      String formattedDob(String dob) {
        if (dob.contains('-')) {
          final parts = dob.split('-');
          if (parts.length == 3) return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
        }
        return dob;
      }

      final body = <String, String>{
        "firstname": _firstNameController.text.trim(),
        "lastname": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "phone_code": "91",
        "username": "${_firstNameController.text.trim()}${DateTime.now().millisecondsSinceEpoch % 10000}",
        "country_code": "IN",
        "country": "India",
        "father_mother_wife_name": "",
        "date_of_birth": formattedDob(_dobController.text.trim()),
        "gender": _selectedGender.toLowerCase(),
        "address": _addressController.text.trim(),
        "city": _cityController.text.trim(),
        "state": _stateController.text.trim(),
        "zip_code": _pincodeController.text.trim(),
        "pan_number": _panController.text.trim(),
        "aadhar_number": _aadharController.text.trim(),
      };

      final files = <String, File>{};
      if (_selectedProfileImage != null) files['image'] = _selectedProfileImage!;

      final result = await updateProvider.updateProfile(body, files);
      print("______ $body----$result");
      // Some implementations return nothing and set updateProvider.updateResponse
      // final success = (updateProvider.updateResponse?.status == "success") ||
      //     (result is Map && result['status'] == 'success');

      if (result) {
        _showSuccessSnackbar("Profile updated");
        // reload profile
        await Provider.of<ProfileDetailsProvider>(context, listen: false).fetchProfile();
      } else {
        final msg = updateProvider.updateResponse?.message?? "Update failed";
        _showErrorSnackbar(msg);
      }
    } catch (e) {
      _showErrorSnackbar("Error updating profile");
    } finally {
      setState(() => _isUpdatingProfile = false);
    }
  }

  // -------------------------
  // SUBMIT: KYC Upload
  // -------------------------
  Future<void> _submitKyc() async {
    if (_kycFieldFiles.isEmpty) {
      _showErrorSnackbar("Please select at least one document");
      return;
    }

    setState(() => _isSubmittingKyc = true);
    try {
      final SubmitKycProvider kycProvider = Provider.of<SubmitKycProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileDetailsProvider>(context, listen: false);

      // Map files and fields
      final files = <String, File>{};
      files.addAll(_kycFieldFiles);

      final fields = <String, String>{};
      fields.addAll(_kycIdFields);

      final response = await kycProvider.kycDoc(fields, files);
      print("response is   ---------   $response");
      final success = (response is Map && response['status'] == 'success') || (profileProvider.profileData?.data?.profile != null && response == null);

      if (success) {
        _showSuccessSnackbar("KYC uploaded successfully");
        // clear selected files
        setState(() {
          _kycFieldFiles.clear();
          _kycIdFields.clear();
          _kycIndexCounter = 0;
        });
        await profileProvider.fetchProfile();
      } else {
        // try to extract message
        String err = "KYC upload failed";
        if (response is Map && response['data'] != null) {
          if (response['data'] is List) err = (response['data'] as List).join("\n");
          else err = response['data'].toString();
        }
        _showErrorSnackbar(err);
      }
    } catch (e) {
      _showErrorSnackbar("Error uploading KYC: $e");
    } finally {
      setState(() => _isSubmittingKyc = false);
    }
  }

  // -------------------------
  // UI helpers
  // -------------------------
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: AppTextStyles.bodyText), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: AppTextStyles.bodyText), backgroundColor: Colors.green),
    );
  }

  // -------------------------
  // WIDGET BUILD
  // -------------------------
  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _panController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileDetailsProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.referralCode24W600Gold),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          tabs: const [
            Tab(text: 'Personal Details'),
            Tab(text: 'KYC'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFFD700))))
          : TabBarView(
        controller: _tabController,
        children: [
          // ---------- PERSONAL DETAILS TAB ----------
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfilePicCard(),
                  const SizedBox(height: 20),
                  _buildTextField(label: 'First Name', controller: _firstNameController, icon: Icons.person_outline, errorText: _fieldErrors['firstName']),
                  const SizedBox(height: 12),
                  _buildTextField(label: 'Last Name', controller: _lastNameController, icon: Icons.person_outline, errorText: _fieldErrors['lastName']),
                  const SizedBox(height: 12),
                  _buildTextField(label: 'Email', controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, errorText: _fieldErrors['email']),
                  const SizedBox(height: 12),
                  _buildTextField(label: 'Mobile', controller: _phoneController, icon: Icons.phone_android, keyboardType: TextInputType.phone, prefix: '+91 ', errorText: _fieldErrors['phone']),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDatePickerField()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildGenderDropdown()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(label: 'Address', controller: _addressController, icon: Icons.home_outlined, errorText: _fieldErrors['address']),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(label: 'City', controller: _cityController, icon: Icons.location_city, errorText: _fieldErrors['city'])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(label: 'State', controller: _stateController, icon: Icons.map_outlined, errorText: _fieldErrors['state'])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(label: 'Pincode', controller: _pincodeController, icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number, maxLength: 6, errorText: _fieldErrors['pincode'])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(label: 'Country', controller: TextEditingController(text: 'India'), icon: Icons.public, readOnly: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(label: 'PAN', controller: _panController, icon: Icons.credit_card, maxLength: 11, errorText: _fieldErrors['pan'])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(label: 'Aadhar', controller: _aadharController, icon: Icons.badge, keyboardType: TextInputType.number, maxLength: 12, errorText: _fieldErrors['aadhar'])),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isUpdatingProfile ? null : _submitProfileUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF0A0A0A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      child: _isUpdatingProfile
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('Update Personal Details', style: AppTextStyles.buttonText),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ---------- KYC TAB ----------
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uploaded Documents', style: AppTextStyles.subHeading1),
                const SizedBox(height: 12),

                if ((profileProvider.profileData?.data?.profile?.kycDocuments ?? []).isEmpty)
                  Text('No uploaded documents', style: AppTextStyles.subHeading),

                ..._buildUploadedDocsList(profileProvider),

                const SizedBox(height: 22),
                Text('Pending KYC Documents', style: AppTextStyles.subHeading1),
                const SizedBox(height: 12),

                ..._buildPendingKycList(profileProvider),

                const SizedBox(height: 20),

                // 🔥 Hide upload button if approved
                if (profileProvider.profileData?.data?.profile?.kycStatus != "approved")
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmittingKyc ? null : _submitKyc,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF0A0A0A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      child: _isSubmittingKyc
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('Upload KYC', style: AppTextStyles.buttonText),
                    ),
                  ),

                const SizedBox(height: 60),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // Build profile pic card
  Widget _buildProfilePicCard() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
                  image: _selectedProfileImage != null ? DecorationImage(image: FileImage(_selectedProfileImage!), fit: BoxFit.cover) : null,
                ),
                child: _selectedProfileImage == null ? const Icon(Icons.person, size: 60, color: Color(0xFF0A0A0A)) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: const Color(0xFFFFD700), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0A0A0A), width: 2)),
                  child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFF0A0A0A)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('Tap to change profile picture', style: AppTextStyles.subHeading),
      ],
    );
  }

  // Build a generic labeled text field
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    String? prefix,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.subHeading),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.red : Colors.white.withOpacity(0.08)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            maxLength: maxLength,
            style: AppTextStyles.bodyText,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 20),
              prefixText: prefix,
              prefixStyle: AppTextStyles.bodyText,
              hintText: hint,
              hintStyle: AppTextStyles.subHeading.copyWith(color: Colors.white30),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              counterText: '',
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth', style: AppTextStyles.subHeading),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 25));
            try {
              if (_dobController.text.isNotEmpty) {
                // attempt parse dd-mm-yyyy or yyyy-mm-dd
                final parts = _dobController.text.split(RegExp(r'[-/]'));
                if (parts.length == 3) {
                  if (parts[0].length == 4) {
                    initial = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                  } else {
                    initial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                  }
                }
              }
            } catch (_) {}
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFFFFD700))), child: child!);
              },
            );
            if (picked != null) setState(() => _dobController.text = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Expanded(child: Text(_dobController.text.isEmpty ? 'Select date' : _dobController.text, style: AppTextStyles.bodyText)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTextStyles.subHeading),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFFD700)),
              items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g, style: AppTextStyles.bodyText))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedGender = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Build uploaded docs list UI
  List<Widget> _buildUploadedDocsList(ProfileDetailsProvider profileProvider) {
    final kycDocs = profileProvider.profileData?.data?.profile?.kycDocuments ?? [];
    if (kycDocs.isEmpty) return [];
    return kycDocs.map((group) {
      final name = group.kycName ?? 'Document';
      final fileUrl = (group.documents != null && group.documents!.isNotEmpty) ? group.documents!.first.fileUrl : null;
      final status = group.status ?? "Pending";
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.08))),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black26),
                  child: fileUrl != null && fileUrl.isNotEmpty ? Image.network(fileUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.insert_drive_file)) : const Icon(Icons.insert_drive_file),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(name, style: AppTextStyles.bodyText)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amberAccent)),
                  child: Text(status, style: AppTextStyles.subHeading.copyWith(color: Colors.amberAccent)),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  // Build pending KYC docs list with upload buttons, dynamic from provider
  List<Widget> _buildPendingKycList(ProfileDetailsProvider profileProvider) {
    final pending = profileProvider.profileData?.data?.profile?.pendingKycForms ?? [];

    if (pending.isEmpty) return [Text('No KYC documents required', style: AppTextStyles.subHeading)];

    return pending.map((group) {
      // group expected fields: kycId, kycName, requiredDocuments -> list with fieldName, fileType...
      final name = group.kycName ?? 'Document';
      final kycId = group.kycId ?? 0;
      final requiredDoc = (group.requiredDocuments ?? []).isNotEmpty ? group.requiredDocuments!.first : null;
      final fieldName = requiredDoc?.fieldName ?? 'file_${kycId}';
      final uploadedLocal = _kycFieldFiles[fieldName];

      return Column(
        children: [
          GestureDetector(
            onTap: () async {
              await _pickKycFile(kycId, fieldName);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.08))),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black26),
                    child: uploadedLocal != null ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(uploadedLocal, fit: BoxFit.cover)) : const Icon(Icons.upload_file),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(name, style: AppTextStyles.bodyText)),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async => await _pickKycFile(kycId, fieldName),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: const Color(0xFF0A0A0A)),
                    child: Text(uploadedLocal != null ? 'Change' : 'Upload', style: AppTextStyles.buttonText.copyWith(color: const Color(0xFF0A0A0A))),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
