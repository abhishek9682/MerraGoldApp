import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../compenent/custom_style.dart';
import '../controllers/buy_gold.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'buy_gold_success_screen.dart';

class BuyGoldPaymentScreen extends StatefulWidget {
  final double goldAmount;
  final double cashAmount;

  const BuyGoldPaymentScreen({
    super.key,
    required this.goldAmount,
    required this.cashAmount,
  });

  @override
  State<BuyGoldPaymentScreen> createState() => _BuyGoldPaymentScreenState();
}

class _BuyGoldPaymentScreenState extends State<BuyGoldPaymentScreen> {
  int _selectedNavIndex = 1;
  int _selectedPaymentMethod = 0;
  final double gstRate = 0.03;

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

  double _getGoldValue() => widget.cashAmount / (1 + gstRate);
  double _getGST() => widget.cashAmount - _getGoldValue();

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 0:
        return 'UPI';
      case 1:
        return 'Net Banking';
      case 2:
        return 'Debit/Credit Card';
      case 3:
        return 'Meera Wallet';
      default:
        return 'UPI';
    }
  }

  void _confirmPayment() async{
    final provider = Provider.of<BuyGold>(context, listen: false);

    Map<String, dynamic> body = {
      "amount": widget.goldAmount,
      "gateway_id": 10,
      "supported_currency": "INR"
    };

    bool success = await provider.buyGold(body);
    String? txnId=provider.paymentInitiationRequest?.trxId;
    print("buy response__---$success---${provider.loading}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyGoldSuccessScreen(
          txnId:"$txnId",
          goldAmount: widget.goldAmount,
          cashAmount: widget.cashAmount,
          paymentMethod: _getPaymentMethodName(),
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
        title: Text('Payment Details', style: AppTextStyles.pageTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 Purchase Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Gold Purchase', '${widget.goldAmount.toStringAsFixed(3)}g'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Gold Rate', '₹6,850/g'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Total Amount', '₹${widget.cashAmount.toStringAsFixed(0)}', isHighlight: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔸 Payment Breakdown
            Text('Payment Breakdown', style: AppTextStyles.labelText),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Gold Value', '₹${_getGoldValue().toStringAsFixed(0)}'),
                  const SizedBox(height: 12),
                  _buildDetailRow('GST (3%)', '₹${_getGST().toStringAsFixed(0)}'),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  _buildDetailRow('Total Payable', '₹${widget.cashAmount.toStringAsFixed(0)}', isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔸 Select Payment Method
            Text('Select Payment Method', style: AppTextStyles.labelText),
            const SizedBox(height: 12),

            _buildPaymentMethodCard(
              icon: '📱',
              title: 'UPI Payment',
              subtitle: 'Pay via Google Pay, PhonePe, Paytm',
              account: 'Instant & Secure',
              isSelected: _selectedPaymentMethod == 0,
              onTap: () => setState(() => _selectedPaymentMethod = 0),
            ),

            const SizedBox(height: 12),

            _buildPaymentMethodCard(
              icon: '🏦',
              title: 'Net Banking',
              subtitle: 'Pay via your bank account',
              account: 'All major banks supported',
              isSelected: _selectedPaymentMethod == 1,
              onTap: () => setState(() => _selectedPaymentMethod = 1),
            ),

            const SizedBox(height: 12),

            _buildPaymentMethodCard(
              icon: '💳',
              title: 'Debit/Credit Card',
              subtitle: 'Visa, Mastercard, RuPay',
              account: 'Secure payment gateway',
              isSelected: _selectedPaymentMethod == 2,
              onTap: () => setState(() => _selectedPaymentMethod = 2),
            ),

            const SizedBox(height: 12),

            _buildPaymentMethodCard(
              icon: '💰',
              title: 'Meera Wallet',
              subtitle: 'Pay from wallet balance',
              account: 'Balance: ₹1,280',
              isSelected: _selectedPaymentMethod == 3,
              onTap: () => setState(() => _selectedPaymentMethod = 3),
            ),

            const SizedBox(height: 24),

            // 🔸 Security Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment is 100% secure. We use bank-grade 256-bit encryption to protect your data.',
                      style: AppTextStyles.featureLabel.copyWith(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔸 Pay Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF0A0A0A),
                  elevation: 8,
                  shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Pay ₹${widget.cashAmount.toStringAsFixed(0)} & Buy Gold',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.labelText),
        Text(
          value,
          style: isHighlight
              ? AppTextStyles.heading.copyWith(fontSize: 18)
              : AppTextStyles.bodyText.copyWith(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.labelText),
        Text(
          value,
          style: isBold
              ? AppTextStyles.buttonText.copyWith(color: Colors.white)
              : AppTextStyles.bodyText.copyWith(color: Colors.white),
        ),
      ],
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
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.subInputText.copyWith(color: Colors.white60)),
                  const SizedBox(height: 4),
                  Text(account, style: AppTextStyles.featureLabel.copyWith(color: const Color(0xFFFFD700))),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF0A0A0A), size: 20),
              ),
          ],
        ),
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
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFFFD700) : Colors.white60, size: 24),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.subInputText.copyWith(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white60,
          )),
        ],
      ),
    );
  }
}
