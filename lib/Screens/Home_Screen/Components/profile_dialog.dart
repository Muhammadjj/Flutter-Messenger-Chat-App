import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messager/Components/Resources/resources.dart';
import 'package:messager/Controller/Routes/routes_method.dart';
import '../../../Models/chat_user.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.chatUser});

  final ChatUser chatUser;

  @override
  Widget build(BuildContext context) {
    // using to mediaQuery .
    var sizeHeight = MediaQuery.sizeOf(context).height;
    var sizeWidth = MediaQuery.sizeOf(context).width;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Resources.colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
          width: sizeWidth * .6,
          height: sizeHeight * .35,
          child: Stack(
            children: [
              //user profile picture
              Align(
                alignment: Alignment.center,
                child: Positioned(
                  top: sizeHeight * .075,
                  left: sizeWidth * .1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(sizeHeight * .25),
                    child: CachedNetworkImage(
                      width: sizeWidth * .5,
                      fit: BoxFit.fill,
                      imageUrl: chatUser.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
              ),

              //user name
              Positioned(
                left: sizeWidth * .04,
                top: sizeHeight * .02,
                width: sizeWidth * .55,
                child: Text(chatUser.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
              ),

              //info button
              Positioned(
                  right: 8,
                  top: 6,
                  child: MaterialButton(
                    onPressed: () {
                      //for hiding image dialog
                      Navigator.pop(context);

                      //move to view profile screen
                      Navigator.pushNamed(context, RouteName.viewProfileScreen,
                          arguments: chatUser);
                    },
                    minWidth: 0,
                    padding: const EdgeInsets.all(0),
                    shape: const CircleBorder(),
                    child: const Icon(Icons.info_outline,
                        color: Colors.blue, size: 30),
                  ))
            ],
          )),
    );
  }
}
