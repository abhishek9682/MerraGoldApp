import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../compenent/custom_style.dart';
import '../controllers/help_center_controllar.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expandedItems = {};

  int _selectedNavIndex = 3;

  @override
  void initState() {
    super.initState();

    // 🔥 API CALL ON SCREEN OPEN
    Future.microtask(() {
      Provider.of<HelpCenterProvider>(context, listen: false)
          .fetchHelpCenter();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helpProvider = Provider.of<HelpCenterProvider>(context,listen: false);
    print("help center response--------->>> ${helpProvider.helpCenterResponse?.data}");
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Help Center',
            style: AppTextStyles.pageTitleHelp.copyWith(color: Colors.white)),
        centerTitle: true,
      ),

      body: helpProvider.isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      )
          : helpProvider.helpCenterResponse == null
          ? const Center(
        child: Text("Failed to load FAQ",
            style: TextStyle(color: Colors.white)),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBox(),
              const SizedBox(height: 24),
              ..._buildDynamicFAQ(helpProvider),
              const SizedBox(height: 24),
              _buildContactSupportCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ================= SEARCH BOX =================

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.inputText,
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Color(0xFFFFD700), size: 22),
          hintText: 'Search for help...',
          hintStyle: AppTextStyles.inputText.copyWith(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ============== DYNAMIC FAQ FROM API ==============

  List<Widget> _buildDynamicFAQ(HelpCenterProvider provider) {
    List<Widget> list = [];
    int index = 0;

    final data = provider.helpCenterResponse?.data;

    if (data == null) return [];

    list.add(_buildCategoryTitle(data.title ?? ""));
    list.add(const SizedBox(height: 16));

    for (var faq in data.faqs ?? []) {
      list.add(_buildFAQItem(index, faq.question ?? "", faq.answer ?? ""));
      list.add(const SizedBox(height: 12));
      index++;
    }
    return list;
  }

  Widget _buildCategoryTitle(String title) {
    return Text(title, style: AppTextStyles.categoryTitle.copyWith(color: Colors.white));
  }

  Widget _buildFAQItem(int index, String question, String answer) {
    final isExpanded = _expandedItems.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFFFFD700).withOpacity(0.3) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedItems.remove(index);
                } else {
                  _expandedItems.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: Text(question, style: AppTextStyles.faqQuestion.copyWith(color: Colors.white))),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: isExpanded ? 0.5 : 0,
                    child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFFD700), size: 24),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(answer, style: AppTextStyles.faqAnswer.copyWith(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUPPORT CARD =================

  Widget _buildContactSupportCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2A2A1A), Color(0xFF1A1A0A)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text('Still Need Help?', style: AppTextStyles.contactTitle.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Our support team is here 24/7 to assist you',
              textAlign: TextAlign.center,
              style: AppTextStyles.contactSubtitle.copyWith(color: Colors.white60)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactMethod(icon: Icons.chat_bubble_outline, label: 'Chat', onTap: () {}),
              _buildContactMethod(icon: Icons.email_outlined, label: 'Email', onTap: () {}),
              _buildContactMethod(icon: Icons.phone_outlined, label: 'Call', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFFFFD700), size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.contactMethodLabel.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  // ================= NAV BAR =================

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
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
            Text(label,
                style: AppTextStyles.navLabel.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFFFFD700) : Colors.white60)),
          ],
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    if (_selectedNavIndex == index && index == 3) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WalletScreen()),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
        break;

      case 3:
        if (Navigator.canPop(context)) Navigator.pop(context);
        break;
    }
  }
}
