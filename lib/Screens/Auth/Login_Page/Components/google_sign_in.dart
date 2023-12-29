// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messager/Controller/Apis/apis.dart';
import 'package:messager/Controller/Routes/routes_method.dart';
import '../../../../Components/Helper_Widget/dialogs.dart';
import '../../../../Export/export_file.dart';

class GoogleSignInMethod {
// Todo : Google Auth In Flutter Help With Firebase
  FirebaseAuth auth = FirebaseAuth.instance;
// ! Google Sign In All Process .
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    Dialogs.showProgressBar(context);
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow  means ka end user ko ak dialog view
      // ho ga js pr end user apne email select kr skta ha aur agr hmra user
      // apne current email select krta ha to hmy authentication check krne prte ha
      // aur agr hmra user (Google Dialog) ko bnd krta ha to (GoogleSignInAccount)
      // Object return ma (null) bhjta haa . jo Future<UserCredential> ko mlta ha
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request means ka GoogleSignIn hona ka
      // bd hmy ab Two thing ki zarort ha (AccessToken, IdToken) ya dono hmy
      // hmra email ma majod data tk rasiye daty ha
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      // Create a new credential means ka Firebase ka Credential (conditions) ko
      // check krta ha aur asy ya sb kuch krna ka laya (accessToken , IdToken) ki
      // zarort hote ha .
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      debugPrint("Google User : $googleUser");
      debugPrint("Google User Email : ${googleUser!.email.toString()}");
      debugPrint("Google User DisPlayName : ${googleUser.displayName}");
      // Once signed in, return the UserCredential
      return await auth.signInWithCredential(credential).then((value) async {
        Navigator.pop(context);
        debugPrint("Google Button Login");
        debugPrint("Successfully ");

        if ((await APIS.isUserExists())) {
          Navigator.pushReplacementNamed(context, RouteName.homeScreen);
        } else {
          APIS.creatingNewUser().then((value) {
            Navigator.pushReplacementNamed(context, RouteName.homeScreen);
          });
        }
        return auth.signInWithCredential(credential);
      });
    } catch (error) {
      log("\n signInWithGoogle : $error ");
      Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }
}
