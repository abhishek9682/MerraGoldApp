import 'package:flutter/material.dart';
import 'package:goldproject/compenent/loader.dart';
import 'package:goldproject/screens/personal_details_screen.dart';
import 'package:goldproject/utils/token_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../compenent/custom_style.dart';
import '../controllers/Delete_Bank.dart';
import '../controllers/profile_details.dart';
import 'add_bank_account_screen.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  bool _loadingAction = false;

  // SET PRIMARY BANK ACCOUNT
  // -----------------------------

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBankData();
  }

  loadBankData()
  async {
    setState(() {
      _loadingAction=true;
    });
    final profileProvider=Provider.of<ProfileDetailsProvider>(context,listen: false);
    await profileProvider.fetchProfile();
    setState(() {
      _loadingAction=false;
    });
  }

  Future<void>  _setPrimary(ProfileDetailsProvider provider, int bankId) async {
    setState(() => _loadingAction = true);

    try {
      await provider.setPrimaryBank(bankId);      // ✅ FIXED
      loadBankData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Primary account updated', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loadingAction = false);
    }
  }

  Future<void> _removeAccount(
      ProfileDetailsProvider provider, int bankId, bool isPrimary) async {

    if (isPrimary) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Can't delete primary account."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(TokenStorage.translate("Remove"),
            style: GoogleFonts.poppins(color: Colors.white)),
        content: Text("Are you sure?",
            style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child:  Text(TokenStorage.translate("Remove")),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loadingAction = true);

    try {
      final deleteProvider =
      Provider.of<DeleteAccount>(context, listen: false);

      bool success = await deleteProvider.deleteById(bankId);

      if (success) {
        await provider.fetchProfile(); // refresh UI

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bank removed successfully",
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to remove bank")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loadingAction = false);
    }
  }


  Widget _buildBankCard(ProfileDetailsProvider provider, int index) {
    final profile = provider.profileData?.data?.profile;
    final banks = profile?.bankAccounts ?? [];
    final bank = banks[index];
    final isPrimary = bank.isPrimary == true;
    bool? isVarified=bank.isVerified;
    // print("!!! -------- $isVarified -- bank : ${bank.accountHolderName}");


    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? Colors.amber : Colors.white12,
        ),
        color: const Color(0xFF1A1A1A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW: NAME + EDIT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bank.bankName ?? "-",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              isVarified==false ?InkWell(
                  onTap: () async {
                    await provider.fetchProfile();   // 🔥 ensure latest bank data
                    final updatedBank = provider.bankAccounts[index]; // updated list

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddBankAccountScreen(bank: updatedBank),
                      ),
                    );
                  },
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.edit, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text("Edit", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ):SizedBox()
            ],
          ),

          const SizedBox(height: 8),

          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "PRIMARY ACCOUNT",
                style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 12),

          Text("Account Number", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
          Text(bank.accountNumber ?? "-", style: GoogleFonts.poppins(color: Colors.white70)),

          const SizedBox(height: 8),

          Text("IFSC Code", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
          Text(bank.ifscCode ?? "-", style: GoogleFonts.poppins(color: Colors.white70)),

          const SizedBox(height: 8),

          Text("Branch", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
          Text(bank.branchName ?? "-", style: GoogleFonts.poppins(color: Colors.white70)),

          const SizedBox(height: 20),
          if (!isPrimary)
          Row(
            children: [
              // SET PRIMARY
              Expanded(
                child: OutlinedButton(
                  onPressed: isPrimary ? null : () => _setPrimary(provider, bank.id!),
                  child: Text(
                    "Set Primary ",
                    style: TextStyle(
                      color: isPrimary ? Colors.white38 : Colors.amber,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // DELETE
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _removeAccount(provider, bank.id!, isPrimary),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: Text(TokenStorage.translate("Remove"), style: TextStyle(color: Colors.red)),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  // -----------------------------
  // MAIN BUILD
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileDetailsProvider>(context);
    final banks = provider.profileData?.data?.profile?.bankAccounts ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(TokenStorage.translate("Select Bank Currency"),style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),

      body:_loadingAction?Center(child: CustomLoader(),):ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (banks.isEmpty)
              Text("No bank accounts yet", style: GoogleFonts.poppins(color: Colors.white60))
            else
              ...List.generate(banks.length,
                      (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBankCard(provider, i),
                  )),

            const SizedBox(height: 20),

            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                 if( provider.profileData?.data?.profile?.kycStatus=="approved") {
                   Navigator.push(context,
                       MaterialPageRoute(
                           builder: (_) => const AddBankAccountScreen()));
                 }
                 else
                   {
                     Navigator.push(context,
                         MaterialPageRoute(
                             builder: (_) => const PersonalDetailsScreen()));
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF0A0A0A),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text("Add Bank Account", style: AppTextStyles.buttonText),
              ),
            ),
            SizedBox( height:10),
          ],
        ),
    );
  }
}
