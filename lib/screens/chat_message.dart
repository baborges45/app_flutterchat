import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({Key? key, required this.data, required this.checkUser})
      : super(key: key);

  final Map<String, dynamic> data;
  final bool? checkUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !checkUser!
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          data['senderPhotoUrl'],
                        ),
                      ),
                    ),
                    Text(
                      data['nickname'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: checkUser!
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                data['imgUrl'] != null
                    ? Column(
                        children: [
                          Image.network(
                            data['imgUrl'],
                            width: 250,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            data['time'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            data['date'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )
                    : _makeText(),
              ],
            ),
          ),
          checkUser!
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          data['senderPhotoUrl'],
                        ),
                      ),
                    ),
                    Text(
                      data['nickname'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _makeText() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: checkUser! ? Colors.indigo.shade300 : const Color(0xFF2E4C7B),
        ),
        child: Column(
          crossAxisAlignment:
              checkUser! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              data['text'],
              textAlign: checkUser! ? TextAlign.end : TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              data['time'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            Text(
              data['date'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
