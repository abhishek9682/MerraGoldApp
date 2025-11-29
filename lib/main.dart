import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:goldproject/screens/language_selection_screen.dart';
import 'package:provider/provider.dart';

import 'controllers/Delete_Bank.dart';
import 'controllers/InvestmentPlansProvider.dart';
import 'controllers/add_bank_account.dart';
import 'controllers/add_new_nominee.dart';
import 'controllers/buy_gold.dart';
import 'controllers/condition_policy.dart';
import 'controllers/enroll_investment.dart';
import 'controllers/gold_data.dart';
import 'controllers/help_center_controllar.dart';
import 'controllers/language_provider.dart';
import 'controllers/notifiacation_provier.dart';
import 'controllers/otp_response.dart';
import 'controllers/profile_details.dart';
import 'controllers/sell_gold.dart';
import 'controllers/submit_kyc.dart';
import 'controllers/transaction_list.dart';
import 'controllers/update_profile.dart';
import 'controllers/user_registration.dart';
import 'controllers/varify_otp.dart';
import 'controllers/venders.dart';

import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => OtpVarification()),
        ChangeNotifierProvider(create: (_) => CompleteProfileProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ProfileDetailsProvider()),
        ChangeNotifierProvider(create: (_) => BankAccountProvider()),
        ChangeNotifierProvider(create: (_) => UpdateProfiles()),
        ChangeNotifierProvider(create: (_) => NomineeProfileProvider()),
        ChangeNotifierProvider(create: (_) => SubmitKycProvider()),
        ChangeNotifierProvider(create: (_) => GoldDetails()),
        ChangeNotifierProvider(create: (_) => GoldSellProvider()),
        ChangeNotifierProvider(create: (_) => InvestmentPlansProvider()),
        ChangeNotifierProvider(create: (_) => EnrollInvestmentProvider()),
        ChangeNotifierProvider(create: (_) => DeleteAccount()),
        ChangeNotifierProvider(create: (_) => BuyGold()),
        ChangeNotifierProvider(create: (_) => HelpCenterProvider()),
        ChangeNotifierProvider(create: (_) => PrivacyPolicyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => MerchantProvider()),
      ],
      child: const MeeraGoldApp(),
    ),
  );
}
class MeeraGoldApp extends StatelessWidget {
  const MeeraGoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(lang.currentLanguage), // dynamic locale

      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('ar'),
        Locale('fr'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: LanguageSelectionScreen(isSelectedLang: ""),
    );
  }
}