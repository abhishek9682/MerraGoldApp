import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goldproject/compenent/loader.dart';
import 'package:goldproject/controllers/profile_details.dart';
import 'package:provider/provider.dart';
import '../compenent/custom_style.dart';
import '../controllers/add_bank_account.dart';
import '../models/get_profile_details.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';

class AddBankAccountScreen extends StatefulWidget {
  final BankAccount? bank;

  const AddBankAccountScreen({super.key, this.bank});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _confirmAccountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  bool isLoading = false;

  /// FIXED: make nullable!
  String? _selectedAccountType;
  int _selectedNavIndex = 3;

  @override
  void initState() {
    super.initState();

    if (widget.bank != null) {
      _bankNameController.text = widget.bank!.bankName ?? '';
      _accountHolderController.text = widget.bank!.accountHolderName ?? '';
      _accountNumberController.text = widget.bank!.accountNumber ?? '';
      _confirmAccountController.text = widget.bank!.accountNumber ?? '';
      _ifscController.text = widget.bank!.ifscCode ?? '';
      _branchController.text = widget.bank!.branchName ?? '';

      /// FIXED: ensure dropdown always gets a valid value
      _selectedAccountType =
      widget.bank!.accountType == "savings" || widget.bank!.accountType == "current"
          ? widget.bank!.accountType
          : "savings";
    }
  }

  // ------------------------------- VALIDATION -------------------------------
  bool _validateForm() {
    if (_bankNameController.text.isEmpty ||
        _accountHolderController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _confirmAccountController.text.isEmpty ||
        _ifscController.text.isEmpty ||
        _selectedAccountType == null) {
      _showSnackbar("Please fill all required fields", false);
      return false;
    }

    if (_accountNumberController.text != _confirmAccountController.text) {
      _showSnackbar("Account numbers do not match", false);
      return false;
    }

    if (_ifscController.text.length != 11) {
      _showSnackbar("IFSC code must be 11 characters", false);
      return false;
    }

    return true;
  }

  void _showSnackbar(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.body14W600White),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _addBankAccount() async {
    if (!_validateForm()) return;

    setState(() => isLoading = true);

    final provider = Provider.of<BankAccountProvider>(context, listen: false);
    final profile = Provider.of<ProfileDetailsProvider>(context, listen: false);
    bool success;
    if(widget.bank!=null) {
      success = await provider.updateBankAccountDetail(
        bankName: _bankNameController.text,
        accountHolder: _accountHolderController.text,
        accountNumber: _accountNumberController.text,
        confirmAccountNumber: _confirmAccountController.text,
        ifsc: _ifscController.text,
        branch: _branchController.text,
        accountType: _selectedAccountType!,
        bankId: widget.bank!.id.toString()
      );
    }
    else {
      success = await provider.addBankAccount(
        bankName: _bankNameController.text,
        accountHolder: _accountHolderController.text,
        accountNumber: _accountNumberController.text,
        confirmAccountNumber: _confirmAccountController.text,
        ifsc: _ifscController.text,
        branch: _branchController.text,
        accountType: _selectedAccountType!,
      );
    }

    if (!mounted) return;
    await profile.fetchProfile();

    setState(() => isLoading = false);

    _showSnackbar(
      success ? "Bank account saved successfully!" : provider.message,
      success,
    );

    if (success) Navigator.pop(context);
  }

  // ------------------------------- UI -------------------------------

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
        title: Text('Add Bank Account', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: Consumer<BankAccountProvider>(
        builder: (context, provider, child) {
          return provider.loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
              : _buildForm();
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bank Details', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 20),
          _buildTextField("BANK NAME", _bankNameController, Icons.account_balance, "Enter bank name"),
          const SizedBox(height: 16),
          _buildTextField("ACCOUNT HOLDER NAME", _accountHolderController, Icons.person_outline, "As per bank records"),
          const SizedBox(height: 16),
          _buildTextField("ACCOUNT NUMBER", _accountNumberController, Icons.credit_card, "Enter account number",
              keyboardType: TextInputType.number, maxLength: 12),
          const SizedBox(height: 16),
          _buildTextField("CONFIRM ACCOUNT NUMBER", _confirmAccountController, Icons.credit_card, "Re-enter number",
              keyboardType: TextInputType.number, maxLength: 12),
          const SizedBox(height: 16),
          _buildTextField("IFSC CODE", _ifscController, Icons.numbers, "Enter IFSC", maxLength: 11),
          const SizedBox(height: 16),
          _buildAccountTypeDropdown(),
          const SizedBox(height: 16),
          _buildTextField("BRANCH NAME", _branchController, Icons.business, "Optional"),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon, String hint,
      {TextInputType keyboardType = TextInputType.text, int? maxLength}) {
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
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: AppTextStyles.body15W600White,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
              hintText: hint,
              counterText: "",
              hintStyle: AppTextStyles.body14White70,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ACCOUNT TYPE", style: AppTextStyles.labelText),
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
              value: _selectedAccountType, // FIXED
              dropdownColor: const Color(0xFF1A1A1A),
              isExpanded: true,
              hint: Text("Select account type", style: AppTextStyles.body14White70),
              items: const [
                DropdownMenuItem(value: "savings", child: Text("Savings Account", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: "current", child: Text("Current Account", style: TextStyle(color: Colors.white))),
              ],
              onChanged: (v) => setState(() => _selectedAccountType = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isLoading
          ? const CustomLoader()
          : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _addBankAccount,
        child: Text(widget.bank == null ? "Add Bank Account" : "Update Bank Account",
            style: AppTextStyles.buttonText),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, "Home"),
              _buildNavItem(1, Icons.account_balance_wallet, "Wallet"),
              _buildNavItem(2, Icons.history, "History"),
              _buildNavItem(3, Icons.person, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final selected = _selectedNavIndex == index;

    return InkWell(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? const Color(0xFFFFD700) : Colors.white60),
          Text(label,
              style: selected ? AppTextStyles.navLabel11W600Gold : AppTextStyles.navLabel11White60),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (_) => false);
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const WalletScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        break;
      case 3:
        Navigator.pop(context);
        break;
    }
  }
}
