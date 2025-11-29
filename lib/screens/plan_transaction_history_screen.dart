import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanTransactionHistoryScreen extends StatelessWidget {
  final String planTitle;
  final Color planColor;
  final Map<String, dynamic> plan;

  const PlanTransactionHistoryScreen({
    super.key,
    required this.planTitle,
    required this.planColor,
    required this.plan,
  });

  // --------------------------------------------------------------------------
  // 🧮 Calculate Total Investment Safely
  // --------------------------------------------------------------------------
  int _calculateTotalInvestment(List? transactions) {
    if (transactions == null || transactions.isEmpty) return 0;

    int sum = 0;
    for (var t in transactions) {
      final amount = int.tryParse("${t["amount"]}") ?? 0;
      sum += amount;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final int totalInvestment = _calculateTotalInvestment(plan["transactions"]);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "History",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildPlanHeader(totalInvestment),
            const SizedBox(height: 20),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🔥 Header
  // --------------------------------------------------------------------------
  Widget _buildPlanHeader(int totalInvestment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            planColor.withOpacity(0.35),
            planColor.withOpacity(0.20),
            Colors.black.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: planColor.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _circleIcon(),
              const SizedBox(width: 16),
              _titleSection(),
              _activeBadge(),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow(totalInvestment),
        ],
      ),
    );
  }

  Widget _circleIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: planColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.savings, color: planColor, size: 26),
    );
  }

  Widget _titleSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            planTitle,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            plan["created_at"] ?? "N/A",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _activeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "Active",
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.greenAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _summaryRow(int totalInvestment) {
    return Row(
      children: [
        _summaryTile(
          label: "Total Invested",
          value: "₹$totalInvestment",
          valueColor: planColor,
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 📌 Transactions Section
  // --------------------------------------------------------------------------
  Widget _buildTransactionHistory() {
    final List transactions = plan["transactions"] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transaction History",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          if (transactions.isEmpty) _noTransactions(),

          if (transactions.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.white12),
              itemBuilder: (ctx, i) => _transactionTile(transactions[i]),
            ),
        ],
      ),
    );
  }

  Widget _noTransactions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          "No transactions yet.",
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🟡 Transaction Tile
  // --------------------------------------------------------------------------
  Widget _transactionTile(Map<String, dynamic> t) {
    bool isBonus = t["type"] == "bonus";

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _transactionIcon(isBonus),
          const SizedBox(width: 12),
          _transactionInfo(t),
          const Spacer(),
          _amountSection(t),
        ],
      ),
    );
  }

  Widget _transactionIcon(bool isBonus) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBonus
            ? Colors.blue.withOpacity(0.15)
            : planColor.withOpacity(0.20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isBonus ? Icons.card_giftcard : Icons.account_balance_wallet,
        color: isBonus ? Colors.blueAccent : planColor,
        size: 26,
      ),
    );
  }

  Widget _transactionInfo(Map<String, dynamic> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t["title"] ?? "",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t["date"] ?? "",
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _amountSection(Map<String, dynamic> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "+${t["gold"]} g",
          style: GoogleFonts.poppins(
            color: Colors.greenAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "₹${t["amount"]}",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
