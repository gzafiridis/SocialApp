import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/widgets/chat/message_bubble.dart';
import 'package:diplomatiki/widgets/chat/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';
  var id;
  var user;
  var _isInit = true;
  var myTag;
  var otherTag;
  var args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      args = ModalRoute.of(context).settings.arguments as List;
      id = args[0];
      if (args[1] == 'patient')
        otherTag = 'patients';
      else
        otherTag = 'doctors';
      user = Provider.of<Auth>(context, listen: false);
      if (user.userRole == 'patient')
        myTag = 'patients';
      else
        myTag = 'doctors';
    }
    _isInit = false;
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    FirebaseFirestore.instance
        .collection(myTag)
        .doc(user.userId)
        .collection('chats')
        .doc(id)
        .collection('messages')
        .add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.userId,
      'username': user.userName,
      'photo': user.userPhoto
    });
    FirebaseFirestore.instance
        .collection(otherTag)
        .doc(id)
        .collection('chats')
        .doc(user.userId)
        .collection('messages')
        .add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.userId,
      'username': user.userName,
      'photo': user.userPhoto
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Container(
          child: Column(
        children: [
          Expanded(child: Messages(tag: myTag, user: user, id: id)),
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration:
                        InputDecoration(labelText: 'Write your message...'),
                    onChanged: (value) {
                      setState(() {
                        _enteredMessage = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(
                    Icons.send,
                  ),
                  onPressed:
                      _enteredMessage.trim().isEmpty ? null : _sendMessage,
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}
