import 'package:flutter/material.dart';
import 'package:goldproject/screens/sell_gold_payment_screen.dart';
import 'package:provider/provider.dart';
import '../compenent/custom_style.dart';
import '../controllers/gold_data.dart';
import '../controllers/profile_details.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class SellGoldScreen extends StatefulWidget {
  const SellGoldScreen({super.key});

  @override
  State<SellGoldScreen> createState() => _SellGoldScreenState();
}

class _SellGoldScreenState extends State<SellGoldScreen> {
  int? _selectedBankId;
  int _selectedNavIndex = 1; // Wallet tab selected
  bool _isByAmount = true;
  int _selectedQuickAmount = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<ProfileDetailsProvider>(context, listen: false);
      provider.fetchProfile().then((_) {
        final primary = provider.profileData?.data?.profile?.primaryBankAccount?.id;
        if (primary != null) {
          setState(() => _selectedBankId = primary);
        }
      });
    });
  }


  Widget _buildBankDropdown() {
    final profileProvider = Provider.of<ProfileDetailsProvider>(context);
    final banks = profileProvider.profileData?.data?.profile?.bankAccounts ?? [];

    if (banks.isEmpty) {
      return Text("No bank accounts available", style: TextStyle(color: Colors.white70));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButton<int>(
        value: _selectedBankId,
        hint: Text('Select bank account', style: TextStyle(color: Colors.white70)),
        isExpanded: true,
        dropdownColor: const Color(0xFF1A1A1A),
        underline: const SizedBox(),
        items: banks.map<DropdownMenuItem<int>>((bank) {
          // adapt fields to your model names
          final id = bank.id as int?;
          final label = "${bank.bankName ?? 'Bank'} • ${bank.accountNumber ?? ''}";
          return DropdownMenuItem<int>(
            value: id,
            child: Text(label, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedBankId = value;
          });
        },
      ),
    );
  }

  final TextEditingController _amountController =
  TextEditingController(text: '5000');
  final TextEditingController _goldController =
  TextEditingController(text: '0.730');

  final double goldRate = 11700.0;
  final double totalGold = 6.61;
  final double totalValue = 45280.0;

  final List<Map<String, dynamic>> _quickAmounts = [
    {'amount': 1000, 'gold': 0.146},
    {'amount': 5000, 'gold': 0.730},
    {'amount': 10000, 'gold': 1.460},
    {'amount': 20000, 'gold': 2.919},
    {'amount': 45280, 'gold': 6.61, 'label': '6.61g (All)'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _goldController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }


  void _calculateGold() async {
    final provider = Provider.of<GoldDetails>(context, listen: false);

    Map<String, String> body = {
      "type": "inr_to_grams",
      "amount": _amountController.text
    };

    await provider.goldDetails(body);
    if (provider.goldCalculationResponse != null) {
      final gramsStr = provider.goldCalculationResponse!.data!.grams; // String?
      final grams = double.tryParse(gramsStr ?? "0") ?? 0; // convert → double

      _goldController.text = grams.toStringAsFixed(3);
    }
  }


  void _calculateAmount() async {
    final provider = Provider.of<GoldDetails>(context, listen: false);

    Map<String, String> body = {
      "type": "grams_to_inr",
      "amount": _goldController.text
    };

    await provider.goldDetails(body);

    if (provider.goldCalculationResponse != null) {
      final amountStr = provider.goldCalculationResponse!.data!.netAmount; // String?
      final amount = double.tryParse(amountStr ?? "0") ?? 0;

      _amountController.text = amount.toStringAsFixed(0);
    }
  }

  void _selectQuickAmount(int index) {
    setState(() {
      _selectedQuickAmount = index;
      _amountController.text = _quickAmounts[index]['amount'].toString();
      _goldController.text = _quickAmounts[index]['gold'].toString();
    });
  }


  void _continueToPayment() async {
    // final goldProvider = Provider.of<GoldSellProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileDetailsProvider>(context, listen: false);

    // Ensure latest profile (optional)
    await profileProvider.fetchProfile();

    final double gold = double.tryParse(_goldController.text.trim()) ?? 0;
    final double amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (gold <= 0 || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid amount or gold weight")),
      );
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context)=> SellGoldPaymentScreen(selectId: _selectedBankId!,goldAmount: gold, cashAmount: amount,)));
    //
    // if (_selectedBankId == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Please select a bank account")),
    //   );
    //   return;
    // }
    // //
    // final body = {
    //   "gold_grams": _goldController.text.trim(),
    //   "payment_method": "bank_transfer",
    //   "bank_account_id": _selectedBankId,
    //   // add other required fields
    // };

    // show loader
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (_) => const Center(child: CircularProgressIndicator()),
    // );

    // try {
    //   // final success = await goldProvider.sellGold(body);
    //   // Navigator.of(context).pop(); // remove loader
    //  Navigator.push(context, MaterialPageRoute(builder: (context)=> SellGoldPaymentScreen(goldAmount: gold, cashAmount: amount,)));
    //   if (success) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Sell request submitted"), backgroundColor: Colors.green),
    //
    //     );
    //     // navigate or refresh
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Sell request failed"), backgroundColor: Colors.red),
    //     );
    //   }
    // } catch (e) {
    //   Navigator.of(context).pop(); // remove loader
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
    //   );
    // }
  }


  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<ProfileDetailsProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sell Gold', style: AppTextStyles.pageTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Holdings Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Gold', style: AppTextStyles.body13W600Gold),
                      const SizedBox(height: 4),
                      Text('${provider.profileData?.data?.profile?.goldBalance}g', style: AppTextStyles.body24W700Gold),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Current Value', style: AppTextStyles.body13W600Gold),
                      const SizedBox(height: 4),
                      Text('${provider.profileData?.data?.profile?.goldBalanceValue}',
                          style: AppTextStyles.body24W700Gold),
                      Text('${provider.profileData?.data?.profile?.currentGoldPricePerGram}',
                          style: AppTextStyles.body12White60),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Selection Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                      child: _buildToggleButton('By Amount', _isByAmount, () {
                        setState(() {
                          _isByAmount = true;
                        });
                      })),
                  Expanded(
                      child:
                      _buildToggleButton('By Gold Weight', !_isByAmount, () {
                        setState(() {
                          _isByAmount = false;
                        });
                      })),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount/Gold Input Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    _isByAmount
                        ? 'Enter Amount to Withdraw'
                        : 'Enter Gold Weight to Sell',
                    style: AppTextStyles.body14White70,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isByAmount)
                        Text('₹', style: AppTextStyles.body24W700Gold),
                      const SizedBox(width: 8),
                      Flexible(
                        child: TextField(
                          controller:
                          _isByAmount ? _amountController : _goldController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body24W700Gold,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: '0'),
                          onChanged: (value) {
                            setState(() {
                              if (_isByAmount) {
                                _calculateGold();

                              } else {
                                _calculateAmount();
                              }
                            });
                          },
                        ),
                      ),
                      if (!_isByAmount)
                        Text('g', style: AppTextStyles.body24W700Gold),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isByAmount
                        ? '= ${_goldController.text} grams'
                        : '= ₹${_amountController.text}',
                    style: AppTextStyles.body16W600White,
                  ),
                  const SizedBox(height: 4),
                  Text('Current gold rate: ₹$goldRate/gram',
                      style: AppTextStyles.body12White60),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Select
            Text('Quick Select', style: AppTextStyles.body16W600White),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...List.generate(_quickAmounts.length, (index) {
                  return _buildQuickAmountChip(
                    amount: '₹${_quickAmounts[index]['amount']}',
                    gold: _quickAmounts[index]['label'] ??
                        '${_quickAmounts[index]['gold']}g',
                    isSelected: _selectedQuickAmount == index,
                    onTap: () => _selectQuickAmount(index),
                  );
                }),
                _buildQuickAmountChip(
                  amount: 'Custom',
                  gold: 'Enter value',
                  isSelected: false,
                  onTap: () {
                    setState(() {
                      _selectedQuickAmount = -1;
                      _amountController.clear();
                      _goldController.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Once confirmed, this transaction cannot be reversed. Funds will be credited to your registered bank account within 24 hours.',
                      style: AppTextStyles.body13W600Gold.copyWith(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _continueToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF0A0A0A),
                  elevation: 8,
                  shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Continue to Payment',
                    style: AppTextStyles.body18W600Black),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFD700) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: isActive
                ? AppTextStyles.body14White70.copyWith(color: const Color(0xFF0A0A0A))
                : AppTextStyles.body14White70,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip({
    required String amount,
    required String gold,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.2)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : Colors.white.withOpacity(0.1),
              width: 2),
        ),
        child: Column(
          children: [
            Text(amount,
                style: AppTextStyles.body15W600White.copyWith(
                    color: isSelected ? const Color(0xFFFFD700) : Colors.white)),
            const SizedBox(height: 4),
            Text(gold, style: AppTextStyles.body12White60),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.account_balance_wallet, 'Wallet'),
              _buildNavItem(2, Icons.history, 'History'),
              _buildNavItem(3, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return InkWell(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFFFD700) : Colors.white60, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: isSelected ? AppTextStyles.navLabel11W600Gold : AppTextStyles.navLabel11White60),
        ],
      ),
    );
  }
}
