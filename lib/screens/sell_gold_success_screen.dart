import 'package:flutter/material.dart';
import '../compenent/custom_style.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class SellGoldSuccessScreen extends StatefulWidget {
  final double goldAmount;
  final double cashAmount;
  final String paymentMethod;
  final String txnId;

  const SellGoldSuccessScreen({
    super.key,
    required this.goldAmount,
    required this.cashAmount,
    required this.paymentMethod,
    required this.txnId,
  });

  @override
  State<SellGoldSuccessScreen> createState() => _SellGoldSuccessScreenState();
}

class _SellGoldSuccessScreenState extends State<SellGoldSuccessScreen> {
  int _selectedNavIndex = 1; // Wallet tab selected

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 70,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 32),

                // Success Title
                Text(
                  'Gold Sold Successfully!',
                  style: AppTextStyles.body24W700White,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Success Message
                Text(
                  'Your gold has been sold and the amount will be credited to your bank account within 24 hours.',
                  style: AppTextStyles.body14White70,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Transaction ID
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Text('Transaction ID', style: AppTextStyles.body12White60),
                      const SizedBox(height: 4),
                      Text('${widget.txnId}', style: AppTextStyles.body16W600Gold),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Transaction Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Gold Sold', '${widget.goldAmount.toStringAsFixed(3)} grams'),
                      const SizedBox(height: 16),
                      _buildDetailRow('Sale Amount', '₹${widget.cashAmount.toStringAsFixed(0)}'),
                      const SizedBox(height: 16),
                      _buildDetailRow('Credited to', widget.paymentMethod),
                      const SizedBox(height: 16),
                      _buildDetailRow('Date & Time', 'Jan 18, 2025 10:30 AM'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // View Transaction History Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF0A0A0A),
                      elevation: 8,
                      shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text('View Transaction History', style: AppTextStyles.body16W600Black),
                  ),
                ),

                const SizedBox(height: 12),

                // Back to Dashboard Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                            (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Back to Dashboard',
                      style: AppTextStyles.body16W600Gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body13White60),
        Text(value, style: AppTextStyles.body14W600White),
      ],
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFFD700) : Colors.white60, size: 24),
            const SizedBox(height: 4),
            Text(label, style: isSelected ? AppTextStyles.navLabel11W600Gold : AppTextStyles.navLabel11White60),
          ],
        ),
      ),
    );
  }
}
