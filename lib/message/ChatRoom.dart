import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? imageFile;
  final scrollController = ScrollController();
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        _isUserScrolling = true;
      }
    });
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'pptx', 'ppt'],
    );

    if (result != null && result.files.isNotEmpty) {
      File pickedFile = File(result.files.single.path!);
      setState(() {
        imageFile = pickedFile;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = const Uuid().v1();
    int status = 1;

    // Determine the file extension
    String extension =
        imageFile != null ? imageFile!.path.split('.').last.toLowerCase() : '';

    String? fileType; // Default to 'file' type

    // Check the file extension and set the appropriate type
    if (extension == 'jpg' || extension == 'png' || extension == 'jpeg') {
      fileType = 'img';
    } else if (extension == 'pdf' ||
        extension == 'doc' ||
        extension == 'docx' ||
        extension == 'ppt' ||
        extension == 'pptx') {
      fileType = 'file';
    }

    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": auth.currentUser!.displayName,
      "message": "",
      "type": fileType,
      "time": FieldValue.serverTimestamp(),
    });

    var ref = FirebaseStorage.instance.ref().child('files').child(fileName);

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      setState(() {
        status = 0;
      });

      return;
    });

    if (status == 1) {
      String fileUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": fileUrl});
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);

      if (!_isUserScrolling) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Color getDotColor(String status) {
    if (status == 'Online') {
      return Colors.greenAccent;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where('uid', isEqualTo: widget.userMap['uid'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final clients = snapshot.data!.docs;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: clients.map((client) {
                  final status = client['status'];

                  String fullName = client['name'];
                  List<String> words = fullName.split(' ');
                  String firstName = words.take(2).join(' ');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: CachedNetworkImageProvider(
                                client['profileImage']),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstName, // Display the first two words only
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    status,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: getDotColor(status),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  );
                }).toList(),
              );
            } else {
              return Container();
            }
          },
        ),
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chatroom')
                  .doc(widget.chatRoomId)
                  .collection('chats')
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;
                  return SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      children: messages.map((message) {
                        Map<String, dynamic> map = message.data();
                        return buildMessageWidget(
                            size, map, context, scrollController);
                      }).toList(),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Center(
            child: Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 15,
                      width: size.width / 1.3,
                      child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () => pickFile(),
                                icon: const Icon(Icons.upload_file_rounded,
                                    color: Color.fromRGBO(58, 150, 255, 1)),
                              ),
                              hintText: "Send Message",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          )),
                    ),
                    IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color.fromRGBO(58, 150, 255, 1),
                        ),
                        onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Rename the function to buildMessageWidget to avoid naming conflict
  Widget buildMessageWidget(Size size, Map<String, dynamic> map,
      BuildContext context, ScrollController scrollController) {
    if (map['type'] == "text") {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        width: size.width,
        alignment: map['sendby'] == auth.currentUser!.displayName
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          decoration: map['sendby'] == auth.currentUser!.displayName
              ? const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      topRight: Radius.circular(10)),
                  color: Colors.grey,
                )
              : const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(10)),
                  color: Color.fromRGBO(58, 150, 255, 1),
                ),
          child: Text(
            map['message'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else if (map['type'] == "file") {
      return Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        alignment: map['sendby'] == auth.currentUser!.displayName
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            if (map['message'].isNotEmpty) {
              downloadFile(map['message']);
            }
          },
          child: Container(
            height: size.height / 22,
            width: size.width / 2,
            decoration: map['sendby'] == auth.currentUser!.displayName
                ? const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        topRight: Radius.circular(10)),
                    color: Colors.grey,
                  )
                : const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                        topLeft: Radius.circular(10)),
                    color: Color.fromRGBO(58, 150, 255, 1),
                  ),
            alignment: map['message'] != "" ? null : Alignment.center,
            child: map['message'] != ""
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_present,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'file',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    ],
                  ) // Display file icon
                : Container(
                    height: 24, // Adjust the height as needed
                    width: 24, // Adjust the width as needed
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
          ),
        ),
      );
    } else if (map['type'] == "img") {
      return Container(
        height: size.height / 2.5,
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        alignment: map['sendby'] == auth.currentUser!.displayName
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ShowImage(
                imageUrl: map['message'],
              ),
            ),
          ),
          child: Container(
            height: size.height / 2.5,
            width: size.width / 2,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            alignment: map['message'] != "" ? null : Alignment.center,
            child: map['message'] != ""
                ? Image.network(
                    map['message'],
                    fit: BoxFit.cover,
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Container();
  }

  Future<void> downloadFile(String fileUrl) async {
    final dir = await getExternalStorageDirectory();
    final savePath = '${dir!.path}/${DateTime.now().millisecondsSinceEpoch}';

    final savedDir = Directory(savePath);
    if (!savedDir.existsSync()) {
      savedDir.createSync(recursive: true);
    }

    try {
      final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: savePath,
        fileName: 'Downloaded File',
        showNotification: true,
        openFileFromNotification: true,
      );
    } catch (error, stackTrace) {
      print('Error downloading file: $error');
      print('Stack Trace: $stackTrace');
    }
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: CachedNetworkImage(imageUrl: imageUrl),
      ),
    );
  }
}
