import 'package:flutter/services.dart';
import 'package:messager/Controller/Apis/apis.dart';
import 'package:messager/Controller/Routes/routes_method.dart';
import 'package:messager/Export/export_file.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SplashScreen> {
  /// User (Object) using define current user .
  var user = APIS.auth.currentUser;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      // Exit this Splash Screen and Continuo Home Screen will the process .
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
        ),
      );
      // Define curent user OR not a current user .
      if (user != null) {
        Navigator.pushReplacementNamed(context, RouteName.homeScreen);
      } else {
        Navigator.pushReplacementNamed(context, RouteName.loginScreen);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ! Image Section .
              Image.asset(
                Resources.imagesPath.chatImages,
                height: size.height * 0.3,
                width: size.width,
              ),
              const Spacer(),
              Text("From Meta App ❤",
                  style: Resources.textStyle.endTextTextStyle()),
              SizedBox(
                height: size.height * 0.03,
              )
            ],
          ),
        ),
      ),
    );
  }
}
