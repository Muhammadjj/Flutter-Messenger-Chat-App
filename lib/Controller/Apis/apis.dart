import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:messager/Models/chat_user.dart';
import 'package:messager/Models/messages.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../Export/export_file.dart';

class APIS {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud Firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing cloud Firestore database
  static FirebaseStorage storage = FirebaseStorage.instance;
  // for storing user info
  static late ChatUser me;

  // ! current user information
  static User get user => auth.currentUser!;

  //! for accessing firebase messaging (Push Notification)
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token .
  static Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission();

    firebaseMessaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        log("Token $value");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      var body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "Chats",
        },
        "data": {
          "some_data": "User ID : ${me.id}",
        }
      };
      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAArs-WpjM:APA91bEhz84aSjdIp4on03ff1Mco2izFMOixlNSVRcUlLoao23-rajaCajSofSyXeW1ki-Jz-dunVk5IzJcj6zr0uqXNoMXzOiUdcC7GIZvZryIqqq7W8uoDkxjxubCn5UiR8VhALGn1'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      debugPrint("\nException :: $e");
    }
  }

  // ! for checking user exists OR not exists .
  static Future<bool> isUserExists() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  // ! for checking user exists OR not exists .
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      log("User Exists : ${data.docs.first.id}");
      firestore
          .collection("users")
          .doc(user.uid)
          .collection("add_User")
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  // ! for checking user exists OR not exists .
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((value) async {
      if (value.exists) {
        me = ChatUser.fromJson(value.data()!);
        getFirebaseMessagingToken();
      } else {
        await creatingNewUser().then((value) => getSelfInfo());
      }
    });
  }

  // ! for creating a new user .
  static Future<void> creatingNewUser() async {
    final dateTime = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: "Hy Jawad I am a Firebase New User ",
        createdAt: dateTime,
        id: user.uid,
        lastActive: dateTime,
        isOnline: false,
        pushToken: "",
        email: user.email.toString());

    return (await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson()));
  }

  // ! for getting all users from firebase database .
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  // for checking user exists OR not exists .
  static Future<void> updateUserInfo() async {
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({"name": me.name, "about": me.about});
  }

  // ! Update profile picture of current user .
  static Future<void> uploadProfileImages(File file) async {
    // getting image file extension .
    var ext = file.path.split(".").last;
    log("Extension : $ext");
    // storage file ref with path .
    final ref = storage.ref().child("profile_picture/${user.uid}.$ext");
    //  upload images .
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      log("Data Transferred ${p0.bytesTransferred / 1000} kb");
    });

    me.image = await ref.getDownloadURL();
    // updating image in firestore database .
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({"image": me.image});
  }

  // for getting specific user .
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection("users")
        .where("id", isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online and last online status of user .
  static Future<void> updateActiveStatus(bool isOnline) async {
    return firestore.collection("users").doc(user.uid).update({
      "is_Online": isOnline,
      "last_active": DateTime.now().millisecondsSinceEpoch.toString(),
      "push_token": me.pushToken
    });
  }

  // /////////////////////////////////////////////////

  ///************** Chat Screen Related APIs **************
  /// Structure of Two user conversation for Firebase 👇👇👇
  //  Todo :=> chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // ! useful for getting  conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? "${user.uid}_$id"
      : "${id}_${user.uid}";

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationId(user.id)}/messages/")
        .orderBy("send", descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Messages message = Messages(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        send: time);

    //
    final ref = firestore
        .collection("chats/${getConversationId(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : "image"));
  }

  // update read status of message .
  static Future<void> updateMessageReadStatus(Messages messages) async {
    firestore
        .collection("chats/${getConversationId(messages.fromId)}/messages/")
        .doc(messages.send)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific chat .
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationId(user.id)}/messages/")
        .orderBy("send", descending: true)
        .limit(1)
        .snapshots();
  }

  // Todo : send chat images .
  static Future<void> sentChatImage(ChatUser chatUser, File file) async {
    // getting image file extension .
    var ext = file.path.split(".").last;
    // storage file ref with path .
    final ref = storage.ref().child(
        "image/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");
    // Upload images .
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      log("Data Transferred ${p0.bytesTransferred / 1000} kb");
    });

    final imageUrl = await ref.getDownloadURL();
    // updating image in firestore database .
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //* Delete Message .
  static Future<void> deleteMessage(Messages messages) async {
    await firestore
        .collection("chats/${getConversationId(messages.toId)}/messages/")
        .doc(messages.send)
        .delete();
    if (messages.type == Type.image) {
      await storage.refFromURL(messages.msg).delete();
    }
  }

  // update tis messages .
  static Future<void> updateMessage(Messages message, String updateMsg) async {
    firestore
        .collection("chats/${getConversationId(message.toId)}/messages/")
        .doc(message.send)
        .update({"msg": updateMsg});
  }
}
