// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:messager/Components/Helper_Widget/my_date_until.dart';
import 'package:messager/Export/export_file.dart';
import 'package:messager/Models/chat_user.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, required this.chatUser});

  final ChatUser chatUser;
  @override
  State<ViewProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return GestureDetector(
      // For hide keyboard focus .
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.chatUser.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Page images section .
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.height * 0.3),
                    child: CachedNetworkImage(
                      height: size.height * .3,
                      width: size.height * .3,
                      fit: BoxFit.cover,
                      imageUrl: widget.chatUser.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  // Profile page email sections .
                  Text(
                    widget.chatUser.email,
                    style: Resources.textStyle.viewProfileEmailTextStyle(),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),

                  //user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('About: '.toUpperCase(),
                          style:
                              Resources.textStyle.viewProfileTextAboutStyle()),
                      Text(widget.chatUser.about,
                          style:
                              Resources.textStyle.viewProfileTAboutInfoStyle()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: //user about
            Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined On: ',
              style: Resources.textStyle.viewProfileJoinedNowStyle(),
            ),
            Text(
                MyDateUntil.getLastMessageTime(
                    context: context,
                    time: widget.chatUser.createdAt,
                    showYear: true),
                style: Resources.textStyle.viewProfileJoinedTextStyle()),
          ],
        ),
      ),
    );
  }
}
