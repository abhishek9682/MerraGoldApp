class Language_Data{
  String? status;
  Data? data;

  Language_Data.fromJson(Map<String,dynamic> json){
    status=json["status"];
    data=json["data"]!=null?Data.fromJson(json["data"]):null;
  }
}

class Data {
  String? recoverPassword;
  String? regainAccess;
  String? emailAddress;
  String? sendLink;
  String? resetPassword;
  String? password;
  String? confirmPassword;
  String? twoFACode;
  String? code;
  String? submit;
  String? verifyYourEmail;
  String? yourEmailAddressIs;
  String? didntGetCode;
  String? resendCode;
  String? smsVerification;
  String? emailVerification;
  String? verifyYourMobileNumber;
  String? yourMobileNumberIs;
  String? doNotHaveAnAccount;
  String? signUp;
  String? enterUsernameOrEmail;
  String? enterCaptcha;
  String? rememberMe;
  String? forgetPassword;
  String? signIn;
  String? or;
  String? referBy;
  String? firstName;
  String? lastName;
  String? enterYourEmail;
  String? email;
  String? username;
  String? enterYourUsername;
  String? phoneNumber;
  String? createAccount;
  String? verifyEmailAddress;
  String? freshVerificationLinkSent;
  String? checkEmailBeforeProceed;
  String? ifNoEmailReceived;
  String? clickHereToRequestAnother;
  String? goToTop;
  String? enterSearchKeyword;
  String? search;
  String? result;
  String? clearAll;
  String? userImage;
  String? accountSettings;
  String? twoFASecurity;
  String? verificationCenter;
  String? signOut;
  String? copyright;
  String? allRightsReserved;

  Data({
    this.recoverPassword,
    this.regainAccess,
    this.emailAddress,
    this.sendLink,
    this.resetPassword,
    this.password,
    this.confirmPassword,
    this.twoFACode,
    this.code,
    this.submit,
    this.verifyYourEmail,
    this.yourEmailAddressIs,
    this.didntGetCode,
    this.resendCode,
    this.smsVerification,
    this.emailVerification,
    this.verifyYourMobileNumber,
    this.yourMobileNumberIs,
    this.doNotHaveAnAccount,
    this.signUp,
    this.enterUsernameOrEmail,
    this.enterCaptcha,
    this.rememberMe,
    this.forgetPassword,
    this.signIn,
    this.or,
    this.referBy,
    this.firstName,
    this.lastName,
    this.enterYourEmail,
    this.email,
    this.username,
    this.enterYourUsername,
    this.phoneNumber,
    this.createAccount,
    this.verifyEmailAddress,
    this.freshVerificationLinkSent,
    this.checkEmailBeforeProceed,
    this.ifNoEmailReceived,
    this.clickHereToRequestAnother,
    this.goToTop,
    this.enterSearchKeyword,
    this.search,
    this.result,
    this.clearAll,
    this.userImage,
    this.accountSettings,
    this.twoFASecurity,
    this.verificationCenter,
    this.signOut,
    this.copyright,
    this.allRightsReserved,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      recoverPassword: json['recover Password'],
      regainAccess: json['regainAccess'],
      emailAddress: json['emailAddress'],
      sendLink: json['sendLink'],
      resetPassword: json['resetPassword'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
      twoFACode: json['twoFACode'],
      code: json['code'],
      submit: json['submit'],
      verifyYourEmail: json['verifyYourEmail'],
      yourEmailAddressIs: json['yourEmailAddressIs'],
      didntGetCode: json['didntGetCode'],
      resendCode: json['resendCode'],
      smsVerification: json['smsVerification'],
      emailVerification: json['emailVerification'],
      verifyYourMobileNumber: json['verifyYourMobileNumber'],
      yourMobileNumberIs: json['yourMobileNumberIs'],
      doNotHaveAnAccount: json['doNotHaveAnAccount'],
      signUp: json['signUp'],
      enterUsernameOrEmail: json['enterUsernameOrEmail'],
      enterCaptcha: json['enterCaptcha'],
      rememberMe: json['rememberMe'],
      forgetPassword: json['forgetPassword'],
      signIn: json['signIn'],
      or: json['or'],
      referBy: json['referBy'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      enterYourEmail: json['enterYourEmail'],
      email: json['email'],
      username: json['username'],
      enterYourUsername: json['enterYourUsername'],
      phoneNumber: json['phoneNumber'],
      createAccount: json['createAccount'],
      verifyEmailAddress: json['verifyEmailAddress'],
      freshVerificationLinkSent: json['freshVerificationLinkSent'],
      checkEmailBeforeProceed: json['checkEmailBeforeProceed'],
      ifNoEmailReceived: json['ifNoEmailReceived'],
      clickHereToRequestAnother: json['clickHereToRequestAnother'],
      goToTop: json['goToTop'],
      enterSearchKeyword: json['enterSearchKeyword'],
      search: json['search'],
      result: json['result'],
      clearAll: json['clearAll'],
      userImage: json['userImage'],
      accountSettings: json['accountSettings'],
      twoFASecurity: json['twoFASecurity'],
      verificationCenter: json['verificationCenter'],
      signOut: json['signOut'],
      copyright: json['copyright'],
      allRightsReserved: json['allRightsReserved'],
    );
  }
}