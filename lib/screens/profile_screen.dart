import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/language_data_provider.dart';
import '../controllers/language_provider.dart';
import '../controllers/profile_details.dart';
import '../controllers/update_profile.dart';
import '../models/Language.dart';
import '../utils/token_storage.dart';
import 'Terms and condition.dart';
import 'language_selection_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';
import 'personal_details_screen.dart';
import 'bank_accounts_screen.dart';
import 'nominee_list_screen.dart';
import 'security_screen.dart';
import 'help_center_screen.dart';
import 'refer_earn_screen.dart';
import 'Privacy_Policy_screen.dart';
import '../compenent/custom_style.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedNavIndex = 3; // Profile is selected
  LanguageData? selectedLanguage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<ProfileDetailsProvider>(context,listen: false).fetchProfile();
    checkLanguage();
  }

  checkLanguage()
  async{
    final provider=Provider.of<LanguageProvider>(context, listen: false);
    await provider.fetchLanguages();
    String? lang=await TokenStorage.getLan();
    if(lang!=null)
    {
      int index=provider.languages.indexWhere((e)=>e.id.toString()==lang);
      setState(() {
        selectedLanguage=provider.languages[index];

      });
    }

  }


  void _onNavItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
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
    } else {
      setState(() {
        _selectedNavIndex = index;
      });
    }
  }

  void _showLanguageSelector() {
    final provider=Provider.of<ProfileDetailsProvider>(context,listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
    );
    // showModalBottomSheet(
    //   context: context,
    //   backgroundColor: const Color(0xFF1A1A1A),
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    //   ),
    //   builder: (context) {
    //     return Padding(
    //       padding: const EdgeInsets.all(24.0),
    //       child: Consumer<ProfileDetailsProvider>(builder: (context, provider, _) {
    //         return Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Center(
    //               child: Container(
    //                 width: 40,
    //                 height: 4,
    //                 decoration: BoxDecoration(
    //                   color: Colors.white30,
    //                   borderRadius: BorderRadius.circular(2),
    //                 ),
    //               ),
    //             ),
    //             const SizedBox(height: 24),
    //             Text("Select Language", style: AppTextStyles.heading),
    //             const SizedBox(height: 24),
    //
    //             ListView.builder(
    //               shrinkWrap: true,
    //               physics: const NeverScrollableScrollPhysics(),
    //               itemCount: provider.profileData?.data?.languages?.length ?? 0,
    //               itemBuilder: (context, index) {
    //                 final lang = provider.profileData!.data!.languages![index];
    //
    //                 bool isSelected =
    //                     provider.selectedLanguage == lang.name;
    //
    //
    //                 return _buildLanguageOption(
    //                   lang.name ??'',
    //                   lang.flag ??'',
    //                   isSelected,
    //                   onTap: () {
    //                     provider.setSelectedLanguage(lang.name ??'');
    //
    //                     Navigator.pop(context);
    //
    //                     ScaffoldMessenger.of(context).showSnackBar(
    //                       SnackBar(
    //                         content:
    //                         Text("Language changed to ${lang.name}"),
    //                         backgroundColor: Colors.green,
    //                       ),
    //                     );
    //                   },
    //                 );
    //               },
    //             ),
    //           ],
    //         );
    //       }),
    //     );
    //   },
    // );
  }

  Widget _buildLanguageOption(
      String language,
      String flag,
      bool isSelected, {
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.1)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: flag.isNotEmpty
                  ? NetworkImage(flag)
                  : const AssetImage("assets/images/user.png")
              as ImageProvider,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: AppTextStyles.subHeading.copyWith(
                  color: Colors.white,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFFFFD700), size: 24),
          ],
        ),
      ),
    );
  }


  // void _showLogoutDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: const Color(0xFF1A1A1A),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Text('Logout', style: AppTextStyles.heading),
  //       content: Text('Are you sure you want to logout?', style: AppTextStyles.bodyText),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(TokenStorage.translate("Cancel"), style: AppTextStyles.subHeading.copyWith(color: Colors.white60)),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Logged out successfully')),
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFFFFD700),
  //             foregroundColor: const Color(0xFF0A0A0A),
  //           ),
  //           child: Text('Logout', style: AppTextStyles.buttonText),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildAccountSection(),
                  const SizedBox(height: 24),
                  _buildPreferencesSection(),
                  const SizedBox(height: 24),
                  _buildSupportSection(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
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

  Future<void> _pickAndUploadProfileImage() async {
    final profileProvider = Provider.of<ProfileDetailsProvider>(context, listen: false);
    final updateProvider = Provider.of<UpdateProfiles>(context, listen: false);

    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uploading profile image...")),
    );

    // Prepare fields and files for upload API
    Map<String, String> fields = {};
    Map<String, File> files = {"image": file};

    await updateProvider.updateProfile(fields, files);

    // Check response
    if (updateProvider.updateResponse != null &&
        updateProvider.updateResponse!.status == "success") {

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(TokenStorage.translate("Profile image updated successfully!"))),
      );

      // 🔥 Refresh profile to show new image in header
      await profileProvider.fetchProfile();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(TokenStorage.translate("Upload failed! Try again"))),
      );
    }
  }

  Widget _buildProfileHeader() {
    final provider = Provider.of<ProfileDetailsProvider>(context);
    final profile = provider.profileData?.data?.profile;

    final imageUrl = profile?.image;
    final kycStatus = profile?.kycStatus?.toLowerCase();
    bool kycMess=profile?.kycStatus=="approved";
    Color color;
    if(kycStatus=="approved"){
     color=Colors.green;
    }
    else if(kycStatus=="pending"){
         color=Colors.orange;
    }
    else{
      color=Colors.red;
    }

    final isKycLocked = kycStatus == "approved" || kycStatus == "completed";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withOpacity(0.2),
            const Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (isKycLocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text(TokenStorage.translate("You cannot change profile image after completing KYC.")),
                  ),
                );
              } else {
                _pickAndUploadProfileImage();
              }
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                  ? NetworkImage(imageUrl)
                  : const AssetImage("assets/images/user.png") as ImageProvider,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            profile?.firstname ?? "User",
            style: AppTextStyles.heading,
          ),

          const SizedBox(height: 4),

          Text(
            profile?.email ?? "",
            style: AppTextStyles.subHeading.copyWith(color: Colors.white60),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?kycMess?const Icon(Icons.verified, color: Colors.white, size: 16):null,
                const SizedBox(width: 6),
                Text(
                  profile?.kycStatusMessage ?? "",
                  style: AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAccountSection() {
    final providerbank=Provider.of<ProfileDetailsProvider>(context,listen: false);
    int? bankCount=providerbank.profileData?.data?.profile?.bankAccounts?.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TokenStorage.translate("Create Account"), style: AppTextStyles.subHeading.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildListItem(
                  icon: Icons.person_outline,
                  title: TokenStorage.translate("Profile Details"),
                  subtitle: TokenStorage.translate( "Update Info"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()));
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.account_balance,
                  title: TokenStorage.translate("Add Bank Account"),
                  subtitle: '$bankCount accounts linked',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BankAccountsScreen()));
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.people_outline,
                  title: TokenStorage.translate("Add Nominee"),
                  subtitle: 'Manage nominees',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NomineeListScreen()));
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.card_giftcard,
                  title: TokenStorage.translate("Refer & Earn"),
                  subtitle: "${TokenStorage.translate("Share & Invite Friends")} (₹100)",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferEarnScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final provider=Provider.of<ProfileDetailsProvider>(context,listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TokenStorage.translate("Preferences"), style: AppTextStyles.subHeading.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildListItem(
                  icon: Icons.notifications_outlined,
                  title: TokenStorage.translate("notification"),
                  subtitle: TokenStorage.translate("Managealerts"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.lock_outline,
                  title: TokenStorage.translate("Security"),
                  subtitle: TokenStorage.translate('Biometric login'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen()));
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.language,
                  title:TokenStorage.translate("Language"),
                  subtitle: '${selectedLanguage?.name}',
                  onTap: _showLanguageSelector,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TokenStorage.translate("Getsupport"), style: AppTextStyles.subHeading.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildListItem(
                  icon: Icons.help_outline,
                  title: TokenStorage.translate("HelpCenter"),
                  subtitle: TokenStorage.translate("Terms & Conditions"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.description_outlined,
                  title: TokenStorage.translate("Privacy Policy"),
                  subtitle: TokenStorage.translate("Readourterms"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                  },
                ),
                // _buildListItem(
                //   icon: Icons.description_outlined,
                //   title: TokenStorage.translate("Terms & Conditions"),
                //   subtitle: TokenStorage.translate("Readourterms"),
                //   onTap: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen()));
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFFD700), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subHeading.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyText.copyWith(fontSize: 13, color: Colors.white60)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(color: Colors.white.withOpacity(0.05), height: 1);

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: () async {
            await TokenStorage.removeToken(); // remove token

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // clear all routes
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                TokenStorage.translate("Logout"),
                style: AppTextStyles.buttonText
                    .copyWith(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
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
              _buildNavItem(1, Icons.account_balance_wallet, TokenStorage.translate("Wallet")),
              _buildNavItem(2, Icons.history, TokenStorage.translate("History")),
              _buildNavItem(3, Icons.person, TokenStorage.translate("Profile")),
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
          Text(label, style: AppTextStyles.subHeading.copyWith(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? const Color(0xFFFFD700) : Colors.white60)),
        ],
      ),
    );
  }
}
