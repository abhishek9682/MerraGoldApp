import 'package:flutter/material.dart';
import 'package:goldproject/compenent/snackbar.dart';
import 'package:provider/provider.dart';
import '../compenent/custom_style.dart';
import '../controllers/language_data_provider.dart';
import '../controllers/language_provider.dart';
import '../models/Language.dart';
import 'login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  LanguageData? selectedLanguage;
  // TokenStorage storeLang=TokenStorage();
  @override
  void initState() {
    super.initState();
    Provider.of<LanguageProvider>(context, listen: false).fetchLanguages();
    Provider.of<LanguageDataProvider>(context,listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final providerLang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                children: [
                  Text('Choose Your Language', style: AppTextStyles.heading),
                  const SizedBox(height: 8),
                  Text(
                    'Select your preferred language\nfor the best experience',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subHeading,
                  ),
                ],
              ),
            ),

            // Language Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: providerLang.languages.length,
                  itemBuilder: (context, index) {
                    final language = providerLang.languages[index];
                    final isSelected = selectedLanguage?.id == language.id;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedLanguage = language;
                        });

                        final langResponse=  Provider.of<LanguageDataProvider>(context,listen: false);
                        langResponse.getLanguageData(language.id.toString());

                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFD700).withOpacity(0.15)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF2A2A2A),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFFD700)
                                          .withOpacity(0.2)
                                          : const Color(0xFF2A2A2A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        language.shortName!.toUpperCase(),
                                        style: AppTextStyles.heading.copyWith(
                                          color: isSelected
                                              ? const Color(0xFFFFD700)
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    language.name!,
                                    style: AppTextStyles.subHeading.copyWith(
                                      color: isSelected
                                          ? const Color(0xFFFFD700)
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (isSelected)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Color(0xFF0A0A0A),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {

                    if(selectedLanguage!=null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                    else
                      {
                        GlobalSnackBar.showError("Please select language");
                      }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF0A0A0A),
                    elevation: 8,
                    shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text('CONTINUE', style: AppTextStyles.buttonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
