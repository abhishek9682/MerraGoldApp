import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/transaction_list.dart';
import '../models/Transaction_list.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart'; // Import for navigation

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  int _selectedNavIndex = 2;

  final List<Map<String, dynamic>> _transactions = [];
  final List<Map<String, dynamic>> _rewardTransactions = [];

  bool valid=true;
  void initialization(bool valid) {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
      valid=false;
  }

  List<TransactionItem> get _filteredTransactions {
    final provider = Provider.of<TransactionProvider>(context);

    if (_selectedFilter == 'All') return provider.transactions;

    return provider.filterTransactions(_selectedFilter);
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
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
            }
        ),
        title: Text(
          'Transaction History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTransactionsList(),
                  if (_selectedFilter != 'Rewards') ...[
                    const SizedBox(height: 20),
                    _buildMonthlySummary(),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _onNavItemTapped(int index) {
    if (_selectedNavIndex == index) return; // Do nothing if the same tab is tapped

    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFFD700) : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFFFFD700) : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          _buildFilterTab('All'),
          _buildFilterTab('Buy'),
          _buildFilterTab('Sell'),
          _buildFilterTab('Rewards'), // Added Rewards Tab
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF0A0A0A) : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 60, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'No Transactions Found',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history for this filter will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
          ),
        ],
      ),
    );
  }


  Widget _buildTransactionsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedFilter == 'All' ? 'All Transactions' : 'Recent ${_selectedFilter}s',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredTransactions.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];

                // make type check case-insensitive + null-safe
                final type = (transaction.trxType ?? '').toLowerCase();

                if (type == 'reward') {
                  return _buildRewardItem(transaction);   // <-- Reward UI
                }

                return _buildTransactionItem(transaction); // <-- Normal UI
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(TransactionItem txn) {
    return InkWell(
      onTap: () {
        // create a Map to feed the modal (same shape as other transactions)
        final transactionMap = {
          'type': txn.trxType,
          'title': txn.remarks ?? 'Reward',
          'date': txn.createdAt ?? '',
          'id': txn.trxId ?? '',
          'amount': "₹${txn.amount ?? ''}",
          'reason': txn.remarks ?? '',
          'status': txn.status ?? '',
        };
        _showTransactionDetails(transactionMap);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Colors.blueAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.remarks ?? 'Reward',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    txn.status ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${txn.amount ?? ''}",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  txn.createdAt ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTransactionItem(TransactionItem txn) {
    final isBuy = txn.trxType?.toLowerCase() == 'buy';

    return InkWell(
      onTap: () {
        _showTransactionDetails({
          'type': txn.trxType,
          'title': isBuy ? "Gold Purchase" : "Gold Redemption",
          'date': txn.createdAt ?? "",
          'id': txn.trxId ?? "",
          'gold': txn.remarks ?? "",
          'amount': "₹${txn.amount ?? ""}",
          'status': txn.trxType ?? "",
          'statusColor': isBuy ? Colors.green : Colors.red,
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isBuy
                    ? const Color(0xFFFFD700).withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                color: isBuy ? const Color(0xFFFFD700) : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuy ? "Gold Purchase" : "Gold Redemption",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    txn.createdAt ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ID: ${txn.trxId ?? ""}",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  // txn.gold ?? "",
                  "",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isBuy ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${txn.amount ?? ""}",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isBuy ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    txn.remarks ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isBuy ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMonthlySummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A2A1A),
            Color(0xFF1A1A0A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFFFFD700),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'This Month Summary',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Invested',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹14,500',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gold Acquired',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2.117g',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final isReward = transaction['type'] == 'reward';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Transaction Details',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Type', transaction['title']),
              if(isReward) _buildDetailRow('Reason', transaction['reason']),
              _buildDetailRow('Date & Time', transaction['date']),
              _buildDetailRow('Transaction ID', transaction['id']),
              if(!isReward) _buildDetailRow('Gold Amount', transaction['gold']),
              _buildDetailRow(isReward ? 'Reward Amount' : 'Total Price', transaction['amount']),
              _buildDetailRow('Status', transaction['status']),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF0A0A0A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}