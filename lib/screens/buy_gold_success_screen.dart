import 'package:flutter/material.dart';
import '../compenent/custom_style.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'buy_gold_screen.dart';

class BuyGoldSuccessScreen extends StatefulWidget {
  final double goldAmount;
  final double cashAmount;
  final String paymentMethod;
  final String txnId;
  const BuyGoldSuccessScreen({
    super.key,
    required this.goldAmount,
    required this.cashAmount,
    required this.paymentMethod,
    required this.txnId,
  });

  @override
  State<BuyGoldSuccessScreen> createState() => _BuyGoldSuccessScreenState();
}

class _BuyGoldSuccessScreenState extends State<BuyGoldSuccessScreen> {
  int _selectedNavIndex = 1; // Wallet tab selected

  void _onNavItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WalletScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final newTotalHoldings = 6.61 + widget.goldAmount;
    final newPortfolioValue = 45280 + widget.cashAmount;
    DateTime now = DateTime.now();
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
                  'Gold Purchased Successfully!',
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Success Message
                Text(
                  'Congratulations! Your digital gold has been added to your wallet. You can view it anytime or sell when you want.',
                  style: AppTextStyles.bodyText.copyWith(fontSize: 14, color: Colors.white70, height: 1.5),
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
                      Text(
                        'Transaction ID',
                        style: AppTextStyles.labelText.copyWith(fontSize: 12, color: Colors.white60),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.txnId,
                        style: AppTextStyles.subInputText.copyWith(fontSize: 16, color: const Color(0xFFFFD700)),
                      ),
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
                      _buildDetailRow('Gold Purchased', '${widget.goldAmount.toStringAsFixed(3)} grams'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Amount Paid', '₹${widget.cashAmount.toStringAsFixed(0)}'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Payment Method', widget.paymentMethod),
                      const SizedBox(height: 12),
                      _buildDetailRow('New Total Holdings', '${newTotalHoldings.toStringAsFixed(2)} grams'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Portfolio Value', '₹${newPortfolioValue.toStringAsFixed(0)}'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Date & Time', '$now'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // View My Wallet Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const WalletScreen()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF0A0A0A),
                      elevation: 8,
                      shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('View My Wallet', style: AppTextStyles.buttonText),
                  ),
                ),

                const SizedBox(height: 12),

                // Buy More Gold Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const BuyGoldScreen(amount: null,)),
                            (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Buy More Gold', style: AppTextStyles.buttonText.copyWith(color: const Color(0xFFFFD700))),
                  ),
                ),

                const SizedBox(height: 12),

                // Back to Dashboard Button
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          (route) => false,
                    );
                  },
                  child: Text('Back to Dashboard', style: AppTextStyles.buttonText.copyWith(color: Colors.white60)),
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
        Text(label, style: AppTextStyles.labelText),
        Text(value, style: AppTextStyles.subInputText.copyWith(color: Colors.white)),
      ],
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
      onTap: () => _onNavItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFFD700) : Colors.white60, size: 24),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodyText.copyWith(
              color: isSelected ? const Color(0xFFFFD700) : Colors.white60,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 11,
            )),
          ],
        ),
      ),
    );
  }
}
