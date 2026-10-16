import 'dart:async';
import 'dart:io';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromNotification;
  final bool fromResetPassword;
  const SignInScreen({super.key, required this.exitFromApp, required this.backFromThis, this.fromNotification = false, this.fromResetPassword = false});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromNotification || widget.fromResetPassword) {
          Navigator.pushNamed(context, RouteHelper.getInitialRoute());
        } else if(widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          if(Get.find<AuthController>().isOtpViewEnable){
            Get.find<AuthController>().enableOtpView(enable: false);
          }else{
            Get.back();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: (ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(leading: IconButton(
            onPressed: () {
              if(widget.fromNotification || widget.fromResetPassword) {
                Navigator.pushNamed(context, RouteHelper.getInitialRoute());
              }else if(Get.find<AuthController>().isOtpViewEnable){
                Get.find<AuthController>().enableOtpView(enable: false);
              }else{
                Get.back(result: false);
              }
            },
            icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
          elevation: 0, backgroundColor: Colors.transparent, actions: const [SizedBox()],
        ) : null),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,

        body: Container(
          width: context.width,
          height: context.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8F5E9), // Light green background to match the welcome screen
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: context.width > 700 ? 500 : context.width,
                padding: context.width > 700 ? const EdgeInsets.all(50) : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                margin: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
                decoration: context.width > 700 ? BoxDecoration(
                  color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 1)],
                ) : null,
                child: SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    
                    if (ResponsiveHelper.isDesktop(context)) Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.clear),
                      ),
                    ),

                    // Modern Header
                    Image.asset(Images.logo, width: 80),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    
                    Text('WELCOME BACK!', style: robotoBold.copyWith(fontSize: 28, color: Theme.of(context).primaryColor)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    
                    Text(
                      'LOGIN TO YOUR ACCOUNT',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                    // The dynamic sign-in view containing manual/otp/social logins
                    SignInView(
                      exitFromApp: widget.exitFromApp,
                      backFromThis: widget.backFromThis,
                      fromResetPassword: widget.fromResetPassword,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
