import 'package:cached_network_image/cached_network_image.dart';
import 'package:messager/Components/Helper_Widget/my_date_until.dart';
import 'package:messager/Controller/Apis/apis.dart';
import 'package:messager/Controller/Routes/routes_method.dart';
import 'package:messager/Models/chat_user.dart';
import 'package:messager/Models/messages.dart';

import '../../Export/export_file.dart';
import '../../Screens/Home_Screen/Components/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.chatUser});
  final ChatUser chatUser;
  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null--> no message)
  Messages? _messages;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Card(
        // color: Colors.blue.shade100,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.symmetric(horizontal: size.width * .03, vertical: 4),
        child: StreamBuilder(
          stream: APIS.getLastMessage(widget.chatUser),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Messages.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _messages = list[0];

            return ListTile(
              // tap press section .
              onTap: () {
                Navigator.pushNamed(context, RouteName.chatScreen,
                    arguments: widget.chatUser);
              },
              title: Text(widget.chatUser.name.toString()),
              // last message .
              subtitle: Text(_messages != null
                  ? _messages!.type == Type.image
                      ? "image"
                      : _messages!.msg
                  : widget.chatUser.about.toString()),
              // show Images sections
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ProfileDialog(
                        chatUser: widget.chatUser,
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size.height * 0.03),
                  child: CachedNetworkImage(
                    height: size.height * .055,
                    width: size.height * .055,
                    imageUrl: widget.chatUser.image,
                    fit: BoxFit.fill,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person),
                  ),
                ),
              ),
              // show new user dot sections .
              // last message time
              trailing: _messages == null
                  ? null // show nothing when no message is not
                  : _messages!.read.isEmpty &&
                          _messages!.fromId != APIS.user.uid
                      // show for unread message
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              color: Resources.colors.greenAccentShade400,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      : Text(
                          MyDateUntil.getLastMessageTime(
                              context: context, time: _messages!.send),
                          style: TextStyle(color: Resources.colors.black54),
                        ),
            );
          },
        ));
  }
}
