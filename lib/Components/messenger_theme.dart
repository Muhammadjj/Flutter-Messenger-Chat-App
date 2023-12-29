import 'package:messager/Export/export_file.dart';

class MessengerTheme {
  static ThemeData messengerTheme() {
    return ThemeData(
        // Icon Theme
        iconButtonTheme: const IconButtonThemeData(
            style:
                ButtonStyle(iconColor: MaterialStatePropertyAll(Colors.black))),
        // AppBar Theme
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            centerTitle: true,
            titleTextStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 17),
            elevation: 1),
        // Flexible material Top Widget.
        useMaterial3: true);
  }
}
