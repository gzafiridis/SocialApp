import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/widgets/chat/message_bubble.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  const Messages({
    Key key,
    @required this.tag,
    @required this.user,
    @required this.id,
  }) : super(key: key);

  final tag;
  final user;
  final id;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(tag)
          .doc(user.userId)
          .collection('chats')
          .doc(id)
          .collection('messages')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = chatSnapshot.data.docs;
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) => MessageBubble(
            chatDocs[index].data()['text'],
            chatDocs[index].data()['username'],
            chatDocs[index].data()['photo'],
            chatDocs[index].data()['userId'] == user.userId,
            key: ValueKey(chatDocs[index].id),
          ),
        );
      },
    );
  }
}
