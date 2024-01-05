import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:messager/Components/Helper_Widget/my_date_until.dart';
import 'package:messager/Controller/Apis/apis.dart';
import 'package:messager/Models/messages.dart';
import '../../../Export/export_file.dart';
import '../../Helper_Widget/dialogs.dart';
import 'option_item.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.messages});
  final Messages messages;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  late Size size;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    bool isMe = APIS.user.uid == widget.messages.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe: isMe, size: size);
      },
      child: isMe ? greenMessage() : blueMessage(),
    );
  }

  //!  sender and other message
  Widget blueMessage() {
    if (widget.messages.read.isEmpty) {
      APIS.updateMessageReadStatus(widget.messages);
      log("Message Read Updated");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.messages.type == Type.image
                ? size.width * .03
                : size.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: size.width * .04, vertical: size.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.messages.type == Type.text
                ? Text(widget.messages.msg)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.messages.msg,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: size.width * .04),
          child: Text(
            MyDateUntil.getFormattedTime(
                context: context, time: widget.messages.send),
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        )
      ],
    );
  }

  //!  our or user message .
  Widget greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //  some space .
            SizedBox(
              width: size.width * .04,
            ),

            // double tick blue icon for read .
            if (widget.messages.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                size: 20,
                color: Colors.blueAccent,
              ),
            // for add some space .
            const SizedBox(
              width: 2,
            ),
            // read Time .
            Padding(
              padding: EdgeInsets.only(right: size.width * .04),
              child: Text(
                MyDateUntil.getFormattedTime(
                    context: context, time: widget.messages.send),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.messages.type == Type.image
                ? size.width * .03
                : size.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: size.width * .04, vertical: size.height * .01),
            decoration: BoxDecoration(
                color: Colors.lightGreen,
                border: Border.all(color: Colors.lightBlue),
                // making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.messages.type == Type.text
                ?
                //  show text .
                Text(widget.messages.msg)
                : // show images .
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.messages.msg,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet({required bool isMe, required Size size}) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              // ! black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: size.height * .015, horizontal: size.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.messages.type == Type.text
                  ?
                  // !  copy option
                  OptionItem(
                      size: size,
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        ///* (Service library) Copy text class (Clipboard) and more
                        ///* more option
                        await Clipboard.setData(
                                ClipboardData(text: widget.messages.msg))
                            .then((value) {
                          Navigator.pop(context); // hide this bottom bar .
                          // Show snackBar.
                          Dialogs.showSnackbar(context, "Copy Text");
                        });
                      })
                  :
                  // ! save option
                  OptionItem(
                      size: size,
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {}),

              //!separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: size.width * .04,
                  indent: size.width * .04,
                ),

              //!edit option
              if (widget.messages.type == Type.text && isMe)
                OptionItem(
                    size: size,
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {}),

              //!delete option
              if (isMe)
                OptionItem(
                    size: size,
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      // Delete a Message Id .
                      await APIS.deleteMessage(widget.messages).then((value) {
                        Navigator.pop(context); // hide this bottom bar .})
                      });
                    }),

              //!separator or divider
              Divider(
                color: Colors.black54,
                endIndent: size.width * .04,
                indent: size.width * .04,
              ),

              //!sent time
              OptionItem(
                  size: size,
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      'Sent At: ${MyDateUntil.getMessageTime(context: context, time: widget.messages.send)}',
                  onTap: () {}),

              //!read time
              OptionItem(
                  size: size,
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.messages.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUntil.getMessageTime(context: context, time: widget.messages.read)}',
                  onTap: () {}),
            ],
          );
        });
  }
}
