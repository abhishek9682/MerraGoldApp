import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:goldproject/utils/token_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/condition_policy.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  int _selectedNavIndex = 3;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PrivacyPolicyProvider>(context, listen: false)
          .fetchPrivacyPolicy();
    });
  }

  // void _onNavItemTapped(int index) {
  //   if (index == _selectedNavIndex && index != 3) return;
  //
  //   switch (index) {
  //     case 0:
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => const DashboardScreen()),
  //             (_) => false,
  //       );
  //       break;
  //     case 1:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const WalletScreen()),
  //       );
  //       break;
  //     case 2:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HistoryScreen()),
  //       );
  //       break;
  //     case 3:
  //       if (Navigator.canPop(context)) Navigator.pop(context);
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrivacyPolicyProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          TokenStorage.translate("Terms & Conditions"),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      )
          : provider.privacyPolicyResponse == null
          ? Center(
        child: Text(
          TokenStorage.translate("Terms & Conditions"),
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      )
          : _buildContent(provider),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent(PrivacyPolicyProvider provider) {
    final data = provider.privacyPolicyResponse!.data;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last Updated
          Row(
            children: [
              Text(
                'Last Updated: ',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              Text(
                data?.lastUpdated ?? "-",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            data?.title ?? "",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          /// RENDER HTML HERE
          Html(
            data: data?.content ?? "",
            style: {
              "body": Style(
                color: Colors.white70,
                fontSize: FontSize(15),
                lineHeight: const LineHeight(1.6),
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              "h1": Style(color: Color(0xFFFFD700)),
              "h2": Style(color: Color(0xFFFFD700)),
              "strong": Style(color: Colors.white),
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget _buildBottomNav() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF1A1A1A),
  //       border: Border(
  //         top: BorderSide(color: Colors.white.withOpacity(0.1)),
  //       ),
  //     ),
  //     child: SafeArea(
  //       child: SizedBox(
  //         height: 60,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             _buildNavItem(0, Icons.home, TokenStorage.translate("Home")),
  //             _buildNavItem(1, Icons.account_balance_wallet, "Wallet"),
  //             _buildNavItem(2, Icons.history, "History"),
  //             _buildNavItem(3, Icons.person, TokenStorage.translate("Profile")),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildNavItem(int index, IconData icon, String label) {
  //   final isSelected = _selectedNavIndex == index;
  //
  //   return InkWell(
  //     onTap: () => _onNavItemTapped(index),
  //     borderRadius: BorderRadius.circular(12),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(
  //             icon,
  //             size: 24,
  //             color: isSelected ? const Color(0xFFFFD700) : Colors.white60,
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             label,
  //             style: GoogleFonts.poppins(
  //               fontSize: 11,
  //               fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  //               color: isSelected ? const Color(0xFFFFD700) : Colors.white60,
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
