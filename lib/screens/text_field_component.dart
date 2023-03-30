import 'dart:io';

import 'package:app_flutterchat/commons/styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({Key? key, this.sendMessage}) : super(key: key);

  final Function({String? text, File? imgFile})? sendMessage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;

  final TextEditingController _controller = TextEditingController();

  void _reset() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: AppStyles.messageFieldCardStyle(),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final XFile? imgFile = await ImagePicker().pickImage(
                source: ImageSource.camera,
              );
              if (imgFile == null) {
                return;
              }
              File fileSend = File(imgFile.path);
              widget.sendMessage!(imgFile: fileSend);
            },
            icon: const Icon(Icons.photo_camera),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                  hintText: "Enviar uma mensagem"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage!(text: text);
                _reset();
              },
            ),
          ),
          IconButton(
            onPressed: _isComposing
                ? () {
                    widget.sendMessage!(text: _controller.text);
                    _reset();
                  }
                : null,
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
