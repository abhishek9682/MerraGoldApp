import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:goldproject/utils/token_storage.dart';
import '../controllers/Term_condition.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  @override
  void initState() {
    super.initState();
    terms();
  }
   terms(){
     Provider.of<TermsConditionsProvider>(context, listen: false)
         .fetchTermsConditions();
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          TokenStorage.translate("Terms & Conditions"),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<TermsConditionsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final data = provider.termsData?.data;

          if (data == null) {
            return  Center(
              child: Text(
                TokenStorage.translate("No description available."),
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Last updated: ${data.lastUpdated}",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // Render HTML Content
                Html(
                  data: data.content,
                  style: {
                    "p": Style(color: Colors.white, fontSize: FontSize(14)),
                    "h1": Style(color: Colors.white),
                    "strong": Style(color: Colors.white),
                  },
                ),

                // const SizedBox(height: 30),

                // Center(
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: const Color(0xFFFFD700),
                //       foregroundColor: Colors.black,
                //       padding: const EdgeInsets.symmetric(
                //           vertical: 14, horizontal: 40),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //     onPressed: () => Navigator.pop(context),
                //     child: Text(
                //       "Accept & Continue",
                //       style: GoogleFonts.poppins(
                //           fontSize: 16, fontWeight: FontWeight.w600),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
