import 'dart:async';
import 'dart:io';

import 'package:app_flutterchat/api/apis.dart';
import 'package:app_flutterchat/commons/styles.dart';
import 'package:app_flutterchat/screens/chat_message.dart';
import 'package:app_flutterchat/screens/text_field_component.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.tema,
    required this.nickname,
  }) : super(key: key);

  final String tema;
  final String nickname;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      user = userCredential.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  /// Envia mensagem e fotos em tempo real firebase
  Future<void> _sendMessage({String? text, File? imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível fazer o login. Tente novamente.'),
        backgroundColor: Colors.red,
      ));
    }

    // adicioanando os campos a serem enviados
    Map<String, dynamic> data = {
      'uid': user!.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoURL,
      'nickname': widget.nickname,
      'time': DateFormat('hh:mm').format(DateTime.now()),
      'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
    };

    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) {
      data['text'] = text;
    }

    //enviando para as collections do firebase
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.tema)
        .collection('messages')
        .add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1B232A),
      appBar: AppBar(
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser?.displayName}' //  recuepra o nome da conta do google
            : 'Chat App'),
        elevation: 0,
        actions: [
          Visibility(
              visible: _currentUser != null,
              child: IconButton(
                onPressed: () {
                  APIs.signOut(
                      context); // sai da conta quando foi logado com o email do google
                },
                icon: const Icon(
                  Icons.exit_to_app_rounded,
                ),
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 25,
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.tema)
                    .collection('messages')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents =
                          snapshot.data!.docs.reversed.toList();

                      return Container(
                        decoration: AppStyles.friendsBox(),
                        child: ListView.builder(
                          itemCount: documents.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return ChatMessage(
                              data: documents[index].data()
                                  as Map<String, dynamic>,
                              checkUser: (documents[index].data()
                                      as Map<String, dynamic>)['uid'] ==
                                  _currentUser?.uid,
                            );
                          },
                        ),
                      );
                  }
                },
              ),
            ),
            Visibility(
              visible: _isLoading,
              child:
                  const LinearProgressIndicator(), // para esperar o carregamento da imagem
            ),
            TextComposer(
              sendMessage: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
