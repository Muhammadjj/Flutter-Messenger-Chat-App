import 'package:messager/Export/export_file.dart';
import 'package:messager/Screens/Auth/Login_Page/Components/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  GoogleSignInMethod signInMethod = GoogleSignInMethod();
  // Animation .
  late Animation<Offset> imageOffset;
  late Animation<Offset> buttonOffset;
  // Animation Controller .
  late AnimationController controller;

  // initial State Run
  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    imageOffset = Tween(
      begin: const Offset(0.5, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(controller);

    buttonOffset = Tween(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.1),
    ).animate(controller);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome To Messenger".toUpperCase(),
          style: Resources.textStyle.loginAppBarTextStyle(),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ! Image Section .
            SlideTransition(
              position: imageOffset,
              child: Image.asset(
                Resources.imagesPath.chatImages,
                height: size.height * 0.3,
                width: size.width,
              ),
            ),
            const Spacer(),

            // ! Google Button Sections .
            SlideTransition(
              position: buttonOffset,
              child: SizedBox(
                width: size.width * 0.8,
                child: ElevatedButton(
                    style: const ButtonStyle(
                        elevation: MaterialStatePropertyAll(16),
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(90, 38, 228, 171))),
                    onPressed: () async {
                      await signInMethod.signInWithGoogle(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          Resources.imagesPath.googleImages,
                          fit: BoxFit.cover,
                          height: size.height * 0.07,
                        ),
                        Text.rich(TextSpan(
                            text: "Sign In With\t\t",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                  text: "Google",
                                  style: Resources.textStyle
                                      .loginGoogleTextTextStyle())
                            ]))
                      ],
                    )),
              ),
            ),
            SizedBox(
              height: size.height * 0.09,
            )
          ],
        ),
      ),
    );
  }
}
