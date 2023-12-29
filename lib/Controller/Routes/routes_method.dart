import 'package:messager/Models/chat_user.dart';
import 'package:messager/Screens/Auth/Splash_Screen/splash_screen.dart';
import 'package:messager/Screens/Chat_Screen/chat_screen_main.dart';
import 'package:messager/Screens/Profile_Screen/profile_screen_main.dart';
import 'package:messager/Screens/View_Chat_Profile_Screen.dart/view_profile_screen.dart';
import '../../Export/export_file.dart';

// ! Different Routes Names .
class RouteName {
  static const String loginScreen = 'LoginScreen';
  static const String homeScreen = 'HomeScreen';
  static const String profileScreen = 'ProfileScreen';
  static const String chatScreen = 'ChatScreen';
  static const String viewProfileScreen = 'ViewProfileScreen';
  static const String splashScreen = 'SplashScreen';
}

// ! Routes Handle Methods .
class RouteMethod {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // 1
    if (settings.name == RouteName.loginScreen) {
      return PageRoutesTransition(child: const LoginScreen());
    }
    // 2
    else if (settings.name == RouteName.homeScreen) {
      return PageRoutesTransition(child: const HomeScreen());
    }
    // 3
    else if (settings.name == RouteName.profileScreen) {
      return PageRoutesTransition(
          child: ProfileScreen(
        chatUser: settings.arguments as ChatUser,
      ));
    }
    // 4
    else if (settings.name == RouteName.splashScreen) {
      return PageRoutesTransition(child: const SplashScreen());
    }
    // 5
    else if (settings.name == RouteName.chatScreen) {
      return PageRoutesTransition(
          child: ChatScreen(
        chatUser: settings.arguments as ChatUser,
      ));
    }
    // 6
    else if (settings.name == RouteName.viewProfileScreen) {
      return PageRoutesTransition(
          child: ViewProfileScreen(
        chatUser: settings.arguments as ChatUser,
      ));
    }
    // Not Found .
    else {
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
            body: Center(
          child: Text("Pages Not Found"),
        )),
      );
    }
  }
}

///! PageRouteBuilder method using Transition .
class PageRoutesTransition extends PageRouteBuilder {
  final Widget child;
  PageRoutesTransition({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );
}
