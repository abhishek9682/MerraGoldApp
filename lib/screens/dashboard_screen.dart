import 'package:flutter/material.dart';
import 'package:goldproject/compenent/loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/InvestmentPlansProvider.dart';
import '../controllers/profile_details.dart';
import '../models/investment_plans.dart';
import '../utils/token_storage.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'rewards_screen.dart';
import 'nearby_vendors_screen.dart';
import 'all_plans_screen.dart';
import 'plan_detail_screen.dart';
import 'notifications_screen.dart';
import 'buy_gold_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _selectedAmount = 1;
  String amount="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }


  final List<int> _amountOptions = [100, 500, 1000, 2000, 5000, 10000];
  List<Map<String, String>> _investmentAmounts = [];

  Future<void> loadData() async {
    final profileProvider = Provider.of<ProfileDetailsProvider>(context, listen: false);
    final plansProvider = Provider.of<InvestmentPlansProvider>(context, listen: false);

    plansProvider.updateLoading(true);

    await profileProvider.fetchProfile();
    await plansProvider.getInvestmentPlans();

    // Get gold rate per gram (₹ per gram)
    final goldRatePerGramString =
        profileProvider.profileData?.data?.profile?.currentGoldPricePerGram ?? '0';

    final double goldRatePerGram = double.tryParse(goldRatePerGramString) ?? 0;

    if (goldRatePerGram == 0) {
      // Avoid division by zero
      setState(() {
        _investmentAmounts = _amountOptions.map((amt) {
          return {
            'amount': '₹$amt',
            'gold': '--', // or '0.000g'
          };
        }).toList();
      });
    } else {
      setState(() {
        _investmentAmounts = _amountOptions.map((amt) {
          final double goldInGrams = amt / goldRatePerGram; // grams = amount / ratePerGram
          return {
            'amount': '₹$amt',
            'gold': '${goldInGrams.toStringAsFixed(3)}g',
          };
        }).toList();
      });
    }

    plansProvider.updateLoading(false);
  }
  
  final List<String> _purchasedPlans = [
    'Gold Plan',
  ]; // Sample - you can load from SharedPreferences

  void _onNavItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalletScreen()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  ProfileScreen()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';

  }

  void addPurchasedPlan(String planTitle) {
    setState(() {
      if (!_purchasedPlans.contains(planTitle)) {
        _purchasedPlans.add(planTitle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileDetailsProvider>(context);
    final plansProvider = Provider.of<InvestmentPlansProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: plansProvider.isLoading?Center(child: CustomLoader(),):RefreshIndicator(

        onRefresh: (){
          return loadData();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildGoldRateCard(),
                      const SizedBox(height: 20),
                      _buildPortfolioCard(),
                      const SizedBox(height: 24),
                      _buildQuickInvest(),
                      const SizedBox(height: 24),
                      _buildExploreSection(),
                      const SizedBox(height: 24),
                      _buildInvestmentPlans(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
   final provider= Provider.of<ProfileDetailsProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.profileData?.data?.profile?.firstname}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFFFFD700),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoldRateCard() {
    final provider= Provider.of<ProfileDetailsProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A1A), Color(0xFF1A1A0A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Today's Gold Rate",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${provider.profileData?.data?.profile?.currentGoldPricePerGram}",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    Text(
                      ' /gram',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    final provider=Provider.of<ProfileDetailsProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TokenStorage.translate("Wallet Balance" ),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A0A0A),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${provider.profileData?.data?.profile?.goldBalanceValue}",
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gold Owned',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF0A0A0A).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${provider.profileData?.data?.profile?.goldBalance}",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A0A0A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInvest() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A1A), Color(0xFF1A1A0A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Invest',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Custom →',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_investmentAmounts.length, (index) {
              final isSelected = _selectedAmount == index;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedAmount = index;
                    amount=_investmentAmounts[_selectedAmount]['amount']!;
                    amount = amount.replaceAll("₹", "").trim();
                  });

                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 88) / 3,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _investmentAmounts[index]['amount']!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF0A0A0A)
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _investmentAmounts[index]['gold']!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFF0A0A0A).withOpacity(0.7)
                              : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                print("-----------  $amount");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  BuyGoldScreen(amount: amount),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0A0A0A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Buy Gold Now',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Explore',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildExploreCard(
                  icon: '🏆',
                  title: 'Rewards',
                  subtitle: 'Earn cashback',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RewardsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildExploreCard(
                  icon: '🏪',
                  title: 'Nearby Vendors',
                  subtitle: 'Find partner stores',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NearbyVendorsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExploreCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentPlans() {
    final plansProvider = Provider.of<InvestmentPlansProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TokenStorage.translate("Investment Plan"),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllPlansScreen(
                        purchasedPlans: _purchasedPlans,
                        onPlanPurchased: addPurchasedPlan,
                      ),
                    ),
                  );
                },
                child: Text(
                  TokenStorage.translate("View all"),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 🔄 LOADING
        if (plansProvider.isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          ),

        // ❌ ERROR
        if (plansProvider.error != null)
          Text(
            plansProvider.error!,
            style: const TextStyle(color: Colors.redAccent),
          ),

        // 📌 SHOW PLANS
        if (!plansProvider.isLoading && plansProvider.plans.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 250, // OR dynamically computed as per card content
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: plansProvider.plans.length >= 3
                      ? 3
                      : plansProvider.plans.length,
                  itemBuilder: (_, index) => Row(
                    children: [
                      _buildPlanCard(plansProvider.plans[index]),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              );
            },
          )
      ],
    );
  }


  Widget _buildPlanCard(Plan plan) {
    final isPurchased = _purchasedPlans.contains(plan.name);
    // final badge = plan.isSubscribed ? "Active" : (plan.isSubscribed ? "Featured" : null);
    String? badge = plan.userSubscriptionStatus;
    final badgeColor = isPurchased ? Colors.green :  Color(0xFFFFD700);
    return GestureDetector(
      onTap: () {
        print("name __---- -- ${plan.isSubscribed}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlanDetailScreen(
              plan: plan
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badgeColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                plan.imageUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // TITLE
            Text(
              plan.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 4),

            // AMOUNT
            Text(
              plan.formattedAmount,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),
            ...plan.features.map(
                  (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "✓$feature",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ),
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
              _buildNavItem(0, Icons.home, TokenStorage.translate("Home")),
              _buildNavItem(1, Icons.account_balance_wallet, 'Wallet'),
              _buildNavItem(2, Icons.history, 'History'),
              _buildNavItem(3, Icons.person, TokenStorage.translate("Profile")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onNavItemTapped(index),
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
    );
  }
}