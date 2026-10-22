import 'package:sixam_mart/features/auth/widgets/auth_ui_kit.dart';
import 'package:sixam_mart/features/auth/widgets/sign_up_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignUpScreen({super.key, this.exitFromApp = false});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: (ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyLarge!.color),
      ), elevation: 0, backgroundColor: Colors.transparent,
        actions: const [SizedBox()],
      ) : null),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: AuthLayout(
        title: 'Create your account',
        subtitle: 'Sign up to get started',
        hasAppBar: !widget.exitFromApp,
        wideMaxWidth: 700,
        wideHeader: false,
        child: const SignUpWidget(),
      ),
    );
  }
}
