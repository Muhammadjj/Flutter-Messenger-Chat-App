// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messager/Components/Helper_Widget/my_date_until.dart';
import 'package:messager/Components/Widgets/Message_Card/message_card.dart';
import 'package:messager/Controller/Routes/routes_method.dart';
import 'package:messager/Models/chat_user.dart';
import 'package:messager/Models/messages.dart';
import '../../Controller/Apis/apis.dart';
import '../../Export/export_file.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chatUser});
  final ChatUser chatUser;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Size size;
  // for storing all message
  List<Messages> list = [];

  TextEditingController textController = TextEditingController();
// for storing value of showing or hide emoji .
  bool _showEmoji = false, _uploadImages = false;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        top: false,
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
              backgroundColor: const Color.fromARGB(255, 234, 238, 255),
              // App Bar
              appBar: AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: APIS.getAllMessage(widget.chatUser),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          // if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );

                          //  access this firestore all data
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            log("All Data : ${jsonEncode(data?[0].data())}");
                            list = data
                                    ?.map((e) => Messages.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (list.isNotEmpty) {
                              return ListView.builder(
                                reverse: true,
                                itemCount: list.length,
                                padding:
                                    EdgeInsets.only(top: size.height * .02),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(messages: list[index]);
                                },
                              );
                            } else {
                              // Empty Text .
                              return const Scaffold(
                                  body: Center(child: Text("Say Hiiiii 🤚🤚")));
                            }
                        }
                      },
                    ),
                  ),
                  // Progress indicator for showing in uploading Images .
                  if (_uploadImages)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  _chatInput(size: size),
                  if (_showEmoji)
                    SizedBox(
                      height: size.height * .33,
                      child: EmojiPicker(
                        textEditingController: textController,
                        config: Config(
                          columns: 7,
                          initCategory: Category.SMILEYS,
                          bgColor: const Color.fromARGB(255, 234, 238, 255),
                          emojiSizeMax: 32 * (Platform.isAndroid ? 1.30 : 1.0),
                          buttonMode: ButtonMode.MATERIAL,
                        ),
                      ),
                    )
                ],
              )),
        ),
      ),
    );
  }

  Widget _chatInput({size}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: size.height * .01, horizontal: size.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // Back Button .
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Resources.colors.blueAccent,
                      )),

                  //  TextField

                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
                      controller: textController,
                      decoration: InputDecoration(
                          hintText: 'Type Something...',
                          hintStyle:
                              TextStyle(color: Resources.colors.blueAccent),
                          border: InputBorder.none),
                    ),
                  ),
                  // Back Button .
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 80);
                        for (var element in images) {
                          log('Image Path: ${element.path}');
                          setState(() => _uploadImages = true);
                          // save images in (firebase storage) and store images (firestore database) .
                          APIS
                              .sentChatImage(
                                  widget.chatUser, File(element.path))
                              .then((value) =>
                                  setState(() => _uploadImages = false));
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Resources.colors.blueAccent,
                      )),

                  // take images for camera button.
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');

                          setState(() => _uploadImages = true);
                          // save images in firebase storage and store images firestore database .
                          APIS
                              .sentChatImage(widget.chatUser, File(image.path))
                              .then((value) =>
                                  setState(() => _uploadImages = false));
                        }
                      },
                      icon: Icon(
                        Icons.camera,
                        color: Resources.colors.blueAccent,
                      )),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                APIS.sendMessage(
                    widget.chatUser, textController.text, Type.text);
                textController.clear();
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Resources.colors.green,
            child: Icon(Icons.send, color: Resources.colors.white, size: 28),
          )
        ],
      ),
    );
  }

  // ! AppBar Sections .
  Widget _appBar() {
    return InkWell(
        onTap: () => Navigator.pushNamed(context, RouteName.viewProfileScreen,
            arguments: widget.chatUser),
        child: StreamBuilder(
          stream: APIS.getUserInfo(widget.chatUser),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                // Back Button .
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Resources.colors.black54,
                    )),

                // show profile image
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    height: size.height * .05,
                    width: size.height * .05,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.chatUser.image,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person),
                  ),
                ),
                // fro adding some space .
                const SizedBox(
                  width: 10,
                ),

                // user name $ late seen time .
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //user name .
                    Text(list.isNotEmpty ? list[0].name : widget.chatUser.name,
                        style: TextStyle(
                            fontSize: 16,
                            color: Resources.colors.black87,
                            fontWeight: FontWeight.w500)),

                    //for adding some space
                    const SizedBox(height: 2),
                    // last seen time of user  .
                    Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? "Online"
                                : MyDateUntil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUntil.getLastActiveTime(
                                context: context,
                                lastActive: widget.chatUser.lastActive,
                              ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Resources.colors.black54,
                        )),
                  ],
                )
              ],
            );
          },
        ));
  }
}
