import 'package:app_flutterchat/commons/styles.dart';
import 'package:app_flutterchat/screens/chat_screen_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final temas = ['VENDAS', 'COMPRAS', 'EMPRESTIMOS'];
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade400,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        title: Text(
          'Temas',
          style: AppStyles.h1(),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(0),
                  child: Container(
                    color: Colors.indigo.shade400,
                    padding: const EdgeInsets.all(8),
                    height: 360,
                    child: Column(
                      children: [
                        const Spacer(),
                        const Center(
                          child: Text(
                            'Bem vindo\nEntre em uma sala',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: .5),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 100,
                          child: _listTemas(),
                        ),
                      ],
                    ),
                  ),
                ),
                //_makeContacts(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // recupera os dados do user cadastrado ainda em desenvolvimento
  Widget _makeContacts() => Expanded(
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(
                  'Contatos',
                  style: AppStyles.h1().copyWith(color: Colors.indigoAccent),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                height: 80,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    List data = !snapshot.hasData
                        ? []
                        : snapshot.data!.docs
                            .where((element) => element['id']
                                .toString()
                                .contains(
                                    FirebaseAuth.instance.currentUser!.uid))
                            .toList();

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final messages = snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                messages[index]['image'] ?? '',
                              ),
                            ),
                          ),
                          title: Text(
                            messages[index]['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            messages[index]['email'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  /// cria a lista de temas
  Widget _listTemas() => ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: temas.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String nickname = '';

                    return AlertDialog(
                      title: const Text('Digite seu nick'),
                      content: TextField(
                        onChanged: (value) {
                          nickname = value;
                        },
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  tema: temas[index],
                                  nickname: nickname,
                                ),
                              ),
                            );
                          },
                          child: const Text('Entrar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: temas[index].contains('VENDAS')
                        ? getClass('VENDAS')
                        : temas[index].contains('COMPRAS')
                            ? getClass('COMPRAS')
                            : getClass('EMPRESTIMOS'),
                  ),
                  SizedBox(
                      width: 100,
                      child: Center(
                          child: Text(
                        temas[index],
                        style: const TextStyle(
                          height: 1.5,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )))
                ],
              ),
            ),
          );
        },
      );

  Icon? getClass(status) {
    const map = {
      'VENDAS': Icon(
        Icons.maps_home_work_outlined,
        size: 40,
        color: Colors.white,
      ),
      'COMPRAS': Icon(
        Icons.shopping_bag_outlined,
        size: 40,
        color: Colors.white,
      ),
      'EMPRESTIMOS': Icon(
        Icons.account_balance_outlined,
        size: 40,
        color: Colors.white,
      ),
    };

    return map[status];
  }
}
