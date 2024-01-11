// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messager/Controller/Apis/apis.dart';
import 'package:messager/Controller/Routes/routes_method.dart';
import 'package:messager/Export/export_file.dart';
import 'package:messager/Models/chat_user.dart';
import '../../Components/Helper_Widget/dialogs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.chatUser});

  final ChatUser chatUser;
  @override
  State<ProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProfileScreen> {
  final _fromKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return GestureDetector(
      // For hide keyboard focus .
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile Screen".toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: floatingPointButtonSection(context),
        body: Form(
          key: _fromKey,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Page images section .
                    Stack(children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.height * 0.3),
                              child: Image.file(
                                File(_image!),
                                height: size.height * .2,
                                width: size.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.height * 0.3),
                              child: CachedNetworkImage(
                                height: size.height * .2,
                                width: size.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.chatUser.image,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person),
                              ),
                            ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet(size: size);
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(Icons.edit, color: Colors.blue),
                        ),
                      )
                    ]),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    // Profile page email sections .
                    Text(
                      widget.chatUser.email,
                      style: Resources.textStyle.profileUserEmailTextStyle(),
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),

                    //  Todo : Update TextFormField .
                    TextFormField(
                      initialValue: widget.chatUser.name,
                      onSaved: (val) => APIS.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.person, color: Resources.colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Happy Boy',
                          label: const Text('Name')),
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    TextFormField(
                      initialValue: widget.chatUser.about,
                      onSaved: (val) => APIS.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.info_outline,
                              color: Resources.colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Feeling Happy',
                          label: const Text('About')),
                    ),

                    SizedBox(
                      height: size.height * 0.05,
                    ),

                    // ! Update Button Section .
                    ElevatedButton.icon(
                        onPressed: () async {
                          if (_fromKey.currentState!.validate()) {
                            _fromKey.currentState?.save();
                            await APIS.updateUserInfo().then((value) {
                              Dialogs.showSnackbar(
                                  context, "Profile Screen Update");
                            });
                            log("Successfully Enter the Form ");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Resources.colors.blue,
                            shape: const StadiumBorder(),
                            minimumSize:
                                Size(size.width * .5, size.height * .06)),
                        icon: Icon(
                          Icons.edit,
                          size: 28,
                          color: Resources.colors.white,
                        ),
                        label: Text(
                          "Update".toUpperCase(),
                          style: TextStyle(
                              color: Resources.colors.white, fontSize: 20),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ! Floating Point button Working Section .
  FloatingActionButton floatingPointButtonSection(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Resources.colors.redAccent,
      onPressed: () async {
        // show this progress Dialog Bar .
        Dialogs.showProgressBar(context);
        APIS.updateActiveStatus(false);
        // Sign Out from app .
        await APIS.auth.signOut().then((value) async {
          await GoogleSignIn().signOut().then((value) {
            // for hiding progress dialog Bar
            Navigator.pop(context);
            // for moving to home screen .
            Navigator.pop(context);

            APIS.auth = FirebaseAuth.instance;
            // replace to homeScreen with login screen .
            Navigator.pushReplacementNamed(context, RouteName.loginScreen);
          });
        });
      },
      icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
      label: Text(
        "LogOut".toUpperCase(),
        style: TextStyle(color: Resources.colors.white),
      ),
    );
  }

  // ! bottom sheet for picking a profile picture for user
  void _showBottomSheet({size}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return ListView(shrinkWrap: true, children: [
          //pick profile picture label
          Text('Pick Profile Picture',
              textAlign: TextAlign.center,
              style: Resources.textStyle.bottomSheetTextStyle()),

          //for adding some space
          SizedBox(height: size.height * .02),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ** Gallery Button Section
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(size.width * .3, size.height * .15)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    // Pick an image
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (image != null) {
                      log('Image Path: ${image.path}  -- Image Mine ${image.mimeType}');
                      // for hiding bottom sheet .
                      Navigator.pop(context);
                      setState(() {
                        _image = image.path;
                      });

                      // save images in firebase storage and store images firestore database .
                      APIS.uploadProfileImages(File(_image!));
                    }
                  },
                  child:
                      Image(image: AssetImage(Resources.imagesPath.addImages))),

              // ** Camera Button Section
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(size.width * .3, size.height * .15)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    // Pick an image
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (image != null) {
                      log('Image Path: ${image.path}');
                      // for hiding bottom sheet .
                      Navigator.pop(context);
                      setState(() {
                        _image = image.path;
                      });

                      // save images in firebase storage and store images firestore database .
                      APIS.uploadProfileImages(File(_image!));
                    }
                  },
                  child: Image(
                      image: AssetImage(Resources.imagesPath.cameraImages))),
            ],
          )
        ]);
      },
    );
  }
}
