import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../compenent/custom_style.dart';
import '../compenent/loader.dart';
import '../constants/constant.dart';
import '../controllers/otp_response.dart';
import '../utils/token_storage.dart';
import 'otp_verification_screen.dart';
import 'create_account_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _acceptedTerms = false;
  bool _isButtonEnabled = false;
  // String? translated;
  @override
  initState()  {
    super.initState();
    _phoneController.addListener(_validateForm);
     // translated =  await TokenStorage.translate("Phone Number");
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled = _phoneController.text.length == 10 && _acceptedTerms;
    });
  }

  void _sendOTP() async {
    final provider = Provider.of<OtpProvider>(context, listen: false);

    bool success = await provider.sendOtp(_phoneController.text.trim());

    if (success) {
      var data = provider.otpResponse!.data!;
      if(data.userExists==true) {
        print("varification =>>>>  ${ provider.otpResponse!.data!}");
        if (data.otpSent == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OTPVerificationScreen(
                    phoneNumber: _phoneController.text,
                    isNewUser: false,
                  ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateAccountScreen(
                    phoneNumber: _phoneController.text,
                  ),
            ),
          );
        }
      }
      else
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("User not found please Register first!"),
              backgroundColor: Colors.red,
            ),
          );
        }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.otpResponse?.data?.message ??
              "Failed to send OTP"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _navigateToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAccountScreen(phoneNumber: _phoneController.text,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final  otpProvider = Provider.of<OtpProvider>(context);
    print("translate------------ '${TokenStorage.translate("Phone Number")}");

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '💰',
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Welcome Back Title
                Text(
                  'Welcome Back',
                  style: AppTextStyles.heading
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Login to your account',
                  style: AppTextStyles.subHeading
                ),
                const SizedBox(height: 50),

                // Mobile Number Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TokenStorage.translate("Phone Number"),
                    style:AppTextStyles.subInputText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 1,
                    )
                  ),
                ),

                const SizedBox(height: 12),

                // Phone Input Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: TokenStorage.translate("Phone Number"),
                      hintStyle: AppTextStyles.inputText,
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.phone_android,
                              color: Color(0xFFFFD700),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+91',
                              style:  AppTextStyles.inputText.copyWith(
                               color: Colors.white,
                                fontWeight: FontWeight.w500,),
                            ),

                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Terms and Conditions Checkbox
                InkWell(
                  onTap: () {
                    setState(() {
                      _acceptedTerms = !_acceptedTerms;
                      _validateForm();
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _acceptedTerms
                              ? const Color(0xFFFFD700)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _acceptedTerms
                                ? const Color(0xFFFFD700)
                                : Colors.white30,
                            width: 2,
                          ),
                        ),
                        child: _acceptedTerms
                            ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Color(0xFF0A0A0A),
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            children: [
                              const TextSpan(text: 'I accept the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Send OTP Button

                otpProvider.isLoading
                    ? Center(child: CustomLoader())
                    : SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(themeColor)
            ),
            onPressed: _isButtonEnabled && !otpProvider.isLoading
                ? _sendOTP
                : null,
            child: Text(
              'Send OTP',
              style: AppTextStyles.buttonText
            ),
          ),
        ),


        const SizedBox(height: 30),

                // OR Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodyText
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Create Account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New user? ',
                      style: AppTextStyles.bodyText.copyWith(color: Colors.white60)
                    ),
                    InkWell(
                      onTap: _navigateToCreateAccount,
                      child: Text(
                        TokenStorage.translate("Create An Account"),
                        style: AppTextStyles.bodyText.copyWith(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w600,)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}