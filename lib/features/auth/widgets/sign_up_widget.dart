import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/auth/widgets/condition_check_box_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/verification/screens/verification_screen.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeySignUp;

  @override
  void initState() {
    super.initState();
    _formKeySignUp = GlobalKey<FormState>();
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

    // UI-only bridge: keep confirm password in sync with password so the
    // existing validation logic still passes when the field is hidden
    // (matches the simplified 4-field Sign Up screen in the design).
    _passwordController.addListener(() {
      if (!mounted) return;
      if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordController.text = _passwordController.text;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referCodeController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _referCodeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Form(
      key: _formKeySignUp,
      child: Container(
        width: context.width > 700 ? 700 : context.width,
        decoration: context.width > 700 ? BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ) : null,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeDefault : 0),
        child: GetBuilder<AuthController>(builder: (authController) {
          return Column(mainAxisSize: MainAxisSize.min, children: [

            isDesktop ? Align(
              alignment: Alignment.topRight,
              child: IconButton(onPressed: ()=> Get.back(), icon: const Icon(Icons.clear)),
            ) : const SizedBox(),

            Padding(
              padding: EdgeInsets.all(isDesktop ? Dimensions.paddingSizeExtraLarge : 0),
              child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [

                isDesktop ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                  child: Image.asset(Images.logo, width: 125),
                ) : const SizedBox(),

                isDesktop ? Align(
                  alignment: Alignment.topLeft,
                  child: Text('sign_up'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                ) : const SizedBox(),

                SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeSmall),

                // === User Name ===
                CustomTextField(
                  titleText: 'ex_jhon'.tr,
                  labelText: 'User Name',
                  showLabelText: true,
                  required: true,
                  controller: _nameController,
                  focusNode: _nameFocus,
                  nextFocus: _phoneFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  prefixIcon: CupertinoIcons.person_alt_circle_fill,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_your_name".tr),
                ),
                SizedBox(height: Dimensions.paddingSizeLarge),

                // === Phone ===
                CustomTextField(
                  titleText: 'xxx-xxx-xxxxx'.tr,
                  labelText: 'Phone',
                  showLabelText: true,
                  required: true,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocus: _emailFocus,
                  inputType: TextInputType.phone,
                  isPhone: true,
                  onCountryChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                  },
                  countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                      : Get.find<LocalizationController>().locale.countryCode,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
                ),
                SizedBox(height: Dimensions.paddingSizeLarge),

                // === E-mail ===
                CustomTextField(
                  labelText: 'E-mail',
                  titleText: 'enter_email'.tr,
                  showLabelText: true,
                  required: true,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocus: _passwordFocus,
                  inputType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail_solid,
                  validator: (value) => ValidateCheck.validateEmail(value),
                  divider: false,
                ),
                SizedBox(height: Dimensions.paddingSizeLarge),

                // === Password (with eye toggle, matches screenshot) ===
                CustomTextField(
                  titleText: '8+characters'.tr,
                  labelText: 'Password',
                  showLabelText: true,
                  required: true,
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.visiblePassword,
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
                ),

                // Confirm password is intentionally hidden in this design
                // (matches the 4-field screenshot). The controller is kept
                // in sync with password above so the existing validation
                // in _prepareSignUpBody continues to pass.
                SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Terms checkbox is hidden visually because acceptTerms
                // defaults to true; the existing logic is unchanged.
                const SizedBox(height: 0),

                CustomButton(
                  height: isDesktop ? 50 : null,
                  width:  isDesktop ? 250 : null,
                  radius: isDesktop ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                  isBold: !isDesktop,
                  fontSize: isDesktop ? Dimensions.fontSizeSmall : null,
                  buttonText: 'Sign Up',
                  isLoading: authController.isLoading,
                  onPressed: authController.acceptTerms ? () => _register(authController, _countryDialCode!) : null,
                ),
                SizedBox(height: isDesktop ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('already_have_account'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                    InkWell(
                      onTap: authController.isLoading ? null : () {
                        if(isDesktop){
                          Get.back();
                          Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: false, backFromThis: false)));

                        }else{
                          if(Get.currentRoute == RouteHelper.signUp) {
                            Get.back();
                          } else {
                            Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        child: Text('Sign In', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  ]),
                ),

              ]),
            ),
          ]);
        }),
      ),
    );
  }

  void _register(AuthController authController, String countryCode) async {

    SignUpBodyModel? signUpModel = await _prepareSignUpBody(countryCode);

    if(signUpModel == null) {
      return;
    } else {
      authController.registration(signUpModel).then((status) async {
        _handleResponse(status, countryCode);
      });
    }
  }

  void _handleResponse(ResponseModel status, String countryCode) {
    String password = _passwordController.text.trim();
    String numberWithCountryCode = countryCode + _phoneController.text.trim();
    String email = _emailController.text.trim();

    if (status.isSuccess) {
      if(ResponsiveHelper.isDesktop(context)) {
        Get.find<CartController>().getCartDataOnline();
      }
      if(status.authResponseModel != null && !status.authResponseModel!.isPhoneVerified!) {
        List<int> encoded = utf8.encode(password);
        String data = base64Encode(encoded);
        if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
          Get.find<AuthController>().firebaseVerifyPhoneNumber(numberWithCountryCode, status.message, CentralizeLoginType.manual.name, fromSignUp: true);
        } else {
          if(ResponsiveHelper.isDesktop(context)) {
            Get.back();
            Get.dialog(VerificationScreen(
              number: numberWithCountryCode, email: null, token: status.message, fromSignUp: true,
              fromForgetPassword: false, loginType: CentralizeLoginType.manual.name, password: password,
            ));
          } else {
            Get.toNamed(RouteHelper.getVerificationRoute(
              numberWithCountryCode, null, status.message, RouteHelper.signUp, data, CentralizeLoginType.manual.name,
            ));
          }
        }
      } else if(status.authResponseModel != null && !status.authResponseModel!.isEmailVerified!) {
        List<int> encoded = utf8.encode(password);
        String data = base64Encode(encoded);
        if(ResponsiveHelper.isDesktop(context)) {
          Get.back();
          Get.dialog(VerificationScreen(
            number: null, email: email, token: status.message, fromSignUp: true,
            fromForgetPassword: false, loginType: CentralizeLoginType.manual.name, password: password,
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(
            null, email, status.message, RouteHelper.signUp, data, CentralizeLoginType.manual.name,
          ));
        }
      } else {
        Get.find<ProfileController>().getUserInfo();
        Get.find<LocationController>().navigateToLocationScreen(RouteHelper.signUp);
        if(ResponsiveHelper.isDesktop(context)) {
          Get.back();
        }
      }
    } else {
      showCustomSnackBar(status.message);
    }
  }

  Future<SignUpBodyModel?> _prepareSignUpBody(String countryCode) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String number = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String referCode = _referCodeController.text.trim();

    String numberWithCountryCode = countryCode + number;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeySignUp!.currentState!.validate()) {
      if (name.isEmpty) {
        showCustomSnackBar('please_enter_your_name'.tr);
      } else if (email.isEmpty) {
        showCustomSnackBar('enter_email_address'.tr);
      } else if (!GetUtils.isEmail(email)) {
        showCustomSnackBar('enter_a_valid_email_address'.tr);
      } else if (number.isEmpty) {
        showCustomSnackBar('enter_phone_number'.tr);
      } else if (!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else if (password.isEmpty) {
        showCustomSnackBar('enter_password'.tr);
      } else if (password.length < 8) {
        showCustomSnackBar('password_should_be_8_characters'.tr);
      } else if (password != confirmPassword) {
        showCustomSnackBar('confirm_password_does_not_matched'.tr);
      } else if (referCode.isNotEmpty && referCode.length != 10) {
        showCustomSnackBar('invalid_refer_code'.tr);
      } else {
        SignUpBodyModel signUpBody = SignUpBodyModel(
          name: name,
          email: email,
          phone: numberWithCountryCode,
          password: password,
          refCode: referCode,
        );
        return signUpBody;
      }
    }
    return null;
  }
}
