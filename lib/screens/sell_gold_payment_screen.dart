import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../compenent/custom_style.dart';
import '../controllers/profile_details.dart';
import '../controllers/sell_gold.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'sell_gold_success_screen.dart';

class SellGoldPaymentScreen extends StatefulWidget {
  final double goldAmount;
  final double cashAmount;
  final int selectId;

  const SellGoldPaymentScreen({
    super.key,
    required this.goldAmount,
    required this.cashAmount,
    required this.selectId,
  });

  @override
  State<SellGoldPaymentScreen> createState() => _SellGoldPaymentScreenState();
}

class _SellGoldPaymentScreenState extends State<SellGoldPaymentScreen> {
  int _selectedNavIndex = 1;
  int _selectedPaymentMethod = 0;
  bool _initialProfileFetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileDetailsProvider>(context, listen: false);
      profileProvider.fetchProfile().whenComplete(() {
        setState(() => _initialProfileFetched = true);
      });
    });
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  Future<void> _confirmSale() async {
    final goldProvider = Provider.of<GoldSellProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileDetailsProvider>(context, listen: false);

    await profileProvider.fetchProfile();

    final gold = widget.goldAmount;
    final amount = widget.cashAmount;

    if (gold <= 0 || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount or gold weight")),
      );
      return;
    }

    Map<String, dynamic> body = {
      "gold_grams": gold,
    };

    if (_selectedPaymentMethod == 0) {
      int bankId = widget.selectId;

      final primary = profileProvider.primaryBank;
      if ((bankId == 0 || bankId == -1) && primary != null) {
        bankId = primary.id ?? bankId;
      }

      body.addAll({
        "payment_method": "bank_transfer",
        "bank_account_id": bankId,
      });
    } else {
      body.addAll({
        "payment_method": "upi",
        "upi_id": "${profileProvider.profileData?.data?.profile?.upiId}",
      });
    }

    final success = await goldProvider.sellGold(body);
    debugPrint("Sell Request Body => $body--${success}");
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellGoldSuccessScreen(
            goldAmount: gold,
            cashAmount: amount,
            paymentMethod: _selectedPaymentMethod == 0 ? "Bank Transfer" : "UPI",
            txnId: "${goldProvider.sellResponse?.data?.trxId}",
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sell request submitted"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit sell request. Please try again "),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileDetailsProvider>(context);
    final goldProvider = Provider.of<GoldSellProvider>(context);

    String bankAccountText = "HDFC Bank •••• 4532";

    if (profileProvider.primaryBank != null &&
        profileProvider.primaryBank!.accountNumber != null &&
        profileProvider.primaryBank!.accountNumber!.length >= 4) {
      String last4 = profileProvider.primaryBank!.accountNumber!.substring(
        profileProvider.primaryBank!.accountNumber!.length - 4,
      );

      bankAccountText = "${profileProvider.primaryBank!.bankName ?? 'Bank'} •••• $last4";
    }

    String upiText = "";

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
            _buildSaleSummary(),
            const SizedBox(height: 32),
            Text('Select Payment Method', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(
              icon: '🏦',
              title: 'Bank Transfer',
              subtitle: 'Direct deposit to bank account',
              account: bankAccountText,
              isSelected: _selectedPaymentMethod == 0,
              onTap: () => setState(() => _selectedPaymentMethod = 0),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              icon: '📱',
              title: 'UPI Transfer',
              subtitle: 'Instant transfer via UPI',
              account: upiText,
              isSelected: _selectedPaymentMethod == 1,
              onTap: () => setState(() => _selectedPaymentMethod = 1),
            ),
            const SizedBox(height: 24),
            _buildInfoBox(),
            const SizedBox(height: 24),
            _buildConfirmButton(isLoading: goldProvider.isLoading),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSaleSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.2),
            const Color(0xFF2A2A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gold to Sell', style: AppTextStyles.body14White70),
              Text('${widget.goldAmount.toStringAsFixed(3)} grams', style: AppTextStyles.body15W600White),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('You will receive', style: AppTextStyles.body16W600White),
              Text('₹${widget.cashAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.body24W700Gold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String icon,
    required String title,
    required String subtitle,
    required String account,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(icon, style: AppTextStyles.icon24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body15W700White),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.body12White60),
                  const SizedBox(height: 4),
                  Text(account, style: AppTextStyles.body13W600Gold),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration:
                const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Color(0xFF0A0A0A), size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Funds will be credited within 24 hours to your selected payment method.',
              style: AppTextStyles.body13W600Gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton({required bool isLoading}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _confirmSale,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: const Color(0xFF0A0A0A),
          elevation: 8,
          shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Processing...', style: AppTextStyles.body18W600Black),
          ],
        )
            : Text('Confirm & Sell Gold', style: AppTextStyles.body18W600Black),
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
      onTap: () => _onNavNavTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? const Color(0xFFFFD700) : Colors.white60, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: isSelected
                  ? AppTextStyles.navLabel11W600Gold
                  : AppTextStyles.navLabel11White60),
        ],
      ),
    );
  }

  void _onNavNavTapped(int index) => _onNavItemTapped(index);
}
