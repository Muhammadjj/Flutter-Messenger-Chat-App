import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:messager/Components/Helper_Widget/my_date_until.dart';
import 'package:messager/Controller/Apis/apis.dart';
import 'package:messager/Models/messages.dart';
import '../../Export/export_file.dart';

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
    return APIS.user.uid == widget.messages.fromId
        ? greenMessage()
        : blueMessage();
  }

  // sender and other message
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

  // our or user message .
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
}
