import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  final Function(String value)? onSend;
  const ChatBox({Key? key, this.onSend}) : super(key: key);

  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  Widget build(BuildContext context) {
    String v = '';
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      margin: EdgeInsets.zero,
      height: 50,
      child: Row(
        children: [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(
          //     LineIcons.paperclip,
          //     color: Color(0xff7a7a7a),
          //   ),
          // ),
          Expanded(
            child: TextFormField(
              controller: TextEditingController(text: v),
              maxLines: 1,
              onChanged: (String b) {
                v = b;
              },
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xffdbdbdb),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xffdbdbdb),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                counterText: "",
                hintText: 'اكتب هنا ...',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onSend!(v);
              v = '';
              setState(() {});
            },
            icon: const Icon(
              Icons.send,
              color: Color(0xff7a7a7a),
            ),
          ),
        ],
      ),
    );
  }
}
