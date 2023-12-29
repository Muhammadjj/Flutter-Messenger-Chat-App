import '../../Export/export_file.dart';

class CustomTextStyle {
  // ! Login Page TextStyle .
  TextStyle loginGoogleTextTextStyle() {
    return TextStyle(
        fontWeight: FontWeight.bold, fontSize: 23, color: Resources.colors.red);
  }

  TextStyle loginAppBarTextStyle() {
    return TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Resources.colors.black);
  }

  // ! Splash Screen TextStyle .
  TextStyle endTextTextStyle() {
    return TextStyle(
        color: Resources.colors.green,
        fontSize: 20,
        overflow: TextOverflow.ellipsis,
        letterSpacing: .5,
        fontWeight: FontWeight.w500);
  }

  // ! Profile Page Text Style .
  TextStyle profileUserEmailTextStyle() {
    return TextStyle(
        fontSize: 16,
        color: Resources.colors.black54,
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.w400);
  }

  // profile bottom sheet text style .
  TextStyle bottomSheetTextStyle() {
    return const TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
  }

  // ! View Profile screen Text Style .
  // Email Text .
  TextStyle viewProfileEmailTextStyle() {
    return TextStyle(
        fontSize: 20,
        color: Resources.colors.black,
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.w400);
  }

  // User About Text .
  TextStyle viewProfileTextAboutStyle() {
    return TextStyle(
        color: Resources.colors.black87,
        fontWeight: FontWeight.w500,
        fontSize: 15);
  }

  // User About information .
  TextStyle viewProfileTAboutInfoStyle() {
    return TextStyle(color: Resources.colors.black54, fontSize: 15);
  }

  // join Now Text Style
  TextStyle viewProfileJoinedNowStyle() {
    return TextStyle(
        color: Resources.colors.black87,
        fontWeight: FontWeight.w500,
        fontSize: 15);
  }

// join Now Text Style
  TextStyle viewProfileJoinedTextStyle() {
    return const TextStyle(color: Colors.black54, fontSize: 15);
  }
}
