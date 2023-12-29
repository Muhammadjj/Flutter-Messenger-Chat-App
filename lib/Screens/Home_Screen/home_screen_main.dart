// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messager/Controller/Apis/apis.dart';
import 'package:messager/Controller/Routes/routes_method.dart';
import 'package:messager/Export/export_file.dart';
import 'package:messager/Models/chat_user.dart';
import '../../Components/Widgets/empty_screen.dart';
import '../../Components/Widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeScreen> {
  // for storing all User
  List<ChatUser> _list = [];
  // for storing all searching
  final List<ChatUser> _searchUser = [];
  // for storing all search status .
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIS.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log("message : $message");

      if (APIS.auth.currentUser != null) {
        if (message.toString().contains("resume")) {
          APIS.updateActiveStatus(true);
        }
        if (message.toString().contains("pause")) {
          APIS.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      //if search is on & back button is pressed then close search
      //or else simple close current screen on back button click
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name, Email, ...'),
                      autofocus: true,
                      style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                      // When search text change then update search list .
                      onChanged: (val) {
                        _searchUser.clear();
                        for (var element in _list) {
                          if (element.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              element.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchUser.add(element);
                          }
                          setState(() {
                            _searchUser;
                          });
                        }
                      },
                    )
                  : Text(
                      "Messenger".toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
              leading: IconButton(
                  onPressed: () {}, icon: const Icon(CupertinoIcons.home)),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: _isSearching
                        ? const Icon(CupertinoIcons.clear_circled_solid)
                        : const Icon(Icons.search)),
                // Profile Screen Buttons Section .
                IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteName.profileScreen,
                          arguments: APIS.me);
                    },
                    icon: const Icon(Icons.more_vert)),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await APIS.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut();
                  Navigator.pushReplacementNamed(
                      context, RouteName.loginScreen);
                });
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
            body: StreamBuilder(
              stream: APIS.getAllUsers(),
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
                    _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];
                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        itemCount:
                            _isSearching ? _searchUser.length : _list.length,
                        padding: EdgeInsets.only(top: size.height * .02),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          // var name = snapshot.data?.docs[index].data()['about'];
                          return ChatUserCard(
                            chatUser: _isSearching
                                ? _searchUser[index]
                                : _list[index],
                          );
                        },
                      );
                    } else {
                      // Empty Screens .
                      return EmptyScreen(size: size);
                    }
                }
              },
            )),
      ),
    );
  }
}
